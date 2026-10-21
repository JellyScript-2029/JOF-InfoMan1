USE infoman1_week8;

-- 1.1
SELECT emp_id, first_name, last_name FROM employee WHERE last_name LIKE '%ez';

-- 1.2
SELECT emp_id, first_name, department FROM employee WHERE first_name LIKE 'Ma%';

-- 1.3a
SELECT emp_code FROM employee WHERE emp_code LIKE 'E____';

-- 1.3b
SELECT emp_code, first_name, last_name FROM employee WHERE emp_code LIKE 'E_0__';

-- 2.1
SELECT COUNT(*) AS total_employees, COUNT(commission) AS with_commission FROM employee;

-- 2.2
SELECT SUM(salary) AS total_payroll FROM employee;

-- 2.3
SELECT ROUND(AVG(salary), 2) AS avg_salary, MIN(hire_date) AS earliest_hire, MAX(hire_date) AS latest_hire FROM employee;

-- 2.4
SELECT SUM(salary + COALESCE(commission, 0)) AS total_compensation FROM employee;

-- 3.1
SELECT department, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_salary, COUNT(DISTINCT job_title) AS distinct_titles FROM employee GROUP BY department;

-- 3.2
SELECT department, job_title, COUNT(*) AS headcount FROM employee GROUP BY department, job_title;

-- 4.1
SELECT department, ROUND(AVG(salary), 2) AS avg_salary FROM employee GROUP BY department HAVING AVG(salary) > 66564.50;

-- 4.2
SELECT department, COUNT(*) AS headcount FROM employee WHERE status = 'Active' GROUP BY department HAVING COUNT(*) > 50;

