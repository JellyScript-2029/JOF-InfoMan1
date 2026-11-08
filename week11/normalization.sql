CREATE DATABASE IF NOT EXISTS infoman1_normalization;
USE infoman1_normalization;

CREATE TABLE student_enrollment (
  student_id INT,
  student_name VARCHAR(100),
  enrolled_courses VARCHAR(200),
  course_id VARCHAR(10),
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100),
  grade DECIMAL(4,2)
);

INSERT INTO student_enrollment VALUES
  (101, 'Ana Cruz', 'IT101, IT102', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.50),
  (102, 'Ben Lim', 'IT101', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.75),
  (101, 'Ana Cruz', 'IT101, IT102', 'IT102', 'Web Development', 'D01', 'Computing Studies', 1.25);

/* TASK 1 - Diagnose the Anomalies (SELECT only)*/

SELECT dept_id, department_name, COUNT(*) AS rows_to_change
FROM student_enrollment
WHERE dept_id = 'D01'
GROUP BY dept_id, department_name;

SELECT * FROM student_enrollment WHERE course_id = 'IT103';  


SELECT NULL AS student_id, 'NO STUDENT (placeholder)' AS student_name,
       NULL AS enrolled_courses, 'IT103' AS course_id,
       'Intro to Networks' AS course_title, 'D01' AS dept_id,
       'Computing Studies' AS department_name, NULL AS grade;

SELECT course_id, course_title, dept_id, department_name, COUNT(*) AS rows_with_this_course
FROM student_enrollment
WHERE course_id = 'IT102'
GROUP BY course_id, course_title, dept_id, department_name;

/*TASK 2 - First Normal Form (1NF) */
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

/* TASK 3 - Second Normal Form (2NF)*/

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

/*TASK 4 - Third Normal Form (3NF)*/

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
