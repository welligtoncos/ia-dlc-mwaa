#!/usr/bin/env bash
# scripts/sync-dags.sh — publica dags/ e requirements.txt no bucket de artefatos (fora do Terraform).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
SLEEP_SECONDS="${SLEEP_SECONDS:-5}"

cd "${TF_DIR}"
BUCKET="$(terraform output -raw artifact_bucket_name)"

sync_once() {
  aws s3 sync "${ROOT_DIR}/dags/" "s3://${BUCKET}/dags/" --delete
  if [[ -f "${ROOT_DIR}/requirements.txt" ]]; then
    aws s3 cp "${ROOT_DIR}/requirements.txt" "s3://${BUCKET}/requirements.txt"
  fi
  # plugins opcional
  if [[ -d "${ROOT_DIR}/plugins" ]]; then
    aws s3 sync "${ROOT_DIR}/plugins/" "s3://${BUCKET}/plugins/"
  fi
}

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  echo "[sync] tentativa ${attempt}/${MAX_ATTEMPTS} -> s3://${BUCKET}"
  if sync_once; then
    echo "[sync] ok"
    exit 0
  fi
  if (( attempt == MAX_ATTEMPTS )); then
    echo "[sync] falhou" >&2
    exit 1
  fi
  sleep "${SLEEP_SECONDS}"
  SLEEP_SECONDS=$((SLEEP_SECONDS * 2))
  attempt=$((attempt + 1))
done
