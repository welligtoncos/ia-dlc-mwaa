#!/usr/bin/env bash
# scripts/apply.sh — wrapper de terraform apply com retry/backoff simples (NFR OperatorTooling).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
SLEEP_SECONDS="${SLEEP_SECONDS:-15}"

cd "${TF_DIR}"

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  echo "[apply] tentativa ${attempt}/${MAX_ATTEMPTS}"
  if terraform init -input=false && terraform apply -input=false -auto-approve "$@"; then
    echo "[apply] sucesso"
    exit 0
  fi
  if (( attempt == MAX_ATTEMPTS )); then
    echo "[apply] falhou após ${MAX_ATTEMPTS} tentativas" >&2
    exit 1
  fi
  echo "[apply] falha transitória? aguardando ${SLEEP_SECONDS}s..."
  sleep "${SLEEP_SECONDS}"
  SLEEP_SECONDS=$((SLEEP_SECONDS * 2))
  attempt=$((attempt + 1))
done
