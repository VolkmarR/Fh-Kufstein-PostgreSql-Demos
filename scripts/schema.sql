-- Consolidated Movies Data Pipeline SQL

-- 1. Cleanup and Recreate Raw Table
DROP TABLE IF EXISTS movie_json CASCADE;
CREATE TABLE movie_json (data jsonb);

-- 2. Import Raw JSONL Data
-- Using a temporary table for safer import and validation
CREATE TEMP TABLE temp_import (val text);
COPY temp_import FROM '/import-data/movies.jsonl' WITH (FORMAT text, DELIMITER E'\x01');

INSERT INTO movie_json (data) 
SELECT val::jsonb 
FROM temp_import 
WHERE val IS NOT NULL 
  AND val != '' 
  AND val IS JSON;

-- 3. Cleanup and Recreate Relational Tables
DROP TABLE IF EXISTS movie_cast CASCADE;
DROP TABLE IF EXISTS movie_genres CASCADE;
DROP TABLE IF EXISTS movie_tags CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP VIEW IF EXISTS movie_search CASCADE;
DROP MATERIALIZED VIEW IF EXISTS movies_full_fts CASCADE;

CREATE TABLE movies (
    id INT PRIMARY KEY,
    title TEXT NOT NULL,
    overview TEXT,
    director TEXT,
    year INTEGER,
    votes INTEGER,
    rating NUMERIC,
    popularity NUMERIC,
    budget BIGINT,
    url TEXT,
    fts tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(director, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(overview, '')), 'C')
    ) STORED
);

CREATE INDEX idx_movies_fts ON movies USING GIN (fts);

CREATE TABLE movie_genres (
    movie_id INT REFERENCES movies(id),
    genre TEXT NOT NULL,
    PRIMARY KEY (movie_id, genre)
);

CREATE TABLE movie_tags (
    movie_id INT REFERENCES movies(id),
    tag TEXT NOT NULL,
    PRIMARY KEY (movie_id, tag)
);

CREATE TABLE movie_cast (
    movie_id INT REFERENCES movies(id),
    actor TEXT NOT NULL,
    character TEXT NOT NULL,
    PRIMARY KEY (movie_id, actor, character)
);

-- 4. Transform and Insert Data
INSERT INTO movies (id, title, overview, director, year, votes, rating, popularity, budget, url)
SELECT 
    (data->>'id')::INTEGER,
    data->>'title',
    data->>'overview',
    data->>'director',
    (data->>'year')::INTEGER,
    (data->>'votes')::INTEGER,
    (data->>'rating')::NUMERIC,
    (data->>'popularity')::NUMERIC,
    (data->>'budget')::BIGINT,
    data->>'url'
FROM movie_json;

INSERT INTO movie_genres (movie_id, genre)
SELECT 
    (data->>'id')::INTEGER,
    genre
FROM movie_json,
     jsonb_array_elements_text(data->'genres') AS genre;

INSERT INTO movie_tags (movie_id, tag)
SELECT 
    (data->>'id')::INTEGER,
    tag
FROM movie_json,
     jsonb_array_elements_text(data->'tags') AS tag;

INSERT INTO movie_cast (movie_id, actor, character)
SELECT 
    (data->>'id')::INTEGER,
    actor,
    COALESCE(data->'characters'->>(ordinality::int-1), 'Unknown')
FROM movie_json,
     jsonb_array_elements_text(data->'actors') WITH ORDINALITY AS actor;

-- 5. Relational Search Materialized View
-- Aggregates genres, tags, and cast for deep searching across relations.
CREATE MATERIALIZED VIEW movies_full_fts AS
SELECT 
    m.id,
    m.fts ||
    setweight(to_tsvector('english', coalesce(string_agg(DISTINCT g.genre, ' '), '')), 'A') ||
    setweight(to_tsvector('english', coalesce(string_agg(DISTINCT t.tag, ' '), '')), 'B') ||
    setweight(to_tsvector('english', coalesce(string_agg(DISTINCT c.actor, ' '), '')), 'C') as fts
FROM movies m
LEFT JOIN movie_genres g ON m.id = g.movie_id
LEFT JOIN movie_tags t ON m.id = t.movie_id
LEFT JOIN movie_cast c ON m.id = c.movie_id
GROUP BY m.id;

CREATE INDEX idx_movies_full_fts ON movies_full_fts USING GIN (fts);
