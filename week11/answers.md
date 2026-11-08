# INFOMAN1 — Week 11 Lab Answers

Name: Jhelianne Figuerres
Student ID: 2510465
GitHub repo: https://github.com/JellyScript-2029/JOF-InfoMan1
Date submitted: November 8, 2026

## Task 1 — Diagnose the Anomalies

**Approach / explanation:**
I used only SELECT queries on student_enrollment. For the update anomaly, the query showed 3 rows carrying D01, so renaming Computing Studies has to touch all 3 rows, and one missed row leaves two names for one department (cause: department_name is repeated on every enrollment row). For the insert anomaly, the query for IT103 returned an empty set, and the only way to fit the course in is a row with NULL student_id and grade or an invented placeholder student (cause: course facts are stored inside an enrollment row, so a course needs a student to exist). For the delete anomaly, IT102 appears in only 1 row, so removing Ana's IT102 row erases Web Development and its department link (cause: the only copy of the course facts sits inside one student-specific row).

**Code / query used (if applicable):**
```sql
-- (a) update anomaly
SELECT dept_id, department_name, COUNT(*) AS rows_to_change
FROM student_enrollment
WHERE dept_id = 'D01'
GROUP BY dept_id, department_name;

-- (b) insert anomaly
SELECT * FROM student_enrollment WHERE course_id = 'IT103';

SELECT NULL AS student_id, 'NO STUDENT (placeholder)' AS student_name,
       NULL AS enrolled_courses, 'IT103' AS course_id,
       'Intro to Networks' AS course_title, 'D01' AS dept_id,
       'Computing Studies' AS department_name, NULL AS grade;

-- (c) delete anomaly
SELECT course_id, course_title, dept_id, department_name, COUNT(*) AS rows_with_this_course
FROM student_enrollment
WHERE course_id = 'IT102'
GROUP BY course_id, course_title, dept_id, department_name;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task1_output.png`

```
+---------+-------------------+----------------+
| dept_id | department_name   | rows_to_change |
+---------+-------------------+----------------+
| D01     | Computing Studies |              3 |
+---------+-------------------+----------------+

SELECT * FROM student_enrollment WHERE course_id = 'IT103';
Empty set

+------------+--------------------------+------------------+-----------+-------------------+---------+-------------------+-------+
| student_id | student_name             | enrolled_courses | course_id | course_title      | dept_id | department_name   | grade |
+------------+--------------------------+------------------+-----------+-------------------+---------+-------------------+-------+
|       NULL | NO STUDENT (placeholder) |             NULL | IT103     | Intro to Networks | D01     | Computing Studies |  NULL |
+------------+--------------------------+------------------+-----------+-------------------+---------+-------------------+-------+

+-----------+-----------------+---------+-------------------+-----------------------+
| course_id | course_title    | dept_id | department_name   | rows_with_this_course |
+-----------+-----------------+---------+-------------------+-----------------------+
| IT102     | Web Development | D01     | Computing Studies |                     1 |
+-----------+-----------------+---------+-------------------+-----------------------+
```

**Reflection question:**
The insert anomaly surprised me most, because a valid course like IT103 could not be stored without a student (or a fake placeholder). All three anomalies come from one structural fact: student, course, and department facts are all stored together in one wide table.

## Task 2 — Reach First Normal Form

**Approach / explanation:**
I removed the enrolled_courses column and built enrollment_1nf with one row per student-course pair (3 rows). I added a composite primary key (student_id, course_id) so every row has a stable identity. The SELECT output shows one value per cell, and the check for commas returned 0. 1NF deliberately leaves redundancy behind: Ana Cruz's name repeats, Database Systems repeats, and Computing Studies repeats on every row, which Tasks 3 and 4 remove.

**Code / query used (if applicable):**
```sql
CREATE TABLE enrollment_1nf (
    student_id      INT,
    student_name    VARCHAR(100),
    course_id       VARCHAR(10),
    course_title    VARCHAR(100),
    dept_id         VARCHAR(10),
    department_name VARCHAR(100),
    grade           DECIMAL(4,2),
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollment_1nf
SELECT student_id, student_name, course_id, course_title,
       dept_id, department_name, grade
FROM student_enrollment;

SELECT * FROM enrollment_1nf;

SELECT COUNT(*) AS cells_with_lists
FROM enrollment_1nf
WHERE course_id LIKE '%,%' OR student_name LIKE '%,%';
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task2_output.png`

