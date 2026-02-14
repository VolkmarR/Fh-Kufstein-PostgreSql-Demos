# Start Harlequin in Docker
$projectRoot = Split-Path -Parent $PSScriptRoot
$dockerfileDir = Join-Path $projectRoot "harlequin"

# Build the image
docker build -t harlequin-local $dockerfileDir

# Run the container
# Connects to host.docker.internal to access the Postgres instance exposed on the host
Write-Host "Starting Harlequin..."
Write-Host "Connecting to Postgres at host.docker.internal:6543..."

# Default connection string for the local setup
$connectionString = "postgres://postgres:postgres@host.docker.internal:6543/postgres"

# Pass any additional arguments to the container
docker run -it --rm --add-host=host.docker.internal:host-gateway harlequin-local -a postgres $connectionString $args
