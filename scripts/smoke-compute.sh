#!/usr/bin/env bash
# smoke-compute.sh — invoke Lambda, start Glue job, run ECS Fargate marker task.
# Uso: bash scripts/smoke-compute.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT}/terraform"
MAX_ATTEMPTS=5

retry() {
  local attempt=1
  local backoff=2
  local desc="$1"
  shift
  while true; do
    echo "[smoke] ${desc} (attempt ${attempt}/${MAX_ATTEMPTS})..."
    if "$@"; then
      return 0
    fi
    if (( attempt >= MAX_ATTEMPTS )); then
      echo "[smoke] ERROR: ${desc} failed" >&2
      return 1
    fi
    sleep "${backoff}"
    backoff=$((backoff * 2))
    attempt=$((attempt + 1))
  done
}

need() {
  local name="$1"
  local val
  val="$(cd "${TF_DIR}" && terraform output -raw "${name}" 2>/dev/null || true)"
  if [[ -z "${val}" ]]; then
    echo "ERROR: missing terraform output ${name}. Run terraform apply first." >&2
    exit 1
  fi
  printf '%s' "${val}"
}

LAMBDA="$(need lambda_function_name)"
GLUE_JOB="$(need glue_job_name)"
CLUSTER="$(need ecs_cluster_name)"
TASK_DEF="$(need ecs_task_definition_arn)"
SG="$(need ecs_security_group_id)"
REGION="$(need aws_region)"
SUBNET_CSV="$(cd "${TF_DIR}" && terraform output -json private_subnet_ids | python -c "import sys,json; print(','.join(json.load(sys.stdin)))")"

retry "invoke lambda" aws lambda invoke \
  --region "${REGION}" \
  --function-name "${LAMBDA}" \
  --payload '{"source":"smoke-compute"}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/lambda-smoke-out.json

retry "start glue job" aws glue start-job-run \
  --region "${REGION}" \
  --job-name "${GLUE_JOB}"

retry "run ecs task" aws ecs run-task \
  --region "${REGION}" \
  --cluster "${CLUSTER}" \
  --launch-type FARGATE \
  --task-definition "${TASK_DEF}" \
  --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_CSV}],securityGroups=[${SG}],assignPublicIp=DISABLED}"

echo "[smoke] OK — check S3 lake markers and Glue/ECS console status."
