#!/usr/bin/env bash
# bootstrap.sh — first-boot / recovery for EC2 Airflow Compose stack.
# Runbook (CRLF, volumes, pip): docs/runbooks/airflow-ec2-bootstrap-postmortem.md
set -euo pipefail

: "${ARTIFACT_BUCKET:?ARTIFACT_BUCKET required}"
: "${AWS_REGION:?AWS_REGION required}"
: "${SSM_PASSWORD_PARAM:?SSM_PASSWORD_PARAM required}"
: "${AIRFLOW_IMAGE_DIGEST:?AIRFLOW_IMAGE_DIGEST required}"

INSTALL_DIR="/opt/airflow-ec2"
LOG="/var/log/airflow-ec2-bootstrap.log"
exec > >(tee -a "${LOG}") 2>&1

echo "[bootstrap] start $(date -Is)"

install_packages() {
  # AL2023 já traz curl-minimal (comando `curl`); não instalar pacote `curl` (conflito).
  dnf install -y docker jq
  systemctl enable --now docker
  usermod -aG docker ec2-user || true

  # AL2023 não empacota docker-compose-plugin via dnf — instala plugin CLI v2.
  local plugin_dir="/usr/local/lib/docker/cli-plugins"
  mkdir -p "${plugin_dir}"
  if [[ ! -x "${plugin_dir}/docker-compose" ]]; then
    curl -fsSL \
      "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64" \
      -o "${plugin_dir}/docker-compose"
    chmod +x "${plugin_dir}/docker-compose"
  fi
  docker compose version
}

pull_compose_package() {
  mkdir -p "${INSTALL_DIR}"/{dags,logs,plugins,config,python-packages}
  aws s3 sync "s3://${ARTIFACT_BUCKET}/airflow-ec2/" "${INSTALL_DIR}/" --region "${AWS_REGION}"
  # Prefer root requirements synced by sync-dags if newer path exists
  aws s3 cp "s3://${ARTIFACT_BUCKET}/requirements.txt" "${INSTALL_DIR}/requirements.txt" \
    --region "${AWS_REGION}" 2>/dev/null || true
  chmod +x "${INSTALL_DIR}/bootstrap.sh" || true
  # Airflow container (UID 50000) precisa escrever em logs/ — senão webserver falha no handler 'processor'.
  chown -R 50000:0 "${INSTALL_DIR}/dags" "${INSTALL_DIR}/logs" "${INSTALL_DIR}/plugins" \
    "${INSTALL_DIR}/config" "${INSTALL_DIR}/python-packages"
  chmod -R ug+rwX "${INSTALL_DIR}/logs" "${INSTALL_DIR}/python-packages"
}

generate_password() {
  openssl rand -base64 24 | tr -d '/+=' | head -c 20
}

write_env() {
  local password="$1"
  cat > "${INSTALL_DIR}/.env" <<EOF
AIRFLOW_IMAGE=apache/airflow:2.11.2@${AIRFLOW_IMAGE_DIGEST}
AIRFLOW_ADMIN_PASSWORD=${password}
AIRFLOW_UID=50000
AIRFLOW_PROJ_DIR=${INSTALL_DIR}
COMPOSE_PROJECT_NAME=airflow-ec2
AWS_REGION=${AWS_REGION}
EOF
  chmod 600 "${INSTALL_DIR}/.env"
  aws ssm put-parameter \
    --name "${SSM_PASSWORD_PARAM}" \
    --type SecureString \
    --value "${password}" \
    --overwrite \
    --region "${AWS_REGION}"
  echo "[bootstrap] UI password stored in ${SSM_PASSWORD_PARAM}"
}

install_python_requirements() {
  local req="${INSTALL_DIR}/requirements.txt"
  local image="apache/airflow:2.11.2@${AIRFLOW_IMAGE_DIGEST}"
  if [[ ! -f "${req}" ]]; then
    echo "[bootstrap] no requirements.txt — skip pip install"
    return 0
  fi
  echo "[bootstrap] pip install -r requirements.txt into python-packages volume"
  mkdir -p "${INSTALL_DIR}/python-packages"
  docker run --rm \
    -u "50000:0" \
    -v "${INSTALL_DIR}/requirements.txt:/requirements.txt:ro" \
    -v "${INSTALL_DIR}/python-packages:/opt/airflow/python-packages" \
    "${image}" \
    bash -c "pip install --no-cache-dir --no-deps -r /requirements.txt --target /opt/airflow/python-packages"
}

prepull_images() {
  local image="apache/airflow:2.11.2@${AIRFLOW_IMAGE_DIGEST}"
  local attempt=1
  while (( attempt <= 5 )); do
    if docker pull "${image}" && docker pull postgres:13; then
      return 0
    fi
    echo "[bootstrap] docker pull attempt ${attempt} failed; retrying..."
    sleep $(( attempt * 10 ))
    attempt=$(( attempt + 1 ))
  done
  return 1
}

compose_up() {
  local attempt=1
  cd "${INSTALL_DIR}"
  while (( attempt <= 5 )); do
    if docker compose --env-file .env run --rm airflow-init \
      && docker compose --env-file .env up -d; then
      return 0
    fi
    echo "[bootstrap] compose up attempt ${attempt} failed; retrying..."
    sleep $(( attempt * 15 ))
    attempt=$(( attempt + 1 ))
  done
  return 1
}

sync_dags_once() {
  aws s3 sync "s3://${ARTIFACT_BUCKET}/dags/" "${INSTALL_DIR}/dags/" --region "${AWS_REGION}" || true
}

install_systemd_units() {
  cp "${INSTALL_DIR}/airflow-compose.service" /etc/systemd/system/
  cp "${INSTALL_DIR}/airflow-dag-sync.service" /etc/systemd/system/
  cp "${INSTALL_DIR}/airflow-dag-sync.timer" /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now airflow-compose.service
  systemctl enable --now airflow-dag-sync.timer
}

main() {
  install_packages
  pull_compose_package
  local password
  password="$(generate_password)"
  write_env "${password}"
  prepull_images
  install_python_requirements
  sync_dags_once
  compose_up
  install_systemd_units
  echo "[bootstrap] complete $(date -Is)"
}

main "$@"
