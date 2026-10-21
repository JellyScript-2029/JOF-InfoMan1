# INFOMAN1 — Week 9 Lab Answers

Name: Jhelianne Figuerres
Student ID: 2510465
GitHub repo: https://github.com/JellyScript-2029/JOF-InfoMan1.git
Date submitted: October 21, 2026

## Task 1 — INNER JOIN Basics

**Approach / explanation:**
I joined `students` to `orders` using the shared key `student_id` in an explicit ON clause, so only students with a matching order are returned. I used table aliases (`s`, `o`) and sorted by `order_id`. The result has 3 rows: Ana twice (orders 101 and 102) and Dan once (order 103).

**Code / query used (if applicable):**
```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
ORDER BY o.order_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task1_output.png`

| student_name | program | order_id | order_date |
|---|---|---|---|
| Ana Cruz | BSIT | 101 | 2026-08-10 |
| Ana Cruz | BSIT | 102 | 2026-08-15 |
| Dan Reyes | BSIT | 103 | 2026-08-16 |

**Reflection question:**
An INNER JOIN returns only rows where the ON condition matches on both sides. Ben and Cara have no row in `orders`, so they have no partner row and are dropped. This is not data loss, and it is exactly what a sales report wants, because only actual buyers should appear.

## Task 2 — Finding Missing Relationships

**Approach / explanation:**
For (a), I used a LEFT JOIN from `students` to `orders` so every student is kept, with NULL in the order columns when no order exists. For (b), I added `WHERE o.order_id IS NULL` to keep only the unmatched students. Ben Lim and Cara Yu appear in (b) because neither has any row in `orders`.

**Code / query used (if applicable):**
```sql
-- (a) all students, NULL where no order exists
SELECT s.student_id, s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
ORDER BY s.student_id, o.order_id;

-- (b) only students who never ordered
SELECT s.student_id, s.student_name
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_id IS NULL;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task2a_output.png`, `task2b_output.png`

(a) 5 rows:

| student_id | student_name | order_id | order_date |
|---|---|---|---|
| 1 | Ana Cruz | 101 | 2026-08-10 |
| 1 | Ana Cruz | 102 | 2026-08-15 |
| 2 | Ben Lim | NULL | NULL |
| 3 | Cara Yu | NULL | NULL |
| 4 | Dan Reyes | 103 | 2026-08-16 |

(b) 2 rows: Ben Lim (2) and Cara Yu (3). They appear because they have no matching order.

**Reflection question:**
NULL in the unmatched columns means no matching row exists on the right side. NULL is an unknown, not a value, so `= NULL` evaluates to unknown and never matches. That is why it must be tested with `IS NULL`.

## Task 3 — Four-Table Canteen Report

**Approach / explanation:**
I chained four tables, each with its own ON on a primary key and foreign key pair: students to orders on `student_id`, orders to order_items on `order_id`, and order_items to menu_items on `menu_id`. Columns are qualified with aliases (`s`, `o`, `oi`, `m`), `line_total` is `quantity * price`, and the result is ordered by `order_id` then `item_name`.

**Code / query used (if applicable):**
```sql
SELECT s.student_name, s.program, o.order_id, m.item_name,
       oi.quantity, m.price, oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
ORDER BY o.order_id, m.item_name;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task3_output.png`

| student_name | program | order_id | item_name | quantity | price | line_total |
|---|---|---|---|---|---|---|
| Ana Cruz | BSIT | 101 | Iced Tea | 1 | 30.00 | 30.00 |
| Ana Cruz | BSIT | 101 | Siomai Rice | 2 | 65.00 | 130.00 |
| Ana Cruz | BSIT | 102 | Burger Steak | 1 | 89.00 | 89.00 |
| Dan Reyes | BSIT | 103 | Siomai Rice | 1 | 65.00 | 65.00 |

**Reflection question:**
Each JOIN connects one specific pair of tables through their matching keys, so each one needs its own ON. If two joins share one ON, or one is missing, the rows pair incorrectly, or every row combines with every other row (a Cartesian product), which gives duplicated and wrong results.

