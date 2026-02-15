# scripts/import-movies.ps1
$containerName = "postgres"
$importPath = "/import-data/movies.jsonl"

# Check if postgres service is running
$serviceStatus = docker compose ps postgres --format json | ConvertFrom-Json
if ($serviceStatus.State -ne "running") {
    Write-Host "Error: PostgreSQL service is not running." -ForegroundColor Red
    Write-Host "Please run scripts/start-docker.ps1 first." -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Preparing movie_json table..." -ForegroundColor Cyan
docker compose exec -T $containerName psql -U postgres -c "DROP TABLE IF EXISTS movie_json; CREATE TABLE movie_json (data jsonb);"

Write-Host "Step 2: Importing data from $importPath..." -ForegroundColor Cyan
# Using CSV format with a custom delimiter and NO quoting to treat each line as a single record
$sql = @"
CREATE TEMP TABLE temp_import (val text);
COPY temp_import FROM '$importPath' WITH (FORMAT text, DELIMITER E'\x01');

-- Insert only valid JSON records
INSERT INTO movie_json (data) 
SELECT val::jsonb FROM temp_import 
WHERE val IS NOT NULL 
  AND val != '' 
  AND val IS JSON;

-- Report skipped records
SELECT count(*) as skipped_records FROM temp_import 
WHERE NOT (val IS NOT NULL AND val != '' AND val IS JSON);
"@

docker compose exec -T $containerName psql -U postgres -c "$sql"
