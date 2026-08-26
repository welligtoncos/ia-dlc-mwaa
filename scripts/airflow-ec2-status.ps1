# scripts/airflow-ec2-status.ps1
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"

Push-Location $TfDir
try {
    $instanceId = terraform output -raw airflow_ec2_instance_id
    $uiUrl = terraform output -raw airflow_ui_url
    $ssmParam = terraform output -raw airflow_ui_password_ssm_param
}
finally {
    Pop-Location
}

$state = aws ec2 describe-instances --instance-ids $instanceId `
    --query "Reservations[0].Instances[0].State.Name" --output text
$publicIp = aws ec2 describe-instances --instance-ids $instanceId `
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text

Write-Host "instance_id: $instanceId"
Write-Host "state:       $state"
Write-Host "public_ip:   $(if ($publicIp -and $publicIp -ne 'None') { $publicIp } else { 'none' })"
Write-Host "ui_url:      http://${publicIp}:8080 (output terraform: $uiUrl)"

if ($state -eq "running") {
    $ssmStatus = aws ssm describe-instance-information `
        --filters "Key=InstanceIds,Values=$instanceId" `
        --query "InstanceInformationList[0].PingStatus" --output text 2>$null
    if (-not $ssmStatus -or $ssmStatus -eq "None") { $ssmStatus = "Unknown" }
    Write-Host "ssm_ping:    $ssmStatus"

    if ($publicIp -and $publicIp -ne "None") {
        try {
            Invoke-WebRequest -Uri "http://${publicIp}:8080/health" -TimeoutSec 5 -UseBasicParsing | Out-Null
            Write-Host "ui_health:   OK"
        } catch {
            Write-Host "ui_health:   FAIL (bootstrap em curso ou SG/CIDR?)"
        }
    }
} else {
    Write-Host "ssm_ping:    n/a (instance not running)"
    Write-Host "ui_health:   n/a"
}

Write-Host "password:    aws ssm get-parameter --name `"$ssmParam`" --with-decryption --query Parameter.Value --output text"
