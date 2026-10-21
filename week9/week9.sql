
CREATE DATABASE IF NOT EXISTS infoman1_canteen;
USE infoman1_canteen;

CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL,
  program VARCHAR(20) NOT NULL
);
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  student_id INT NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);
CREATE TABLE menu_items (
  menu_id INT PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  price DECIMAL(8,2) NOT NULL
);
CREATE TABLE order_items (
  order_id INT NOT NULL,
  menu_id INT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (order_id, menu_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (menu_id) REFERENCES menu_items(menu_id)
);

INSERT INTO students VALUES
  (1, 'Ana Cruz', 'BSIT'),
  (2, 'Ben Lim', 'BSCS'),
  (3, 'Cara Yu', 'BSIS'),
  (4, 'Dan Reyes', 'BSIT');
INSERT INTO orders VALUES
  (101, 1, '2026-08-10'),
  (102, 1, '2026-08-15'),
  (103, 4, '2026-08-16');
INSERT INTO menu_items VALUES
  (1, 'Siomai Rice', 65.00),
  (2, 'Burger Steak', 89.00),
  (3, 'Iced Tea', 30.00);
INSERT INTO order_items VALUES
  (101, 1, 2),
  (101, 3, 1),
  (102, 2, 1),
  (103, 1, 1);

-- ===== Task 1: INNER JOIN basics =====
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
ORDER BY o.order_id;

-- ===== Task 2a: LEFT JOIN, all students =====
SELECT s.student_id, s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
ORDER BY s.student_id, o.order_id;

-- ===== Task 2b: students who never ordered =====
SELECT s.student_id, s.student_name
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_id IS NULL;

-- ===== Task 3: four-table canteen report =====
SELECT s.student_name, s.program, o.order_id, m.item_name,
       oi.quantity, m.price, oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
ORDER BY o.order_id, m.item_name;

-- ===== Task 4 version A: inner joins + WHERE, newest first =====
SELECT s.student_name, o.order_id, o.order_date, m.item_name,
       oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, o.order_id DESC, m.item_name;

-- ===== Task 4 version B: LEFT JOIN + WHERE (silent inner join) =====
SELECT s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;

-- ===== Task 4 fix: date rule moved into ON =====
SELECT s.student_name, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o
  ON s.student_id = o.student_id
 AND o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, s.student_id;
