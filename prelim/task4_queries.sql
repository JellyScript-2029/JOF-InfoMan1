-- Task 4: queries (run these after loading toolshare_sample_data.sql)
USE toolshare_prelim;

-- 1. Names and categories of all the "Power Tools"
SELECT tool_name, category
FROM tool
WHERE category = 'Power Tools';

-- 2. Members who joined after Jan 1, 2025
SELECT member_id, member_name, join_date
FROM member
WHERE join_date > '2025-01-01';

-- 3. Borrowing records still on loan (return_date not filled in yet)
SELECT borrow_id, member_id, tool_id, borrow_date, return_date
FROM borrowing
WHERE return_date IS NULL;

-- 4. All borrowing records for one member
--    (member_id = 1 is Maria Santos in the sample data; change it to try another member)
SELECT borrow_id, member_id, tool_id, borrow_date, return_date
FROM borrowing
WHERE member_id = 1;

-- 5. Tools bought before Jan 1, 2024
SELECT tool_id, tool_name, purchase_date
FROM tool
WHERE purchase_date < '2024-01-01';

/* RESULTS (real output from MySQL, after running task3_ddl.sql and loading toolshare_sample_data.sql)

mysql> SELECT tool_name, category
    -> FROM tool
    -> WHERE category = 'Power Tools';
+----------------+-------------+
| tool_name      | category    |
+----------------+-------------+
| Cordless Drill | Power Tools |
| Circular Saw   | Power Tools |
| Angle Grinder  | Power Tools |
+----------------+-------------+
3 rows in set (0.005 sec)

mysql> SELECT member_id, member_name, join_date
    -> FROM member
    -> WHERE join_date > '2025-01-01';
+-----------+-------------+------------+
| member_id | member_name | join_date  |
+-----------+-------------+------------+
|         2 | Jose Rizal  | 2025-02-10 |
|         3 | Ana Reyes   | 2025-06-01 |
|         5 | Liza Gomez  | 2025-01-15 |
|         6 | Kevin Lim   | 2025-08-05 |
+-----------+-------------+------------+
4 rows in set (0.086 sec)

mysql> SELECT borrow_id, member_id, tool_id, borrow_date, return_date
    -> FROM borrowing
    -> WHERE return_date IS NULL;
+-----------+-----------+---------+-------------+-------------+
| borrow_id | member_id | tool_id | borrow_date | return_date |
+-----------+-----------+---------+-------------+-------------+
|         2 |         1 |       2 | 2025-09-12  | NULL        |
|         3 |         2 |       7 | 2025-09-05  | NULL        |
+-----------+-----------+---------+-------------+-------------+
2 rows in set (0.006 sec)

mysql> SELECT borrow_id, member_id, tool_id, borrow_date, return_date
    -> FROM borrowing
    -> WHERE member_id = 1;
+-----------+-----------+---------+-------------+-------------+
| borrow_id | member_id | tool_id | borrow_date | return_date |
+-----------+-----------+---------+-------------+-------------+
|         1 |         1 |       1 | 2025-09-01  | 2025-09-10  |
|         2 |         1 |       2 | 2025-09-12  | NULL        |
+-----------+-----------+---------+-------------+-------------+
2 rows in set (0.032 sec)

mysql> SELECT tool_id, tool_name, purchase_date
    -> FROM tool
    -> WHERE purchase_date < '2024-01-01';
+---------+----------------+---------------+
| tool_id | tool_name      | purchase_date |
+---------+----------------+---------------+
|       1 | Cordless Drill | 2023-05-10    |
|       2 | Circular Saw   | 2023-08-22    |
|       4 | Garden Shovel  | 2023-12-01    |
+---------+----------------+---------------+
3 rows in set (0.009 sec)

Q1 = 3 rows, Q2 = 4 rows, Q3 = 2 rows, Q4 = 2 rows, Q5 = 3 rows.
*/