#!/usr/bin/env bash
# scripts/set-airflow-variables.sh — imprime airflow variables set a partir do TF output.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

MAP_JSON="$(terraform -chdir="${TF_DIR}" output -json airflow_variables_map)"

echo ""
echo "=== Cole estes comandos via SSM na EC2 (container scheduler/webserver) ==="
echo "# Exemplo: sudo docker exec -it \$(sudo docker ps -qf name=scheduler) bash"
echo ""

if command -v jq >/dev/null 2>&1; then
  echo "${MAP_JSON}" | jq -r 'to_entries[] | "airflow variables set \(.key) '\''\(.value // "")'\''"'
else
  python -c 'import json,sys
data=json.load(sys.stdin)
for k,v in data.items():
    val="" if v is None else str(v).replace("'\'\'","'\''\\'\'''\''")
    print("airflow variables set %s '\''%s'\''" % (k, val))
' <<<"${MAP_JSON}"
fi

echo ""
echo "=== Fim ==="
