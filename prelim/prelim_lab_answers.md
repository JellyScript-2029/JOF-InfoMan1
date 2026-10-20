# INFOMAN1 Prelim Lab Exam — Answers (ToolShare)

## Task 5: Debug a Cross-Week Mismatch

Broken query:
```sql
SELECT borrow_date, return_date
FROM borrowing
WHERE member_name = 'Maria Santos';
```

### 1. Why it fails
The short version: `member_name` belongs to the `member` table, not to `borrowing`, so the query asks `borrowing` for a column it doesn't have.

- **Week 3 (schema design) side:** `member_name` is an attribute of the **Member** entity. When I resolved the ERD, the many-to-many relationship between Member and Tool became the junction table `Borrowing`. That table only carries a foreign key to the member (`member_id`), not a copy of the member's name. Putting the name in every borrowing row would be uncontrolled redundancy (Week 1): if a member's name changed, some rows would be updated and others wouldn't, and the data would disagree with itself. Descriptive attributes belong in the table they describe, which is why the design is the way it is.
- **Week 4 (DDL) side:** my `CREATE TABLE borrowing` statement only defines `borrow_id`, `member_id`, `tool_id`, `borrow_date`, and `return_date`. `DESCRIBE borrowing;` shows the same five columns and no `member_name`. Since the column doesn't exist, MySQL rejects the query.

I ran the broken query to confirm, and this is the exact output:

```text
mysql> SELECT borrow_date, return_date FROM borrowing WHERE member_name = 'Maria Santos';
ERROR 1054 (42S22): Unknown column 'member_name' in 'where clause'
```

### 2. Corrected single-table queries
Joins haven't been covered yet, so I did it as two single-table queries linked by the foreign key value. First I find Maria's `member_id` in the `member` table, then I filter `borrowing` on that ID.

```sql
-- Step 1: find Maria's member_id from the member table
SELECT member_id
FROM member
WHERE member_name = 'Maria Santos';

-- Step 2: filter borrowing with that id (1 is what step 1 returned)
SELECT borrow_date, return_date
FROM borrowing
WHERE member_id = 1;
```

Here is the real output of both steps:

```text
mysql> SELECT member_id FROM member WHERE member_name = 'Maria Santos';
+-----------+
| member_id |
+-----------+
|         1 |
+-----------+
1 row in set (0.012 sec)

mysql> SELECT borrow_date, return_date FROM borrowing WHERE member_id = 1;
+-------------+-------------+
| borrow_date | return_date |
+-------------+-------------+
| 2025-09-01  | 2025-09-10  |
| 2025-09-12  | NULL        |
+-------------+-------------+
2 rows in set (0.014 sec)
```

Step 1 returns Maria's `member_id` (1), and step 2 returns her two borrowing records: one that was returned on 2025-09-10, and one that is still on loan, shown by the NULL `return_date`.

### 3. Week 5 concepts illustrated
- **FROM decides what WHERE can use:** a WHERE filter can only reference columns of the table named in FROM (Week 5, SELECT/FROM/WHERE). MySQL doesn't guess what I meant by a column that isn't there. It rejects the query with an error.
- **The filter has to match the real column name and type:** the column must actually exist, and string values need quotes (`'Maria Santos'`), while the numeric `member_id` doesn't (Week 5, comparison operators and quoting).
- **Schema vs. instance (Week 2):** this is a schema problem, because the column doesn't exist. It is not an instance problem where the data just looks wrong, so changing the data could never fix it.
- **Single-table filtering:** until joins are covered, the name lookup and the borrowing lookup stay as two separate WHERE queries, connected by the foreign key value (Week 3, foreign keys).

## Task 3 data type justifications
These are in the comment block at the bottom of `task3_ddl.sql` (phone as VARCHAR not INT, return_date as the deliberately nullable DATE, location_code as a VARCHAR natural key, and borrow_id as a surrogate key).

## Task 1/2 summary
- Entities: Member, Tool, Certification, Storage Location.
- Relationships: Member borrows Tool (M:N), Member completes Certification (M:N), Tool requires Certification (M:N), and Storage Location stores Tool (1:N, total on the Tool side).
- The spec has no weak entities, multivalued attributes, or derived attributes.
- Junction tables: Borrowing, MemberCertification, ToolRequirement.
