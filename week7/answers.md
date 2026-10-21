# INFOMAN1 — Week 7 Lab Answers
 
## Task 1 — Complex Student Roster
 
**Approach / explanation:**
I filtered the `students` table with three conditions joined by AND. `IN` limits the major to Computer Science or Information Technology, `LIKE 'S%'` keeps last names that start with S, and `NOT section = 'Online'` removes students in the Online section. No parentheses were needed because every condition is joined by AND.
 
**Code / query used (if applicable):**
```sql
SELECT first_name, last_name, major
FROM students
WHERE major IN ('Computer Science', 'Information Technology')
AND last_name LIKE 'S%'
AND NOT section = 'Online';
```
 
**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task1_output.png`
+------------+-----------+------------------------+
| first_name | last_name | major                  |
+------------+-----------+------------------------+
| Sofia      | Santos    | Computer Science       |
| Samuel     | Santiago  | Information Technology |
| Sarah      | Sy        | Computer Science       |
| Daniel     | Serrano   | Information Technology |
| Liza       | Soberano  | Computer Science       |
+------------+-----------+------------------------+
 
**Reflection question:**
Why is it often better to use the `IN` operator rather than chaining multiple `OR` conditions when filtering by a specific list of values?
`IN` is shorter and easier to read because the column name is written once and the values are listed in one place. Chained `OR` conditions repeat the column every time, so they get long and are easier to mistype. `IN` also avoids precedence mistakes when the filter is combined with `AND`, and adding or removing a value only means editing the list.
 
---
 
## Task 2 — Formatting Employee Data
 
**Approach / explanation:**
I used `LEFT(first_name, 1)` to get the first initial, then `CONCAT` to join it with a period and space, the last name, and the salary in parentheses. `ROUND(salary)` rounds the salary to a whole number, and the result is aliased as `Instructor Details` (in backticks because of the space). `LIMIT 5` shows only the first five rows.
 
**Code / query used (if applicable):**
```sql
SELECT CONCAT(LEFT(first_name, 1), '. ', last_name, ' ($', ROUND(salary), ')') AS `Instructor Details`
FROM instructors
LIMIT 5;
```
 
**Evidence (screenshot filename, output, or file reference in this folder):**
```
+--------------------+
| Instructor Details |
+--------------------+
| J. Smith ($55001)  |
| M. Santos ($62500) |
| R. Johnson ($49000)|
| A. Reyes ($71250)  |
| P. Cruz ($47001)   |
+--------------------+
```
Note: John Smith's salary is 55000.75, so `ROUND` gives 55001, not the 55000 shown in the lab's example.
 
**Reflection question:**
How do string functions like `CONCAT` affect the performance of a query compared to retrieving raw columns and formatting them in the application layer (e.g., in Java or Python)?
For small tables like this one the difference is negligible. On large tables, formatting in SQL makes the database server do extra work for every row, and it can add load when many users query at once. Formatting in the application layer spreads that work across app servers and keeps the database free for retrieval. SQL formatting is still convenient for quick reports and reduces code in the app, but for heavy workloads it is usually better to return raw columns and format them in the application.
 
---
 
## Task 3 — Project Deadline Analysis
 
**Approach / explanation:**
I used `DATEDIFF(due_date, assigned_date)` to get the number of days between the two dates, with `due_date` first so the result is positive. The result is aliased as `Days_To_Complete`. I repeated the expression in `WHERE` because aliases can't be used there (`WHERE` runs before `SELECT`), and I used the alias in `ORDER BY ... DESC` to sort from longest to shortest.
 
**Code / query used (if applicable):**
```sql
SELECT assignment_name,
       assigned_date,
       due_date,
       DATEDIFF(due_date, assigned_date) AS Days_To_Complete
FROM assignments
WHERE DATEDIFF(due_date, assigned_date) > 14
ORDER BY Days_To_Complete DESC;
```
 
**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task3_output.png`
 
+----------------------+---------------+------------+------------------+
| assignment_name      | assigned_date | due_date   | Days_To_Complete |
+----------------------+---------------+------------+------------------+
| Capstone Proposal    | 2026-09-01    | 2026-10-15 |               44 |
| Midterm Lab Report   | 2026-09-10    | 2026-10-05 |               25 |
| Normalization Case   | 2026-09-01    | 2026-09-22 |               21 |
| SQL Basics Worksheet | 2026-08-05    | 2026-08-25 |               20 |
+----------------------+---------------+------------+------------------+

**Reflection question:**
Why is column aliasing particularly important when using mathematical or date functions in the `SELECT` clause?
Without an alias, the column header is the whole expression, such as `DATEDIFF(due_date, assigned_date)`, which is hard to read in results and reports. An alias gives the column a clear, meaningful name like `Days_To_Complete`. It also lets `ORDER BY` refer to the calculated column by name, and applications can read the column by that name instead of the raw expression.
 
---
 
## Task 4 — Comprehensive Data Audit
 
**Approach / explanation:**
I selected `course_code`, `course_name` and `credits` from `courses`. The `IS NULL` and `BETWEEN 4 AND 6` conditions are joined by OR and wrapped in parentheses, and that group is joined by AND with `course_code LIKE '%ADV%'`. This way every returned course must contain 'ADV' in its code and also have either a missing description or 4 - 6 credits. Results are sorted alphabetically with `ORDER BY course_name`.
 
**Code / query used (if applicable):**
```sql
SELECT course_code, course_name, credits
FROM courses
WHERE (course_description IS NULL OR credits BETWEEN 4 AND 6)
  AND course_code LIKE '%ADV%'
ORDER BY course_name ASC;
```
 
**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task4_output.png`
 
+-------------+----------------------------+---------+
| course_code | course_name                | credits |
+-------------+----------------------------+---------+
| CS-ADV305   | Advanced Algorithms        |       4 |
| CS-ADV400   | Advanced Capstone Project  |       6 |
| CS-ADV101   | Advanced Database Systems  |       5 |
| IT-ADV210   | Advanced Networking        |       3 |
| ENG-ADV110  | Advanced Technical Writing |       2 |
| IT-ADV150   | Advanced Web Development   |       6 |
+-------------+----------------------------+---------+
**Reflection question:**
Explain how MySQL evaluates the expression `A OR B AND C`. How did you use parentheses (if you did) to ensure your query filtered the exact data requested in the instructions?
MySQL evaluates `AND` before `OR`, so `A OR B AND C` is read as `A OR (B AND C)`. In this task, A is `course_description IS NULL`, B is `credits BETWEEN 4 AND 6` and C is `course_code LIKE '%ADV%'`. Without parentheses, any course with a NULL description would be returned even if its code has no 'ADV', for example `CS-101 Introduction to Computing`. I wrote `(A OR B) AND C` so that the 'ADV' condition applies to every row, and only the OR group decides between a missing description or 4 to 6 credits.
 
---
 
## Self-Check
 
- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week7/`
- [x] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)
 