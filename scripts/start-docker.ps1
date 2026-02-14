# Start Docker Compose in detached mode
$projectRoot = Split-Path -Parent $PSScriptRoot
docker compose -f (Join-Path $projectRoot "docker-compose.yml") up -d
