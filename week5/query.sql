-- INFOMAN1 - Week 5 Lab Performance Task
-- Student Script for SELECT Queries

USE infoman1_vetclinic;

-- Task 1: Basic SELECT Statements

-- Query 1.1: Select all columns and rows from Pets table
SELECT * FROM Pets;

-- Query 1.2: Select only name and species from Pets table
SELECT name, species FROM Pets;

-- Task 2: Filtering with Equality

-- Query 2: Get name and species of pets that are Dogs
SELECT name, species 
FROM Pets 
WHERE species = 'Dog';

-- Task 3: Filtering with Relational Operators

-- Query 3.1: Get pets older than 2 years old
SELECT * 
FROM Pets 
WHERE age > 2;

-- Query 3.2: Get appointments on or after March 15, 2026
SELECT * 
FROM Appointments 
WHERE appointment_date >= '2026-03-15';

-- Task 4: Combine and Debug

-- Working Query: Get pets where species is 'Cat' using single quotes
SELECT pet_id, name, species, age 
FROM Pets 
WHERE species = 'Cat';

-- Broken Query (Error): Missing single quotes around Cat
-- Result: Error 1054 - Unknown column 'Cat' in 'where clause'
SELECT pet_id, name, species, age 
FROM Pets 
WHERE species = Cat;