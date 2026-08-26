# scripts/set-airflow-variables.ps1
# Lê terraform output airflow_variables_map e imprime comandos para colar via SSM na EC2.
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"

Push-Location $TfDir
try {
    $json = terraform output -json airflow_variables_map | ConvertFrom-Json
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== Cole estes comandos via SSM na EC2 (container scheduler/webserver) ===" -ForegroundColor Cyan
Write-Host "# Exemplo SSM:"
Write-Host "#   aws ssm start-session --target <instance_id>"
Write-Host "#   sudo docker exec -it `$(sudo docker ps -qf name=scheduler) bash"
Write-Host ""

$json.PSObject.Properties | ForEach-Object {
    $k = $_.Name
    $v = $_.Value
    if ($null -eq $v) { $v = "" }
    $escaped = [string]$v -replace "'", "'\''"
    Write-Host "airflow variables set $k '$escaped'"
}

Write-Host ""
Write-Host "=== Fim ===" -ForegroundColor Cyan
