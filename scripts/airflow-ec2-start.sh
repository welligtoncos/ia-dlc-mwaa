#!/usr/bin/env bash
# scripts/airflow-ec2-start.sh — inicia a EC2 Airflow (custo: ~US$ 1–2/dia enquanto running).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"
INSTANCE_ID="$(terraform output -raw airflow_ec2_instance_id)"

echo "[airflow-ec2-start] starting ${INSTANCE_ID}"
aws ec2 start-instances --instance-ids "${INSTANCE_ID}" >/dev/null
aws ec2 wait instance-running --instance-ids "${INSTANCE_ID}"

PUBLIC_IP="$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"

echo "[airflow-ec2-start] running — public IP: ${PUBLIC_IP}"
echo "[airflow-ec2-start] UI (após bootstrap ~5–10 min): http://${PUBLIC_IP}:8080"
echo "[airflow-ec2-start] senha: aws ssm get-parameter --name \"$(terraform output -raw airflow_ui_password_ssm_param)\" --with-decryption --query Parameter.Value --output text"
