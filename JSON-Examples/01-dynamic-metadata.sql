-- Example 1: Dynamic Metadata Storage
-- Use Case: Storing highly variable data (awards, tech specs, parental ratings) 
-- without modifying the core 'movies' table.

-- 1. Create a sidecar table for metadata
-- We use JSONB for efficient querying and indexing.
CREATE TABLE IF NOT EXISTS movie_metadata (
    movie_id INT PRIMARY KEY REFERENCES movies(id),
    details JSONB
);

-- 2. Insert some sample metadata

-- 2.1 Metadata for 'The Shawshank Redemption' (278)
INSERT INTO movie_metadata (movie_id, details)
VALUES (278, '{
    "awards": [
        {"name": "Academy Award", "category": "Best Picture", "status": "Nominated"},
        {"name": "Academy Award", "category": "Best Actor", "status": "Nominated"},
        {"name": "Golden Globes", "category": "Best Performance by an Actor", "status": "Nominated"}
    ],
    "tech_specs": {
        "aspect_ratio": "1.85 : 1",
        "audio": ["Dolby Digital", "SDDS", "DTS"],
        "runtime_minutes": 142
    },
    "parental_ratings": {
        "US": "R",
        "UK": "15",
        "Germany": "12"
    }
}')
ON CONFLICT (movie_id) DO UPDATE SET details = EXCLUDED.details;

-- 2.2 Metadata for 'The Matrix' (603)
INSERT INTO movie_metadata (movie_id, details)
VALUES (603, '{
    "awards": [
        {"name": "Academy Award", "category": "Best Visual Effects", "status": "Winner"},
        {"name": "Academy Award", "category": "Best Film Editing", "status": "Winner"},
        {"name": "Academy Award", "category": "Best Sound", "status": "Winner"},
        {"name": "Academy Award", "category": "Best Sound Effects Editing", "status": "Winner"}
    ],
    "tech_specs": {
        "aspect_ratio": "2.39 : 1",
        "audio": ["Dolby Digital", "DTS", "SDDS"],
        "runtime_minutes": 136
    },
    "parental_ratings": {
        "US": "R",
        "UK": "15",
        "Germany": "16"
    }
}')
ON CONFLICT (movie_id) DO UPDATE SET details = EXCLUDED.details;

-- 2.3 Metadata for 'The Animatrix' (55931)
INSERT INTO movie_metadata (movie_id, details)
VALUES (55931, '{
    "tech_specs": {
        "aspect_ratio": "1.33 : 1",
        "audio": ["Dolby Digital 5.1"],
        "runtime_minutes": 102
    },
    "parental_ratings": {
        "US": "PG-13",
        "UK": "15",
        "Germany": "16"
    }
}')
ON CONFLICT (movie_id) DO UPDATE SET details = EXCLUDED.details;

-- 3. Querying nested data
-- Find movies with an Academy Award nomination
SELECT m.title, md.details->'awards' as awards
FROM movies m
JOIN movie_metadata md ON m.id = md.movie_id
WHERE md.details @> '{"awards": [{"name": "Academy Award"}]}';

-- 4. Using the JSONB containment operator (@>) to find specific audio support
SELECT m.title
FROM movies m
JOIN movie_metadata md ON m.id = md.movie_id
WHERE md.details->'tech_specs'->'audio' @> '"DTS"';

-- 5. Extracting specific fields with the ->> operator (returns text)
SELECT 
    m.title,
    md.details->'parental_ratings'->>'US' as rating_us
FROM movies m
JOIN movie_metadata md ON m.id = md.movie_id

