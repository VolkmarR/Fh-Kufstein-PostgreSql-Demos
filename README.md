# PostgreSQL Advanced Features: JSONB and Full Text Search

This repository contains examples and scripts for exploring advanced PostgreSQL features, specifically focusing on JSONB (binary JSON) and Full Text Search (FTS). The project utilizes the [Metarank Movie Search Ranking Dataset (MSRD)](https://github.com/metarank/msrd) to demonstrate these capabilities in a practical scenario.

## Getting Started

### Prerequisites
- Docker and Docker Compose
- PowerShell (for running the helper scripts)

### Installation and Setup

1.  **Initialize Database**:
    Execute the script to start the PostgreSQL container:
    ```powershell
    ./scripts/start-docker.ps1
    ```
    The database instance is accessible on port `6543` with the default credentials:
    - Username: `postgres`
    - Password: `postgres`

2.  **Import Data**:
    Run the import pipeline to initialize the schema, import the raw JSONL data, and perform the transformation into relational tables:
    ```powershell
    ./scripts/import-movies.ps1
    ```

3.  **Data Exploration**:
    The database can be accessed using any standard SQL client or the included Harlequin SQL IDE:
    ```powershell
    ./scripts/start-harlequin.ps1
    ```

---

## Project Structure

### Scripts (`/scripts`)
- `start-docker.ps1`: Initializes the PostgreSQL 18 container.
- `stop-docker.ps1`: Stops and removes the active container.
- `cleanup-environment.ps1`: Stops containers and deletes all local database data (volumes).
- `schema.sql`: Contains the primary database schema definition, including tables for movies, cast, genres, and FTS configurations.
- `import-movies.ps1`: Orchestrates the data import process from the `movies.jsonl` source.
- `start-harlequin.ps1`: Launches the Harlequin terminal-based SQL IDE via Docker.

### JSON Examples (`/JSON-Examples`)
These examples demonstrate the management of semi-structured data using the `JSONB` data type:

- **`01-dynamic-metadata.sql`**: Demonstrates the use of sidecar tables for variable metadata and querying nested objects using containment operators.
- **`02-api-views.sql`**: Illustrates the creation of views that aggregate relational data into JSON objects for API integration.
- **`03-path-queries.sql`**: Explores the use of `jsonb_path_query` and SQL/JSON path expressions for complex filtering.
- **`04-performance.sql`**: Compares query execution times between standard JSONB columns and those optimized with GIN (Generalized Inverted Index) indexes.
- **`05-updates.sql`**: Shows methods for performing partial updates on JSON documents.

### Full Text Search (`/FTS-Examples`)
These examples illustrate PostgreSQL's robust search capabilities:

- **`01-search-examples.sql`**: Covers core FTS concepts including basic search (`@@` operator), weighted ranking (Title vs. Overview), and user-friendly web-style searching.
- **`02-advanced-search.sql`**: Demonstrates deep search capabilities using materialized views to aggregate and search across multiple related tables (actors, genres, tags).

---

## Data Model

The project implements a hybrid data model:

1.  **Relational**: Structured tables for core entities including `movies`, `movie_genres`, `movie_tags`, and `movie_cast`.
2.  **Document-based**: A `movie_metadata` table for managing variable, nested attributes.
3.  **Search-optimized**: Pre-computed `tsvector` columns and materialized views for efficient multi-table searching.

## Technical Stack
- **PostgreSQL 18**: Database engine.
- **Harlequin**: Terminal-based SQL IDE.
- **Docker**: Container orchestration.
