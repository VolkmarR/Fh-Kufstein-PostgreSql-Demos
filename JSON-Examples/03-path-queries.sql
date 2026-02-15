-- Example 3: SQL/JSON Path Queries
-- Use Case: Complex filtering on nested structures in the raw 'movie_json' table.
-- This uses the SQL/JSON standard path language supported starting from PostgreSQL 12.

-- 1. Find movies where an actor has 'Hanks' in their name
-- jsonb_path_exists returns true if the path finds any match.
-- The path '$.actors[*] ? (@ like_regex ".*Hanks.*" flag "i")':
-- $       : Root object
-- .actors[*] : Iterate through all elements of the 'actors' array
-- ? (...) : Filter condition
-- @       : Current element
SELECT data->>'title' 
FROM movie_json 
WHERE jsonb_path_exists(data, '$.actors[*] ? (@ like_regex ".*Hanks.*" flag "i")')
LIMIT 10;

-- 2. Extract specific values using jsonb_path_query
-- Get the first character of each movie using path expressions
SELECT 
    data->>'title' as title,
    jsonb_path_query(data, '$.characters[0]') as primary_character
FROM movie_json
WHERE data->>'title' = 'Forrest Gump';

-- 3. Complex logic: Find movies with 'Drama' genre AND budget > 100M
-- using jsonb_path_query_array to return all matching genres
SELECT 
    data->>'title' as title,
    data->>'budget' as budget
FROM movie_json
WHERE jsonb_path_exists(data, '$.genres[*] ? (@ == "Drama")')
  AND (data->>'budget')::bigint > 100000000;

-- 4. Advanced: Use arithmetic and logic in paths
-- Find movies where the rating is greater than 8 and votes > 10000
SELECT data->>'title'
FROM movie_json
WHERE jsonb_path_exists(data, '$ ? (@.rating > 8 && @.votes > 10000)');