## Task 4 — Aliases, Filters, and the Silent Inner Join

**Approach / explanation:**
Version A uses inner joins across all four tables with `WHERE o.order_date >= '2026-08-01'`, sorted newest first. Version B starts from `students LEFT JOIN orders` but puts the same date rule in WHERE. Version A returns 4 rows (line items), and Version B returns only 3 rows, whereas the plain LEFT JOIN had 5. The 2 missing rows are Ben and Cara.

**Code / query used (if applicable):**
```sql
-- Version A: inner joins + WHERE
SELECT s.student_name, o.order_id, o.order_date, m.item_name,
       oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, o.order_id DESC, m.item_name;

-- Version B: LEFT JOIN + WHERE (silent inner join)
SELECT s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;

-- Fix: move the date rule into ON
SELECT s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o
  ON s.student_id = o.student_id
 AND o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, s.student_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task4a_output.png`, `task4b_output.png`, `task4_fix_output.png`

Version A (4 rows): Dan 103 Siomai Rice 65.00; Ana 102 Burger Steak 89.00; Ana 101 Iced Tea 30.00; Ana 101 Siomai Rice 130.00.

Version B (3 rows): Dan 103; Ana 102; Ana 101. Ben and Cara are gone.

Fix (5 rows): Dan 103; Ana 102; Ana 101; Ben NULL; Cara NULL.

**Comparison:** Version A has 4 rows because it is at line-item level. Version B has 3 rows at order level, and 2 fewer than the unfiltered LEFT JOIN (5 rows). The difference comes from WHERE running after the join: Ben and Cara have NULL for `order_date`, and `NULL >= '2026-08-01'` is unknown, so their rows are filtered out. That turns the LEFT JOIN into a silent inner join. **Fix:** move the date rule into the ON clause (or test `OR o.order_date IS NULL`), so students are still preserved.

**Reflection question:**
WHERE is evaluated after the join, so it tests the NULL rows the LEFT JOIN just preserved, and those fail the comparison. Rules about the optional (right) side belong in the ON clause, which only decides how rows pair, so the left-side rows are never removed.

## Task 5 — Reflection

**Approach / explanation:**
I wrote a 150–200 word reflection contrasting INNER JOIN and LEFT JOIN using the Task 1 and Task 2 examples. I described the mistake I actually made in Task 1, running the query before creating the tables (ERROR 1146), along with its symptom and fix. I also mentioned the WHERE-vs-ON problem I saw in Task 4. The full text is saved in `task5_reflection.txt` and pasted below.

**Code / query used (if applicable):**
```sql
-- No new query for this task. See the fix query in Task 4.
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task5_reflection.txt`

> I would use an INNER JOIN for a completed-sales report, like Task 1, where only Ana and Dan should appear because they actually ordered. I would use a LEFT JOIN for a campus roster that must include every student, even non-buyers like Ben and Cara, as in Task 2. The deciding question is whether people with no matching row still belong in the report. The first mistake I actually made was in Task 1. I ran the INNER JOIN and got ERROR 1146, saying the table infoman1_canteen.students did not exist, and SHOW TABLES returned an empty set. I had created the database but never ran the seed script that creates and fills the tables. I fixed it by running the CREATE TABLE and INSERT statements, confirming with SHOW TABLES, and re-running the query, which returned 3 rows. In Task 4, I also saw a right-side WHERE turn my LEFT JOIN into an inner join and drop Ben and Cara, until I moved the date rule into ON. Now I check that the data exists before debugging the join.

**Reflection question:**
For an "all students including non-buyers" roster, I would choose a LEFT JOIN from `students` to `orders`, so non-buyers are kept with NULLs. For a "completed sales only" report, I would choose an INNER JOIN. The single symptom that tells me I picked the wrong one is the row count: if students I expected (like Ben and Cara) are missing from a roster, the join is acting as an inner join. If a sales report shows rows with NULL where an order should be, a LEFT JOIN is being used where an INNER JOIN belongs.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week9/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
