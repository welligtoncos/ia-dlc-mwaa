# scripts/airflow-ec2-start.ps1 — inicia a EC2 Airflow
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"

Push-Location $TfDir
try {
    $instanceId = terraform output -raw airflow_ec2_instance_id
    $ssmParam = terraform output -raw airflow_ui_password_ssm_param
}
finally {
    Pop-Location
}

Write-Host "[airflow-ec2-start] starting $instanceId"
aws ec2 start-instances --instance-ids $instanceId | Out-Null
aws ec2 wait instance-running --instance-ids $instanceId

$publicIp = aws ec2 describe-instances --instance-ids $instanceId `
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text

Write-Host "[airflow-ec2-start] running — public IP: $publicIp"
Write-Host "[airflow-ec2-start] UI (após bootstrap ~5–15 min): http://${publicIp}:8080"
Write-Host "[airflow-ec2-start] senha: aws ssm get-parameter --name `"$ssmParam`" --with-decryption --query Parameter.Value --output text"
Write-Host "[airflow-ec2-start] status: .\scripts\airflow-ec2-status.ps1"
