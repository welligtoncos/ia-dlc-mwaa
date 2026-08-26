#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

export ARTIFACT_BUCKET="${artifact_bucket}"
export AWS_REGION="${aws_region}"
export SSM_PASSWORD_PARAM="${ssm_password_param}"
export AIRFLOW_IMAGE_DIGEST="${airflow_image_digest}"

dnf install -y aws-cli jq openssl

mkdir -p /opt/airflow-ec2
aws s3 sync "s3://${artifact_bucket}/airflow-ec2/" /opt/airflow-ec2/ --region "${aws_region}"
# Strip CRLF if objects were uploaded from Windows (avoids `bash\r` on first boot).
for f in /opt/airflow-ec2/*.sh /opt/airflow-ec2/*.service /opt/airflow-ec2/*.timer; do
  [ -f "$f" ] && sed -i 's/\r$//' "$f"
done
chmod +x /opt/airflow-ec2/bootstrap.sh

cat > /etc/airflow-ec2.env <<EOF
ARTIFACT_BUCKET=${artifact_bucket}
AWS_REGION=${aws_region}
SSM_PASSWORD_PARAM=${ssm_password_param}
AIRFLOW_IMAGE_DIGEST=${airflow_image_digest}
EOF
chmod 600 /etc/airflow-ec2.env

/opt/airflow-ec2/bootstrap.sh
