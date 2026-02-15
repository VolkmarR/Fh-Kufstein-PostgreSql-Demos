-- Example 5: Efficient Updates with jsonb_set
-- Use Case: Updating a single field deep inside a JSON document 
-- without overwriting the whole blob.

-- 1. Adding a new field to a JSONB object
-- We'll add 'streaming_platforms' to the metadata for Shawshank Redemption.
Select details->'streaming_platforms' as streaming_platforms from  movie_metadata 
WHERE movie_id = 278;

UPDATE movie_metadata 
SET details = jsonb_set(details, '{streaming_platforms}', '["Netflix", "HBO Max", "Amazon Prime"]', true) 
WHERE movie_id = 278;

-- 2. Updating a nested value
-- Change the runtime in the tech_specs object.
Select details->'tech_specs'->'runtime_minutes' as runtime_minutes from  movie_metadata 
WHERE movie_id = 278;

UPDATE movie_metadata 
SET details = jsonb_set(details, '{tech_specs, runtime_minutes}', '144') 
WHERE movie_id = 278;

-- 3. Appending to an array
-- Add a new audio format to the audio array inside tech_specs.
-- We use || to concatenate arrays.
Select details->'tech_specs'->'audio' as audio from  movie_metadata 
WHERE movie_id = 278;

UPDATE movie_metadata 
SET details = jsonb_set(
    details, 
    '{tech_specs, audio}', 
    (details->'tech_specs'->'audio') || '["Auro 3D"]'::jsonb
) 
WHERE movie_id = 278;

-- 4. Deleting a field
-- Use the - operator to remove a key.
Select details->'parental_ratings' as parental_ratings from  movie_metadata 
WHERE movie_id = 278;

UPDATE movie_metadata 
SET details = details #- '{parental_ratings, Germany}'
WHERE movie_id = 278;

/*
  NOTE:
  - jsonb_set(target, path, new_value, create_if_missing)
  - #- : delete path
  - - : delete key or array index
  - || : concatenate objects or arrays
*/
