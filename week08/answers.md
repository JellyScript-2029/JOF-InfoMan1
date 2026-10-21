# INFOMAN1 — Week 8 Lab Answers

Name: Jhelianne Figuerres
Student ID: 2510465
GitHub repo: https://github.com/JellyScript-2029/JOF-InfoMan1.git
Date submitted: 21 October 2026

**Dataset check:** `SELECT COUNT(*) FROM employee;` returned: **500**

All queries are also collected in `queries.sql`. Full result sets are in `task1_output.txt` to `task4_output.txt` in this folder.

## Task 1 — Pattern Matching Basics

**Approach / explanation:**
I used `LIKE` with `%` for the last-name and first-name searches, since those can have any number of characters before or after the fixed part. For `emp_code`, I used only `_` wildcards because the code is always exactly 5 characters. The `E____` pattern matched all 500 rows, which proves the format, and `E_0__` then found codes with `0` as the third character.

**Code / query used (if applicable):**
```sql
-- 1.1 last name ends in "ez"
SELECT emp_id, first_name, last_name FROM employee WHERE last_name LIKE '%ez';

-- 1.2 first name starts with "Ma"
SELECT emp_id, first_name, department FROM employee WHERE first_name LIKE 'Ma%';

-- 1.3a proof: 5-character codes starting with E
SELECT emp_code FROM employee WHERE emp_code LIKE 'E____';

-- 1.3b third character is 0
SELECT emp_code, first_name, last_name FROM employee WHERE emp_code LIKE 'E_0__';
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Full output in `task1_output.txt`.

| Query | Row count |
|-------|-----------|
| 1.1 `LIKE '%ez'` | 161 rows |
| 1.2 `LIKE 'Ma%'` | 112 rows |
| 1.3a `LIKE 'E____'` | 500 rows (all employees) |
| 1.3b `LIKE 'E_0__'` | 48 rows |

**Reflection question:**
`%` matches zero or more characters, so it can stand in for any amount of text before and after a keyword. `_` matches exactly one character, so `LIKE '_Database_'` would only match titles with exactly one character on each side. Since we don't know how much text surrounds a keyword, `%` is the right choice.

## Task 2 — Basic Aggregation

**Approach / explanation:**
I ran each aggregate over the whole table with no `GROUP BY`, so each query returns a single row. `MIN` and `MAX` were applied directly to the `hire_date` column. For total compensation I wrapped `commission` in `COALESCE(commission, 0)` before adding it to `salary`.

**Code / query used (if applicable):**
```sql
-- 2.1
SELECT COUNT(*) AS total_employees, COUNT(commission) AS with_commission FROM employee;
-- 2.2
SELECT SUM(salary) AS total_payroll FROM employee;
-- 2.3
SELECT ROUND(AVG(salary), 2) AS avg_salary, MIN(hire_date) AS earliest_hire, MAX(hire_date) AS latest_hire FROM employee;
-- 2.4
SELECT SUM(salary + COALESCE(commission, 0)) AS total_compensation FROM employee;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Full output in `task2_output.txt`.

| Query | Result |
|-------|--------|
| 2.1 | total_employees = 500, with_commission = 352 |
| 2.2 | total_payroll = 33,282,250.00 |
| 2.3 | avg_salary = 66,564.50; earliest_hire = 2015-01-03; latest_hire = 2026-09-14 |
| 2.4 | total_compensation = 35,387,750.00 |

**Explanation of the 2.1 gap and 2.4 COALESCE:**
`COUNT(*)` counts every row (500), but `COUNT(commission)` skips NULLs, so it returns only 352. The gap of 148 is the employees in roles with no commission. In 2.4, `salary + NULL` evaluates to NULL, so those 148 employees' salaries would be left out of the sum. `COALESCE(commission, 0)` turns the NULL into 0 so their salary is still counted.

**Reflection question:**
`COUNT(*)` counts all rows in the result, including rows with NULLs. `COUNT(column_name)` counts only the rows where that column is not NULL.

## Task 3 — Grouping Data

**Approach / explanation:**
I used `GROUP BY department` to get per-department headcount, average salary, and distinct job titles. Then I grouped by both `department` and `job_title` to get headcount per combination. Every non-aggregated column in the `SELECT` list appears in the `GROUP BY`.

**Code / query used (if applicable):**
```sql
-- 3.1
SELECT department, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_salary,
       COUNT(DISTINCT job_title) AS distinct_titles
FROM employee
GROUP BY department;

-- 3.2
SELECT department, job_title, COUNT(*) AS headcount
FROM employee
GROUP BY department, job_title;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Full output in `task3_output.txt`.

3.1 (5 rows):

| department | headcount | avg_salary | distinct_titles |
|------------|-----------|------------|-----------------|
| Engineering | 125 | 75160.00 | 3 |
| Finance | 69 | 79513.04 | 3 |
| HR | 50 | 62610.00 | 3 |
| Sales | 144 | 71799.65 | 3 |
| Support | 112 | 44028.57 | 3 |

3.2 returns 15 rows (5 departments × 3 job titles each), with headcounts ranging from 12 (HR Recruiter) to 50 (Sales Account Manager). See `task3_output.txt` for all 15.

**Reflection question:**
After grouping, each group collapses into one output row. A column that is neither grouped nor aggregated can have many different values inside a single group, so the database has no way to know which one to show. Columns must be in the `GROUP BY` (one value per group) or inside an aggregate function (which reduces many values to one).

## Task 4 — Advanced Filtering with HAVING

**Approach / explanation:**
For 4.1, I looked at the Task 3.1 averages (44,028.57 to 79,513.04) and the overall company average from Task 2.3 (66,564.50). I chose **66,564.50 (the company-wide average salary)** as the threshold, so the query shows which departments pay above the company average. HR (62,610.00) and Support (44,028.57) fall below it. For 4.2, `WHERE status = 'Active'` filters rows first, then `GROUP BY` and `HAVING COUNT(*) > 50` filter the groups.

**Code / query used (if applicable):**
```sql
-- 4.1
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 66564.50;

-- 4.2
SELECT department, COUNT(*) AS headcount
FROM employee
WHERE status = 'Active'
GROUP BY department
HAVING COUNT(*) > 50;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Full output in `task4_output.txt`.

4.1 (3 rows):

| department | avg_salary |
|------------|------------|
| Engineering | 75160.00 |
| Finance | 79513.04 |
| Sales | 71799.65 |

4.2 (4 rows):

| department | headcount |
|------------|-----------|
| Engineering | 104 |
| Finance | 52 |
| Sales | 116 |
| Support | 99 |

(HR is excluded because it has only 40 active employees.)

**Why HAVING instead of WHERE:**
- 4.1: The average salary of a department only exists after the rows have been grouped, and `WHERE` runs before grouping, so the condition on `AVG(salary)` must go in `HAVING`.
- 4.2: `WHERE status = 'Active'` correctly filters individual rows, but the condition `COUNT(*) > 50` applies to each group's total, so it has to be in `HAVING`.

**Reflection question:**
`WHERE` filters individual rows before grouping happens, so aggregate values like `AVG(salary)` don't exist yet and can't be used there. `HAVING` runs after `GROUP BY` and filters the groups using their aggregate results.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week08/`
- [x] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)