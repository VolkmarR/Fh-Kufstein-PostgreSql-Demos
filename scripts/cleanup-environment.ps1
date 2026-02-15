# scripts/cleanup-environment.ps1
$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptDir
$PgDataPath = Join-Path $ProjectRoot ".docker\pgdata"

Write-Host "Stopping and removing containers..." -ForegroundColor Cyan
Push-Location $ProjectRoot
docker compose down
Pop-Location

if (Test-Path $PgDataPath) {
    Write-Host "Removing database volume data ($PgDataPath)..." -ForegroundColor Yellow
    Remove-Item -Path $PgDataPath -Recurse -Force
}

Write-Host "Cleanup completed successfully." -ForegroundColor Green
