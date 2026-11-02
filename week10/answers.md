# INFOMAN1 — Week 10 Lab Answers

Name: Jhelianne Figuerres
Student ID: 2510465
GitHub repo: https://github.com/JellyScript-2029/JOF-InfoMan1.git
Date submitted: November 2, 2026

## Task 1 — Safe INSERT

**Approach / explanation:**
I inserted the Scientific Calculator and the Compass using INSERT INTO products with all the column names written out, and I left out product_id because it is AUTO_INCREMENT. After each insert I ran a SELECT on the sku to check that the row was really saved. For the rejected insert, I tried to put 'abc' in the price column, which MySQL refuses because price is DECIMAL(10,2) and 'abc' is not a number.

**Code / query used (if applicable):**
```sql
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');
SELECT * FROM products WHERE sku = 'CALC-SCI-001';

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');
SELECT * FROM products WHERE sku = 'CMP-001';

-- rejected: wrong data type
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Test Item', 'TST-001', 'abc', 10, 'Active');
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task1_output.png`

```
product_id | product_name          | sku          | price  | stock_quantity | status
6          | Scientific Calculator | CALC-SCI-001 | 850.00 | 20             | Active
7          | Compass               | CMP-001      | 120.00 | 50             | Active

ERROR 1366 (HY000): Incorrect decimal value: 'abc' for column 'price' at row 1
```

**Reflection question:**
Listing the columns makes the INSERT safer because the values are matched to the column names and not to the table's column order. If the table changes later (a new column is added or the order changes), the insert still puts the values in the right place. Columns I leave out get their DEFAULT value, or NULL if there is no default, and AUTO_INCREMENT columns like product_id get the next number automatically.

## Task 2 — UPDATE & DELETE Without Collateral Damage

**Approach / explanation:**
For each change I did three steps: first a SELECT with the exact WHERE condition I planned to use, then the UPDATE or DELETE with the same condition, then a SELECT again to verify. I used product_id (6 for the calculator and 5 for the eraser) instead of the product names so I only touch the one row I mean.

**Code / query used (if applicable):**
```sql
-- UPDATE: preview, execute, verify
SELECT product_id, product_name, price FROM products WHERE product_id = 6;
UPDATE products SET price = 875.00 WHERE product_id = 6;
SELECT product_id, product_name, price FROM products WHERE product_id = 6;

-- DELETE: preview, execute, verify
SELECT * FROM products WHERE product_id = 5;
DELETE FROM products WHERE product_id = 5;
SELECT * FROM products WHERE product_id = 5;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task2_output.png`

```
Preview:  6 | Scientific Calculator | 850.00
UPDATE:   Query OK, 1 row affected (Rows matched: 1  Changed: 1  Warnings: 0)
Verify:   6 | Scientific Calculator | 875.00

Preview:  5 | Eraser | ER-001 | 10.00 | 200 | Active
DELETE:   Query OK, 1 row affected
Verify:   Empty set
```

**Reflection question:**
Without the WHERE clause, the UPDATE would have changed the price of every product in the table to 875.00, and the DELETE would have tried to delete every row in products. (In my case the foreign key from sales would probably block it because products 1 and 2 have sales, but I should not depend on that.) A stable identifier like product_id is safer than a name because it is unique and never changes, while a name can be repeated, misspelled, or edited later and could match more than one row.

Before running the change, I also previewed the calculator by name and by ID to compare. Both returned 1 row here, but nothing stops two products from sharing a name (the table has no UNIQUE on product_name), so product_id is the only one that is always exactly one row.

## Task 3 — Self Join & Cross Join

**Approach / explanation:**
For the self join I used the employees table twice with the aliases e (the employee) and m (the manager), and matched e.manager_id to m.employee_id. For the cross join I paired colors with sizes without any ON condition, then counted the rows to confirm it is 3 x 3 = 9.

**Code / query used (if applicable):**
```sql
-- (a) self join
SELECT e.employee_id,
       e.employee_name AS employee,
       m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
       ON e.manager_id = m.employee_id;

-- (b) cross join
SELECT c.color_name, s.size_name
FROM colors AS c
CROSS JOIN sizes AS s
ORDER BY c.color_name, s.size_name;

SELECT COUNT(*) AS total_combinations
FROM colors AS c
CROSS JOIN sizes AS s;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task3_output.png`

```
employee_id | employee    | manager
1           | Lea Ramos   | NULL
2           | Carlo Reyes | Lea Ramos
3           | Dana Cruz   | Lea Ramos

Cross join (9 rows):
Blue-L, Blue-M, Blue-S, Green-L, Green-M, Green-S, Red-L, Red-M, Red-S

total_combinations = 9
```

LEFT JOIN keeps Lea because she has no manager (manager_id is NULL), so she has no match on the right side, and a LEFT JOIN still keeps every row from the left table and shows NULL for the manager.

A real business use of CROSS JOIN is generating all the variants of a product, for example every color and size of a notebook, so each combination can be listed for inventory. It must never be an accidental missing-ON because forgetting the ON would multiply the rows (for big tables this can be thousands or millions) and give wrong results.

