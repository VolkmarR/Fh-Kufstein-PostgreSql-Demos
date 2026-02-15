-- Full Text Search Examples for Movies Database

-- 1. Basic Search
-- Find movies mentioning 'space' and 'odyssey'
SELECT title, year, rating 
FROM movies 
WHERE fts @@ to_tsquery('english', 'space & odyssey');

-- 2. Weighted Search (Title has more weight than Overview)
-- Searching for 'batman'
SELECT title, ts_rank(fts, to_tsquery('english', 'batman')) as rank
FROM movies
WHERE fts @@ to_tsquery('english', 'batman')
ORDER BY rank DESC
LIMIT 10;

-- 3. Performance Comparison (Indexed vs. Non-Indexed)

-- Query Using Index (Fast)
SELECT title, year 
FROM movies 
WHERE fts @@ to_tsquery('english', 'space & odyssey');

-- Query Using On-The-Fly Vectorization (Slow)
-- This calculates the tsvector for every row during execution
SELECT title, year 
FROM movies 
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(director, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(overview, '')), 'C')
) @@ to_tsquery('english', 'space & odyssey');

-- 4. User-Friendly Web Search
-- websearch_to_tsquery handles quotes for phrases and minus for exclusion
-- This is much more intuitive for end-users than to_tsquery

-- Find "space odyssey" as a phrase
SELECT title, year 
FROM movies 
WHERE fts @@ websearch_to_tsquery('english', '"space odyssey"');

-- Find movies with "space" but NOT "star" (using Google-style syntax)
SELECT title, year 
FROM movies 
WHERE fts @@ websearch_to_tsquery('english', 'space -star');

-- 5. Deep Search using Materialized View (movies_full_fts)
-- This view includes title, director, overview, genres, tags, and actors.

-- Find movies with 'Tom Hanks' (Actor) and 'Space'
SELECT m.title, m.year, m.director
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'hanks & space')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'hanks & space')) desc;

-- Find movies with 'Action' (Genre) directed by 'Christopher Nolan'
SELECT m.title, m.year, m.rating
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'action & nolan')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'action & nolan')) desc;

-- Find movies tagged with 'dystopia' starring 'Keanu Reeves'
SELECT m.title, m.year
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'dystopia & reeves')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'dystopia & reeves')) desc;
