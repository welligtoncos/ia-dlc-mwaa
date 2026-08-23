#!/usr/bin/env bash
# seed-sample.sh — upload CSV de exemplo para raw/dt=YYYY-MM-DD/ (Hive-style).
# Uso: bash scripts/seed-sample.sh [bucket-name]
# Se bucket omitido, lê terraform output data_lake_bucket_name.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAMPLE="${ROOT}/samples/orders_sample.csv"
MAX_ATTEMPTS=5
BACKOFF=2

BUCKET="${1:-}"
if [[ -z "${BUCKET}" ]]; then
  if [[ -d "${ROOT}/terraform" ]]; then
    BUCKET="$(cd "${ROOT}/terraform" && terraform output -raw data_lake_bucket_name 2>/dev/null || true)"
  fi
fi

if [[ -z "${BUCKET}" ]]; then
  echo "ERROR: informe o bucket ou rode terraform apply e tenha output data_lake_bucket_name." >&2
  exit 1
fi

if [[ ! -f "${SAMPLE}" ]]; then
  echo "ERROR: sample não encontrado: ${SAMPLE}" >&2
  exit 1
fi

DT="$(date -u +%Y-%m-%d)"
KEY="raw/dt=${DT}/orders_sample.csv"

attempt=1
while true; do
  echo "Uploading s3://${BUCKET}/${KEY} (attempt ${attempt}/${MAX_ATTEMPTS})..."
  if aws s3 cp "${SAMPLE}" "s3://${BUCKET}/${KEY}"; then
    echo "OK: s3://${BUCKET}/${KEY}"
    echo "Próximo: aws glue start-crawler --name \$(terraform -chdir=terraform output -raw raw_crawler_name)"
    exit 0
  fi
  if (( attempt >= MAX_ATTEMPTS )); then
    echo "ERROR: falha após ${MAX_ATTEMPTS} tentativas." >&2
    exit 1
  fi
  sleep "${BACKOFF}"
  BACKOFF=$((BACKOFF * 2))
  attempt=$((attempt + 1))
done
