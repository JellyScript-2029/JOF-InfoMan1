# INFOMAN1 — Week 5 Reflection

## DQL vs DDL and DML Safety
SELECT statements are part of Data Query Language (DQL). They are safe to run anytime because they only read and display data from the database. Running a SELECT query won't change, delete, or overwrite any information stored in the tables. On the other hand, DDL commands (like CREATE or DROP) alter the database structure, and DML commands (like INSERT, UPDATE, or DELETE) modify actual data records. Running DDL or DML by mistake can break tables or permanently lose data.

## Task 4 Debugging Experience
In Task 4, my working query was SELECT pet_id, name, species, age FROM Pets WHERE species = 'Cat';, which correctly returned all cat records. For the broken query, I removed the single quotes around Cat (WHERE species = Cat). When I executed it, MySQL gave me Error 1054: Unknown column 'Cat' in 'where clause'. This happened because MySQL treated Cat as a column name instead of a string. Adding single quotes back fixed the issue immediately.