```
+------------+--------------+-----------+------------------+---------+-------------------+-------+
| student_id | student_name | course_id | course_title     | dept_id | department_name   | grade |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
|        101 | Ana Cruz     | IT101     | Database Systems | D01     | Computing Studies |  1.50 |
|        101 | Ana Cruz     | IT102     | Web Development  | D01     | Computing Studies |  1.25 |
|        102 | Ben Lim      | IT101     | Database Systems | D01     | Computing Studies |  1.75 |
+------------+--------------+-----------+------------------+---------+-------------------+-------+

+------------------+
| cells_with_lists |
+------------------+
|                0 |
+------------------+
```

**Reflection question:**
Names still repeat (Ana Cruz appears twice) because 1NF only fixes atomic values and row identity, not dependencies. student_name depends on only part of the key (student_id), which is a partial dependency, and Second Normal Form (2NF) removes that next.

## Task 3 — Reach Second Normal Form

**Approach / explanation:**
The composite key is (student_id, course_id). Dependencies I observed: student_id → student_name (partial); course_id → course_title, dept_id (partial); dept_id → department_name (transitive, handled in Task 4); (student_id, course_id) → grade (full key). I split the partial dependencies into students (2 rows) and courses_stage (2 rows), and kept enrollments (3 rows) with the full key plus grade. The join across the three tables returned all 3 original rows, so the wide report still reconstructs. Grade stays with the full key because it describes one student in one specific course.

**Code / query used (if applicable):**
```sql
CREATE TABLE students (
    student_id   INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses_stage (
    course_id       VARCHAR(10) PRIMARY KEY,
    course_title    VARCHAR(100) NOT NULL,
    dept_id         VARCHAR(10),
    department_name VARCHAR(100)
);

CREATE TABLE enrollments (
    student_id INT,
    course_id  VARCHAR(10),
    grade      DECIMAL(4,2),
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)  REFERENCES courses_stage(course_id)
);

INSERT INTO students
SELECT DISTINCT student_id, student_name FROM enrollment_1nf;

INSERT INTO courses_stage
SELECT DISTINCT course_id, course_title, dept_id, department_name FROM enrollment_1nf;

INSERT INTO enrollments
SELECT student_id, course_id, grade FROM enrollment_1nf;

SELECT s.student_id, s.student_name, c.course_id, c.course_title,
       c.dept_id, c.department_name, e.grade
FROM enrollments e
JOIN students s       ON s.student_id = e.student_id
JOIN courses_stage c  ON c.course_id  = e.course_id
ORDER BY s.student_id, c.course_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task3_output.png`

```
INSERT INTO students ...        Query OK, 2 rows affected
INSERT INTO courses_stage ...   Query OK, 2 rows affected
INSERT INTO enrollments ...     Query OK, 3 rows affected

+------------+--------------+-----------+------------------+---------+-------------------+-------+
| student_id | student_name | course_id | course_title     | dept_id | department_name   | grade |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
|        101 | Ana Cruz     | IT101     | Database Systems | D01     | Computing Studies |  1.50 |
|        101 | Ana Cruz     | IT102     | Web Development  | D01     | Computing Studies |  1.25 |
|        102 | Ben Lim      | IT101     | Database Systems | D01     | Computing Studies |  1.75 |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
```

**Reflection question:**
I ask what I need to know to find the value. A student's name only needs student_id (half the key), so it is a partial dependency. A grade is different for the same student in different courses, so it needs both student_id and course_id, the whole key.

## Task 4 — Reach Third Normal Form

**Approach / explanation:**
The transitive chain is course_id → dept_id → department_name. I created departments (1 row) and reduced courses to (course_id, course_title, dept_id) (2 rows) with a foreign key to departments. Then I moved the enrollments foreign key from courses_stage to the final courses table and dropped courses_stage. I checked each final table with the decision path, and the four-table join returned all 3 complete rows.

