-- ===========================================================================
-- PostgreSQL Transaction Isolation Examples
-- ===========================================================================
-- This script demonstrates common transaction phenomena and how isolation 
-- levels affect them.
--
-- Prerequisites:
-- To see these phenomena in action, you should open TWO separate connections
-- (sessions) to the database and execute the steps as indicated.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- Setup: Create a shared table for the examples
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS Account;
CREATE TABLE Account (
    Id INT PRIMARY KEY,
    Balance DECIMAL NOT NULL
);

-- Initialize with data
INSERT INTO Account (Id, Balance) VALUES (1, 100), (2, 200);


-- ===========================================================================
-- Phenomenon 1: Non-Repeatable Read
-- ===========================================================================
-- A non-repeatable read occurs when a transaction retrieves the same row twice 
-- and finds that the data within the row has changed between the reads 
-- (because another committed transaction has modified it).
-- ---------------------------------------------------------------------------

-- Session 1: Begin a transaction and read a value
-- (PostgreSQL default is READ COMMITTED)
BEGIN;
SELECT Balance FROM Account WHERE Id = 1; -- Expected: 100

-- Session 2: (Parallel execution) Update the same row and commit
-- BEGIN;
-- UPDATE Account SET Balance = Balance + 50 WHERE Id = 1; 
-- COMMIT;

-- Session 1: Read the same row again
-- In READ COMMITTED, the change is visible. This is a "Non-Repeatable Read".
SELECT Balance FROM Account WHERE Id = 1; -- Result: 150

COMMIT;


-- ===========================================================================
-- Phenomenon 2: Phantom Read
-- ===========================================================================
-- A phantom read occurs when a transaction retrieves a set of rows satisfying 
-- a search condition, and then a second transaction performs an INSERT, 
-- UPDATE, or DELETE that changes the set of rows returned by the first query.
-- ---------------------------------------------------------------------------

-- Reset Data
DELETE FROM Account;
INSERT INTO Account (Id, Balance) VALUES (1, 100), (2, 200);

-- Session 1: Count accounts with balance >= 100
BEGIN;
SELECT COUNT(*) FROM Account WHERE Balance >= 100; -- Expected: 2 (Id 1 and 2)

-- Session 2: (Parallel execution) Modify an account so it no longer matches
-- BEGIN;
-- UPDATE Account SET Balance = Balance - 50 WHERE Id = 1; 
-- COMMIT;

-- Session 1: Repeat the count
-- In READ COMMITTED, the count changes. This is a "Phantom Read".
SELECT COUNT(*) FROM Account WHERE Balance >= 100; -- Result: 1

COMMIT;


-- ===========================================================================
-- Solution: Using REPEATABLE READ
-- ===========================================================================
-- The REPEATABLE READ isolation level ensures that if you read data twice 
-- in the same transaction, you get the same result even if other 
-- transactions commit changes.
-- ---------------------------------------------------------------------------

-- Reset Data
DELETE FROM Account;
INSERT INTO Account (Id, Balance) VALUES (1, 100), (2, 200);

-- Session 1: Start with REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM Account WHERE Balance >= 100; -- Expected: 2

-- Session 2: (Parallel execution) Change data and commit
-- BEGIN;
-- UPDATE Account SET Balance = Balance - 50 WHERE Id = 1; 
-- COMMIT;

-- Session 1: Repeat the count
-- In REPEATABLE READ, the transaction sees a snapshot from its start.
SELECT COUNT(*) FROM Account WHERE Balance >= 100; -- Still: 2!

-- Note: If Session 1 tried to UPDATE Id = 1 now, it would get a 
-- "could not serialize access due to concurrent update" error.
COMMIT;
