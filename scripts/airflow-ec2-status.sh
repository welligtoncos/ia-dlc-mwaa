#!/usr/bin/env bash
# scripts/airflow-ec2-status.sh — estado EC2, SSM e health HTTP da UI :8080.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"
INSTANCE_ID="$(terraform output -raw airflow_ec2_instance_id)"
UI_URL="$(terraform output -raw airflow_ui_url)"
SSM_PARAM="$(terraform output -raw airflow_ui_password_ssm_param)"

STATE="$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].State.Name' --output text)"
PUBLIC_IP="$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"

echo "instance_id: ${INSTANCE_ID}"
echo "state:       ${STATE}"
echo "public_ip:   ${PUBLIC_IP:-none}"
echo "ui_url:      http://${PUBLIC_IP:-unknown}:8080 (output terraform: ${UI_URL})"

if [[ "${STATE}" == "running" ]]; then
  SSM_STATUS="$(aws ssm describe-instance-information \
    --filters "Key=InstanceIds,Values=${INSTANCE_ID}" \
    --query 'InstanceInformationList[0].PingStatus' --output text 2>/dev/null || echo "Unknown")"
  echo "ssm_ping:    ${SSM_STATUS:-Unknown}"

  if [[ -n "${PUBLIC_IP}" && "${PUBLIC_IP}" != "None" ]]; then
    if curl -sf --max-time 5 "http://${PUBLIC_IP}:8080/health" >/dev/null; then
      echo "ui_health:   OK"
    else
      echo "ui_health:   FAIL (bootstrap ainda em curso ou SG/CIDR?)"
    fi
  fi
else
  echo "ssm_ping:    n/a (instance not running)"
  echo "ui_health:   n/a"
fi

echo "password:    aws ssm get-parameter --name \"${SSM_PARAM}\" --with-decryption --query Parameter.Value --output text"
