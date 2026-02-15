-- Advanced Full Text Search using Materialized Views
-- This set of examples demonstrates searching across multiple related tables.

-- 1. Deep Search using Materialized View (movies_full_fts)
-- This view includes title, director, overview, genres, tags, and actors.

-- Find movies with 'Tom Hanks' (Actor) and 'Space'
SELECT m.title, m.year, m.director
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'hanks & space')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'hanks & space')) DESC;

-- Find movies with 'Action' (Genre) directed by 'Christopher Nolan'
SELECT m.title, m.year, m.rating
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'action & nolan')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'action & nolan')) DESC;

-- Find movies tagged with 'dystopia' starring 'Keanu Reeves'
SELECT m.title, m.year
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'dystopia & reeves')
ORDER BY ts_rank(f.fts, to_tsquery('english', 'dystopia & reeves')) DESC;

-- 2. Combined Search with Filters
-- Search for 'matrix' movies released between 1995 and 2005
SELECT m.title, m.year, m.rating
FROM movies m
JOIN movies_full_fts f ON m.id = f.id
WHERE f.fts @@ to_tsquery('english', 'matrix')
  AND m.year BETWEEN 1995 AND 2005
ORDER BY ts_rank(f.fts, to_tsquery('english', 'matrix')) DESC, m.rating DESC;
