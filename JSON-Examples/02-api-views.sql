-- Example 2: Denormalized API View
-- Use Case: Fetching all movie details (main info, cast, genres, tags) in a single round-trip 
-- to the database, formatted exactly as an API expects.

-- This demonstrates JSON aggregation functions: jsonb_build_object and jsonb_agg.

-- 1. Simple aggregation of genres for a movie
SELECT 
    m.title,
    jsonb_agg(g.genre) as genres
FROM movies m
JOIN movie_genres g ON m.id = g.movie_id
WHERE m.id = 603 -- The martix
GROUP BY m.title;

-- 2. Fully denormalized view with nested objects for cast
-- This query constructs a complex JSON structure in one go.

-- simplified example
SELECT 
    jsonb_build_object(
        'movie_id', m.id,
        'title', m.title,
        'year', m.year,
        'director', m.director,
        'cast', (
            SELECT jsonb_agg(jsonb_build_object('actor', actor, 'character', character))
            FROM movie_cast
            WHERE movie_id = m.id
        )
    ) as api_response
FROM movies m
WHERE m.id =  603; -- The martix

-- full json
SELECT 
    jsonb_build_object(
        'movie_id', m.id,
        'title', m.title,
        'year', m.year,
        'director', m.director,
        'stats', jsonb_build_object(
            'rating', m.rating,
            'votes', m.votes,
            'popularity', m.popularity
        ),
        'genres', (
            SELECT jsonb_agg(genre) 
            FROM movie_genres 
            WHERE movie_id = m.id
        ),
        'cast', (
            SELECT jsonb_agg(jsonb_build_object('actor', actor, 'character', character))
            FROM movie_cast
            WHERE movie_id = m.id
        ),
        'tags', (
            SELECT jsonb_agg(tag)
            FROM movie_tags
            WHERE movie_id = m.id
        )
    ) as api_response
FROM movies m
WHERE m.id =  603; -- The martix

-- 3. Creating a view for easier access (optional but helpful for developers)
-- Note: Views don't store data, they just store the query.
CREATE OR REPLACE VIEW movie_api_denormalized AS
SELECT 
    m.id,
    jsonb_build_object(
        'id', m.id,
        'title', m.title,
        'overview', m.overview,
        'metadata', jsonb_build_object(
            'year', m.year,
            'director', m.director,
            'rating', m.rating
        ),
        'genres', COALESCE((SELECT jsonb_agg(genre) FROM movie_genres WHERE movie_id = m.id), '[]'::jsonb),
        'cast', COALESCE((SELECT jsonb_agg(jsonb_build_object('name', actor, 'role', character)) FROM movie_cast WHERE movie_id = m.id), '[]'::jsonb)
    ) as data
FROM movies m;

-- Usage:
-- SELECT data FROM movie_api_denormalized WHERE id = 603;