**Reflection question:**
The self join needs two aliases because it is the same table used twice, and MySQL cannot tell which copy a column belongs to without e and m. It needs a LEFT JOIN so the top person (Lea, with no manager) is not dropped, which an INNER JOIN would do. A CROSS JOIN is the deliberate choice when I really want every combination of two lists, like colors and sizes, and I write it with the CROSS JOIN keyword so it is clear that it is on purpose.

## Task 4 — Constraints & Table Evolution

**Approach / explanation:**
First I made a small practice table called students and added a contact_number VARCHAR(20) column with ALTER TABLE. Then I added the three bookstore rules on products with ALTER TABLE. Before each one I checked the existing data for problems (NULL names, duplicate skus, prices <= 0). Then I tested one valid insert that passes and one invalid insert that gets rejected.

**Code / query used (if applicable):**
```sql
-- (a) new column
CREATE TABLE students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  student_name VARCHAR(100) NOT NULL
);
ALTER TABLE students ADD COLUMN contact_number VARCHAR(20);

-- (b) Rule 1: NOT NULL
ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Stapler', 'STP-001', 95.00, 40, 'Active');            -- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES (NULL, 'NN-001', 50.00, 10, 'Active');                  -- rejected

-- Rule 2: UNIQUE
ALTER TABLE products ADD CONSTRAINT uq_products_sku UNIQUE (sku);
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Highlighter', 'HL-001', 30.00, 60, 'Active');         -- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Notebook Copy', 'NB-001', 45.00, 10, 'Active');       -- rejected

-- Rule 3: CHECK
ALTER TABLE products ADD CONSTRAINT chk_price_positive CHECK (price > 0);
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Pencil Case', 'PC-001', 60.00, 25, 'Active');         -- passes
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Free Pen', 'FP-001', -5.00, 10, 'Active');            -- rejected
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task4_output.png`

```
NOT NULL : ERROR 1048 (23000): Column 'product_name' cannot be null
UNIQUE   : ERROR 1062 (23000): Duplicate entry 'NB-001' for key 'products.uq_products_sku'
CHECK    : ERROR 3819 (HY000): Check constraint 'chk_price_positive' is violated.
```

Extra: I also tried DEFAULT with `ALTER TABLE products ALTER COLUMN stock_quantity SET DEFAULT 0;`. When I inserted Sticky Notes without stock_quantity, it was saved with 0.

Syntax caveat and how I tested: In MySQL, NOT NULL is added with MODIFY (re-stating the whole column definition), not with ADD CONSTRAINT. CHECK is only enforced in MySQL 8.0.16 and above. Older versions accept the syntax but silently ignore it. To test, I inserted a negative price and confirmed that I really got error 3819, and I also looked at SHOW CREATE TABLE products to see all three rules listed.

**Reflection question:**
Constraints only check new INSERTs and UPDATEs after they are added. They do not fix rows that were already saved, so old bad data would stay or even make the ALTER TABLE fail. Before adding NOT NULL I must check for existing NULLs (WHERE product_name IS NULL) and fix or fill them, otherwise MySQL will not accept the change.

## Task 5 — Reflection

**Approach / explanation:**
I compared checks in the app form with constraints in the database using the CHECK (price > 0) rule from Task 4. For the mistake, I used the self join error from Task 3 where I forgot the aliases. The full reflection is in `task5_reflection.txt` and is pasted below.

**Code / query used (if applicable):**
```sql
-- the mistake (no aliases):
SELECT employee_name FROM employees
LEFT JOIN employees ON manager_id = employee_id;
-- ERROR 1066 (42000): Not unique table/alias: 'employees'

-- the fix: aliases e and m (see Task 3)
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task5_reflection.txt` (about 180 words)

> For a campus bookstore I would use both layers, but I trust the database more for rules that must never break. Application checks, like a form saying a price is required, give the cashier a quick and friendly message. But they only protect data that comes through that form. Another script or someone typing in Workbench can skip them. So rules like price above zero or a unique SKU belong in the database. In Task 4, CHECK (price > 0) rejected a price of -5 even though I inserted it directly with no form involved.
>
> A mistake I made was in Task 3. I first wrote the self join as employees LEFT JOIN employees without aliases. MySQL showed ERROR 1066 (42000): Not unique table/alias: 'employees'. The symptom was that the query would not run at all, because MySQL could not tell the two copies of the table apart. I fixed it by adding aliases, employees AS e and employees AS m, then using e.manager_id = m.employee_id in the ON clause. After that, Lea showed up with a NULL manager, which was correct.

**Reflection question:**
I would trust the application form for friendly, quick feedback to the user (like showing "please enter a price"), but trust the database constraint for rules that must always be true no matter how the data gets in. The symptom that I trusted the wrong layer would be bad data showing up in the table anyway, such as a negative price or duplicate sku that came in from a script or a direct insert that skipped the form.

## Self-Check

- [X] All tasks committed with individual, meaningful commit messages
- [X] All files placed inside `week10/`
- [X] This file completed and renamed `answers.md`
- [X] Repository link pasted into Moodle (no files uploaded)
