# scripts/import-movies.ps1
$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptDir
$SchemaPath = Join-Path $ScriptDir "schema.sql"

# Change to project root to ensure docker compose finds the configuration
Push-Location $ProjectRoot

try {
  # Check if postgres service is running
  $serviceStatus = docker compose ps postgres --format json | ConvertFrom-Json
  if ($serviceStatus.State -ne "running") {
    Write-Host "Error: PostgreSQL service is not running." -ForegroundColor Red
    Write-Host "Please run scripts/start-docker.ps1 first." -ForegroundColor Yellow
    exit 1
  }

  Write-Host "Starting movies data import and transformation pipeline..." -ForegroundColor Cyan

  if (Test-Path $SchemaPath) {
    Get-Content $SchemaPath -Raw | docker compose exec -T postgres psql -U postgres
  }
  else {
    Write-Host "Error: $SchemaPath not found!" -ForegroundColor Red
    exit 1
  }

  Write-Host "Pipeline completed successfully." -ForegroundColor Green
}
finally {
  Pop-Location
}