**Code / query used (if applicable):**
```sql
CREATE TABLE departments (
    dept_id         VARCHAR(10) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    course_id    VARCHAR(10) PRIMARY KEY,
    course_title VARCHAR(100) NOT NULL,
    dept_id      VARCHAR(10) NOT NULL,
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments
SELECT DISTINCT dept_id, department_name FROM courses_stage;

INSERT INTO courses
SELECT course_id, course_title, dept_id FROM courses_stage;

ALTER TABLE enrollments DROP FOREIGN KEY fk_enr_course;
ALTER TABLE enrollments
    ADD CONSTRAINT fk_enr_course FOREIGN KEY (course_id) REFERENCES courses(course_id);
DROP TABLE courses_stage;

SELECT s.student_name, c.course_title, d.department_name, e.grade
FROM enrollments e
JOIN students s     ON s.student_id = e.student_id
JOIN courses c      ON c.course_id  = e.course_id
JOIN departments d  ON d.dept_id    = c.dept_id
ORDER BY s.student_name, c.course_title;
```

Decision path verdicts (multi-valued? / partial? / transitive?):

| Table | Multi-valued | Partial | Transitive | Verdict |
|---|---|---|---|---|
| students (student_id PK, student_name) | No | No | No | 3NF |
| departments (dept_id PK, department_name) | No | No | No | 3NF |
| courses (course_id PK, course_title, dept_id FK) | No | No | No (department_name moved out) | 3NF |
| enrollments (student_id + course_id PK, grade) | No | No (grade needs the full key) | No | 3NF |

**Evidence (screenshot filename, output, or file reference in this folder):**
Screenshot: `task4_output.png`

```
INSERT INTO departments ...   Query OK, 1 row affected
INSERT INTO courses ...       Query OK, 2 rows affected

+--------------+------------------+-------------------+-------+
| student_name | course_title     | department_name   | grade |
+--------------+------------------+-------------------+-------+
| Ana Cruz     | Database Systems | Computing Studies |  1.50 |
| Ana Cruz     | Web Development  | Computing Studies |  1.25 |
| Ben Lim      | Database Systems | Computing Studies |  1.75 |
+--------------+------------------+-------------------+-------+
3 rows in set
```

**Reflection question:**
department_name depends on dept_id, which is a non-key column in courses, so a course reaches its department name only indirectly (course_id → dept_id → department_name). The four-table join returns the same 3 rows as the original wide table (names, titles, department, grades), which proves nothing was lost because every foreign key link was kept.

## Task 5 — Reflection

**Approach / explanation:**
I wrote a 150–200 word reflection that contrasts normalizing to 3NF with deliberate denormalization, using the D01 rename from Task 1 as the example, and described the mistake of stopping at 1NF.

**Code / query used (if applicable):**
```sql
-- not applicable (written reflection)
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task5_reflection.txt` (same text as below)

For a campus enrollment system I would normalize to 3NF by default, because enrollment data is edited all the time. In Task 1, department D01 appeared in three rows, so renaming Computing Studies meant three edits, and one missed row would leave two names for one department. After the 3NF split, the name lives once in departments, so a rename is one UPDATE. I would only keep some denormalized repetition on purpose for read-heavy reporting, like a nightly grades summary table, where speed matters and the table is rebuilt from the normalized ones. The mistake I made was stopping at 1NF. After splitting "IT101, IT102" into rows and adding the primary key (student_id, course_id), I thought I was done, but Ana Cruz's name and the course titles still repeated. The symptom was that a rename would still touch many rows. I fixed it by listing the dependencies, moving student_name and course_title into their own tables for 2NF, then moving department_name into departments for 3NF. I ran the four-table join to confirm all rows came back with nothing lost.

**Reflection question:**
I would keep denormalized repetition on purpose for read-heavy reports or summaries that are rebuilt from the normalized tables. The symptom that a split dropped a key is that the JOIN can no longer rebuild the original rows (rows go missing or match wrongly), because there is no foreign key left to link them.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week11/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
