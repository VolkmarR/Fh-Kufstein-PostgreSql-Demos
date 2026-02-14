# Stop Docker Compose and remove containers
$projectRoot = Split-Path -Parent $PSScriptRoot
docker compose -f (Join-Path $projectRoot "docker-compose.yml") down
