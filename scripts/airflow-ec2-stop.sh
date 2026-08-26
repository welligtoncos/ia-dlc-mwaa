#!/usr/bin/env bash
# scripts/airflow-ec2-stop.sh — para a EC2 Airflow (EBS/metadata Postgres sobrevivem).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"
INSTANCE_ID="$(terraform output -raw airflow_ec2_instance_id)"

echo "[airflow-ec2-stop] stopping ${INSTANCE_ID}"
aws ec2 stop-instances --instance-ids "${INSTANCE_ID}" >/dev/null
aws ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}"
echo "[airflow-ec2-stop] stopped — IP público mudará no próximo start"
