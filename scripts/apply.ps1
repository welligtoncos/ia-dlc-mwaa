# scripts/apply.ps1 — terraform apply (PowerShell / Windows)
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"
$MaxAttempts = if ($env:MAX_ATTEMPTS) { [int]$env:MAX_ATTEMPTS } else { 3 }
$SleepSeconds = if ($env:SLEEP_SECONDS) { [int]$env:SLEEP_SECONDS } else { 15 }

Push-Location $TfDir
try {
    $tfvars = Join-Path $TfDir "terraform.tfvars"
    $applyArgs = @("apply", "-input=false", "-auto-approve")
    if (Test-Path $tfvars) {
        $applyArgs += @("-var-file", "terraform.tfvars")
    }
    if ($args.Count -gt 0) {
        $applyArgs += $args
    }

    $attempt = 1
    while ($attempt -le $MaxAttempts) {
        Write-Host "[apply] tentativa $attempt/$MaxAttempts"
        terraform init -input=false | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "terraform init failed" }
        terraform @applyArgs | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[apply] sucesso"
            exit 0
        }
        if ($attempt -eq $MaxAttempts) {
            Write-Error "[apply] falhou após $MaxAttempts tentativas"
            exit 1
        }
        Write-Host "[apply] falha transitória? aguardando ${SleepSeconds}s..."
        Start-Sleep -Seconds $SleepSeconds
        $SleepSeconds *= 2
        $attempt++
    }
}
finally {
    Pop-Location
}
