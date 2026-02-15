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

