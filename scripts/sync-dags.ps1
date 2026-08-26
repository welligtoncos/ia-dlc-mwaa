# scripts/sync-dags.ps1
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$TfDir = Join-Path $RootDir "terraform"
$MaxAttempts = if ($env:MAX_ATTEMPTS) { [int]$env:MAX_ATTEMPTS } else { 3 }
$SleepSeconds = if ($env:SLEEP_SECONDS) { [int]$env:SLEEP_SECONDS } else { 5 }

Push-Location $TfDir
try {
    $bucket = terraform output -raw artifact_bucket_name
}
finally {
    Pop-Location
}

$attempt = 1
while ($attempt -le $MaxAttempts) {
    Write-Host "[sync] tentativa $attempt/$MaxAttempts -> s3://$bucket"
    try {
        aws s3 sync (Join-Path $RootDir "dags/") "s3://$bucket/dags/" --delete
        $req = Join-Path $RootDir "requirements.txt"
        if (Test-Path $req) {
            aws s3 cp $req "s3://$bucket/requirements.txt"
        }
        $plugins = Join-Path $RootDir "plugins"
        if (Test-Path $plugins) {
            aws s3 sync $plugins "s3://$bucket/plugins/"
        }
        Write-Host "[sync] ok"
        exit 0
    } catch {
        if ($attempt -eq $MaxAttempts) {
            Write-Error "[sync] falhou"
            exit 1
        }
        Start-Sleep -Seconds $SleepSeconds
        $SleepSeconds *= 2
        $attempt++
    }
}
