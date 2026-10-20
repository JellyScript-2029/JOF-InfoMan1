-- Task 3: ToolShare DDL (MySQL / InnoDB)
-- Builds the database and the 7 tables from my Task 2 schema.

CREATE DATABASE toolshare_prelim;
USE toolshare_prelim;

CREATE TABLE member (
    member_id INT NOT NULL,
    member_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL,
    PRIMARY KEY (member_id)
) ENGINE=InnoDB;

CREATE TABLE storage_location (
    location_code VARCHAR(10) NOT NULL,
    description VARCHAR(100) NOT NULL,
    PRIMARY KEY (location_code)
) ENGINE=InnoDB;

CREATE TABLE certification (
    cert_id INT NOT NULL,
    cert_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (cert_id)
) ENGINE=InnoDB;

CREATE TABLE tool (
    tool_id INT NOT NULL,
    tool_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    location_code VARCHAR(10) NOT NULL,   -- NOT NULL = total participation (every tool has a location)
    PRIMARY KEY (tool_id),
    FOREIGN KEY (location_code) REFERENCES storage_location (location_code)
) ENGINE=InnoDB;

CREATE TABLE borrowing (
    borrow_id INT NOT NULL,
    member_id INT NOT NULL,
    tool_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE NULL,                -- NULL = still on loan
    PRIMARY KEY (borrow_id),
    FOREIGN KEY (member_id) REFERENCES member (member_id),
    FOREIGN KEY (tool_id) REFERENCES tool (tool_id)
) ENGINE=InnoDB;

CREATE TABLE member_certification (
    member_id INT NOT NULL,
    cert_id INT NOT NULL,
    completion_date DATE NOT NULL,
    PRIMARY KEY (member_id, cert_id),
    FOREIGN KEY (member_id) REFERENCES member (member_id),
    FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
) ENGINE=InnoDB;

CREATE TABLE tool_requirement (
    tool_id INT NOT NULL,
    cert_id INT NOT NULL,
    PRIMARY KEY (tool_id, cert_id),
    FOREIGN KEY (tool_id) REFERENCES tool (tool_id),
    FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
) ENGINE=InnoDB;

SHOW TABLES;
DESCRIBE member;
DESCRIBE storage_location;
DESCRIBE certification;
DESCRIBE tool;
DESCRIBE borrowing;
DESCRIBE member_certification;
DESCRIBE tool_requirement;

/* Data type choices and why

1. phone is VARCHAR(20), not INT. A phone number is really an identifier, not a
   number you calculate with. INT would also drop leading zeros (this was the
   common mistake from week 4) and it can't hold "+", dashes or spaces.

2. return_date is DATE and allows NULL. The spec says a tool that is still on loan
   has no return date, so this is the one column I left nullable on purpose.
   I used DATE instead of DATETIME because only the calendar date is recorded.

3. location_code is VARCHAR(10), not CHAR or INT. The codes themselves are short,
   like A3, B1 and C2 (the longer text like "Shelf A3" or "Pegboard B1" is the
   description column, not the code), so VARCHAR fits fine and CHAR would just
   pad them with spaces. I kept it as a natural key because the codes are stable
   and human-readable, which also keeps the FK in tool easy to read.

4. borrow_id is an INT surrogate key. Since the same member can borrow the same
   tool more than once, (member_id, tool_id) is not unique and can't be the PK.
*/
