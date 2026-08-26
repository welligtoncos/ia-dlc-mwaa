# scripts/airflow-ec2-stop.ps1 — para a EC2 Airflow (EBS/metadata sobrevivem)
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"

Push-Location $TfDir
try {
    $instanceId = terraform output -raw airflow_ec2_instance_id
}
finally {
    Pop-Location
}

Write-Host "[airflow-ec2-stop] stopping $instanceId"
aws ec2 stop-instances --instance-ids $instanceId | Out-Null
aws ec2 wait instance-stopped --instance-ids $instanceId
Write-Host "[airflow-ec2-stop] stopped — IP público mudará no próximo start"
Write-Host "[airflow-ec2-stop] tip: NAT/S3/Glue da stack continuam existindo (custo residual até destroy)"
