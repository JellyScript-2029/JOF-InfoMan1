 -- seed script (run once only)
CREATE DATABASE IF NOT EXISTS infoman1_bookstore;
USE infoman1_bookstore;
 
CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  sku VARCHAR(30),
  price DECIMAL(10,2),
  stock_quantity INT,
  status VARCHAR(20)
);
CREATE TABLE sales (
  sale_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  sale_date DATE,
  quantity INT,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  employee_name VARCHAR(100) NOT NULL,
  manager_id INT
);
CREATE TABLE colors (
  color_name VARCHAR(30) PRIMARY KEY
);
CREATE TABLE sizes (
  size_name VARCHAR(10) PRIMARY KEY
);
 
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES
  ('Notebook', 'NB-001', 45.00, 100, 'Active'),
  ('Ballpen', 'BP-001', 15.00, 250, 'Active'),
  ('USB Drive', 'USB-001', 350.00, 30, 'Active'),
  ('Ruler', 'RL-001', 25.00, 80, 'Active'),
  ('Eraser', 'ER-001', 10.00, 200, 'Active');
INSERT INTO sales (product_id, sale_date, quantity) VALUES
  (1, '2026-08-10', 5),
  (2, '2026-08-11', 10);
INSERT INTO employees VALUES
  (1, 'Lea Ramos', NULL),
  (2, 'Carlo Reyes', 1),
  (3, 'Dana Cruz', 1);
INSERT INTO colors VALUES ('Red'), ('Blue'), ('Green');
INSERT INTO sizes VALUES ('S'), ('M'), ('L');
 
USE infoman1_bookstore;
 
-- check starting data
SELECT * FROM products;
 
 
-- TASK 1: Safe INSERT
 
-- insert 1
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');
 
SELECT * FROM products WHERE sku = 'CALC-SCI-001';
 
-- insert 2
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');
 
SELECT * FROM products WHERE sku = 'CMP-001';
 
-- rejected: 'abc' is not a decimal (error 1366)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Test Item', 'TST-001', 'abc', 10, 'Active');
 
-- check that nothing was added
SELECT * FROM products WHERE sku = 'TST-001';
 
 
-- TASK 2: UPDATE & DELETE
 
-- compare name vs id
SELECT * FROM products WHERE product_name = 'Scientific Calculator';
SELECT * FROM products WHERE product_id = 6;
 
-- update calculator price
-- preview
SELECT product_id, product_name, price
FROM products
WHERE product_id = 6;
 
-- execute
UPDATE products
SET price = 875.00
WHERE product_id = 6;
 
-- verify
SELECT product_id, product_name, price
FROM products
WHERE product_id = 6;
 
-- no WHERE = all prices become 875.00
 
 
-- delete eraser
-- preview
SELECT * FROM products WHERE product_id = 5;
 
-- execute
DELETE FROM products
WHERE product_id = 5;
 
-- verify
SELECT * FROM products WHERE product_id = 5;
SELECT * FROM products;
 
-- no WHERE = tries to delete every row
 
 
-- TASK 3: Self Join & Cross Join
 
-- self join
SELECT e.employee_id,
       e.employee_name AS employee,
       m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
       ON e.manager_id = m.employee_id;
 
-- cross join
SELECT c.color_name, s.size_name
FROM colors AS c
CROSS JOIN sizes AS s
ORDER BY c.color_name, s.size_name;
 
-- row count (should be 9)
SELECT COUNT(*) AS total_combinations
FROM colors AS c
CROSS JOIN sizes AS s;
 
 
-- TASK 4: Constraints & Table Evolution
 
-- (a) practice table with new column
CREATE TABLE students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  student_name VARCHAR(100) NOT NULL
);
 
INSERT INTO students (student_name) VALUES ('Maria Santos'), ('Juan Dela Cruz');
 
ALTER TABLE students
ADD COLUMN contact_number VARCHAR(20);
 
-- old rows are NULL
SELECT * FROM students;
 
UPDATE students
SET contact_number = '09171234567'
WHERE student_id = 1;
 
SELECT * FROM students;
 
 
-- (b) rule 1: product_name NOT NULL
-- check for NULLs first
SELECT COUNT(*) AS null_names
FROM products
WHERE product_name IS NULL;
 
ALTER TABLE products
MODIFY product_name VARCHAR(100) NOT NULL;
 
-- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Stapler', 'STP-001', 95.00, 40, 'Active');
 
-- rejected (error 1048)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES (NULL, 'NN-001', 50.00, 10, 'Active');
 
 
-- rule 2: sku UNIQUE
-- check for duplicates first
SELECT sku, COUNT(*) AS how_many
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;
 
ALTER TABLE products
ADD CONSTRAINT uq_products_sku UNIQUE (sku);
 
-- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Highlighter', 'HL-001', 30.00, 60, 'Active');
 
-- rejected, NB-001 is already used (error 1062)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Notebook Copy', 'NB-001', 45.00, 10, 'Active');
 
 
-- rule 3: CHECK price > 0
-- check old prices first
SELECT * FROM products WHERE price <= 0;
 
ALTER TABLE products
ADD CONSTRAINT chk_price_positive CHECK (price > 0);
 
-- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Pencil Case', 'PC-001', 60.00, 25, 'Active');
 
-- rejected (error 3819)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Free Pen', 'FP-001', -5.00, 10, 'Active');
 
 
-- extra: DEFAULT
ALTER TABLE products
ALTER COLUMN stock_quantity SET DEFAULT 0;
 
-- no stock_quantity, should be 0
INSERT INTO products (product_name, sku, price, status)
VALUES ('Sticky Notes', 'SN-001', 20.00, 'Active');
 
SELECT product_name, stock_quantity FROM products WHERE sku = 'SN-001';
 
-- check the constraints are there
SHOW CREATE TABLE products;
SELECT * FROM products;
 