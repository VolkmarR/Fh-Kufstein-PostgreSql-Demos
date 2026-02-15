-- Example 4: Search Performance (GIN vs Normalized)
-- Use Case: Comparing search performance for tags/genres between 
-- the normalized relational model and a GIN-indexed JSONB column.

-- 1. Create a GIN index on the raw movie_json data
-- The jsonb_path_ops index is often faster and smaller but supports fewer operators.
-- For general containment (@>), the default jsonb_ops is fine.
CREATE INDEX IF NOT EXISTS idx_movie_json_data_gin ON movie_json USING GIN (data);

-- 2. Performance Test: Searching for 'Action' movies in JSON
-- Note: Use EXPLAIN ANALYZE to see the actual execution time.
EXPLAIN ANALYZE 
SELECT count(*) 
FROM movie_json 
WHERE data @> '{"genres": ["Action"]}';

-- 3. Performance Test: Searching for 'Action' movies in Normalized Relation
-- This uses the movie_genres table which should have a B-tree index on (movie_id, genre).
-- To make it fair, ensure there is an index on just 'genre'.
CREATE INDEX IF NOT EXISTS idx_movie_genres_name ON movie_genres(genre);

EXPLAIN ANALYZE 
SELECT count(*) 
FROM movie_genres 
WHERE genre = 'Action';

-- 4. Deep Search: Actor + Genre
-- Finding movies where Tom Hanks is in an Action movie.

-- JSON Search (using @>):
EXPLAIN ANALYZE
SELECT count(*)
FROM movie_json
WHERE data @> '{"genres": ["Action"], "actors": ["Tom Hanks"]}';

-- Relational Search (using Joins):
EXPLAIN ANALYZE
SELECT count(*)
FROM movies m
JOIN movie_genres g ON m.id = g.movie_id
JOIN movie_cast c ON m.id = c.movie_id
WHERE g.genre = 'Action' AND c.actor = 'Tom Hanks';

/*
  OBSERVATION:
  - For simple searches on a single attribute, the normalized table is often faster.
  - For complex searches involving multiple criteria across different "arrays", 
    the GIN index on JSONB can sometimes outperform joins because it doesn't need to cross-check multiple tables.
  - JSONB indexes are much larger than relational indexes.
*/
