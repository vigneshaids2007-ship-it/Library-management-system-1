-- =====================================================================
-- Library Management System - Database Schema
-- =====================================================================
-- Import this file into MySQL/MariaDB (e.g. via phpMyAdmin or:
--   mysql -u root -p < library_db.sql
-- =====================================================================

DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_db;

-- ---------------------------------------------------------------------
-- USERS  (both Admins and Students live here, differentiated by `role`)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(120)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    password      VARCHAR(255)  NOT NULL,          -- bcrypt hash
    role          ENUM('admin','student') NOT NULL DEFAULT 'student',
    phone         VARCHAR(20)   DEFAULT NULL,
    address       VARCHAR(255)  DEFAULT NULL,
    roll_number   VARCHAR(50)   DEFAULT NULL,       -- student id / registration no.
    status        ENUM('active','blocked') NOT NULL DEFAULT 'active',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CATEGORIES
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description   VARCHAR(255) DEFAULT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- AUTHORS
-- ---------------------------------------------------------------------
CREATE TABLE authors (
    author_id     INT AUTO_INCREMENT PRIMARY KEY,
    author_name   VARCHAR(150) NOT NULL,
    bio           TEXT DEFAULT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PUBLISHERS
-- ---------------------------------------------------------------------
CREATE TABLE publishers (
    publisher_id  INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(150) NOT NULL,
    contact_email VARCHAR(150) DEFAULT NULL,
    phone         VARCHAR(20)  DEFAULT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- BOOKS
-- ---------------------------------------------------------------------
CREATE TABLE books (
    book_id       INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    isbn          VARCHAR(30)  NOT NULL UNIQUE,
    category_id   INT DEFAULT NULL,
    author_id     INT DEFAULT NULL,
    publisher_id  INT DEFAULT NULL,
    edition       VARCHAR(50)  DEFAULT NULL,
    rack_no       VARCHAR(20)  DEFAULT NULL,
    price         DECIMAL(10,2) DEFAULT 0.00,
    total_copies  INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    cover_color   VARCHAR(20) DEFAULT '#3D5A80',   -- used for the UI "spine" color
    description   TEXT DEFAULT NULL,
    added_on      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id)  REFERENCES categories(category_id)  ON DELETE SET NULL,
    FOREIGN KEY (author_id)    REFERENCES authors(author_id)       ON DELETE SET NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- BOOK ISSUES  (a row is created every time a book is issued)
-- ---------------------------------------------------------------------
CREATE TABLE book_issues (
    issue_id      INT AUTO_INCREMENT PRIMARY KEY,
    book_id       INT NOT NULL,
    user_id       INT NOT NULL,
    issue_date    DATE NOT NULL,
    due_date      DATE NOT NULL,
    status        ENUM('issued','returned') NOT NULL DEFAULT 'issued',
    renewed_count INT NOT NULL DEFAULT 0,
    issued_by     INT DEFAULT NULL,                 -- admin user_id
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- RETURNS
-- ---------------------------------------------------------------------
CREATE TABLE returns (
    return_id     INT AUTO_INCREMENT PRIMARY KEY,
    issue_id      INT NOT NULL,
    return_date   DATE NOT NULL,
    condition_note VARCHAR(255) DEFAULT 'Good',
    received_by   INT DEFAULT NULL,                 -- admin user_id
    FOREIGN KEY (issue_id) REFERENCES book_issues(issue_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- FINES
-- ---------------------------------------------------------------------
CREATE TABLE fines (
    fine_id       INT AUTO_INCREMENT PRIMARY KEY,
    issue_id      INT NOT NULL,
    user_id       INT NOT NULL,
    amount        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    reason        VARCHAR(150) DEFAULT 'Late return',
    status        ENUM('unpaid','paid','waived') NOT NULL DEFAULT 'unpaid',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at       DATETIME DEFAULT NULL,
    FOREIGN KEY (issue_id) REFERENCES book_issues(issue_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- SAMPLE DATA
-- =====================================================================

-- Default password for BOTH sample accounts below is:  Password123
-- (hash generated with PHP password_hash(), bcrypt)
INSERT INTO users (full_name, email, password, role, phone, roll_number, status) VALUES
('Library Admin', 'admin@library.com', '$2b$12$TVQSJI2SNeLg6bHlncbDC.uE/ZWGG.fQNBxuftvSTGL4kuIkAlES2', 'admin', '9990001111', NULL, 'active'),
('Aisha Khan', 'aisha@student.com', '$2b$12$TVQSJI2SNeLg6bHlncbDC.uE/ZWGG.fQNBxuftvSTGL4kuIkAlES2', 'student', '9812345678', 'STU-1001', 'active'),
('Rohan Mehta', 'rohan@student.com', '$2b$12$TVQSJI2SNeLg6bHlncbDC.uE/ZWGG.fQNBxuftvSTGL4kuIkAlES2', 'student', '9823456789', 'STU-1002', 'active'),
('Sara Ali', 'sara@student.com', '$2b$12$TVQSJI2SNeLg6bHlncbDC.uE/ZWGG.fQNBxuftvSTGL4kuIkAlES2', 'student', '9834567890', 'STU-1003', 'active');

INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Novels and imaginative literature'),
('Science', 'Scientific and technical works'),
('History', 'Historical accounts and analysis'),
('Technology', 'Computing, engineering and IT'),
('Biography', 'Life stories of notable people'),
('Philosophy', 'Philosophical texts and essays');

INSERT INTO authors (author_name, bio) VALUES
('George Orwell', 'English novelist and essayist, 1903-1950.'),
('Isaac Asimov', 'American writer and biochemist, known for science fiction.'),
('Yuval Noah Harari', 'Israeli historian and author of Sapiens.'),
('Robert C. Martin', 'Software engineer, author of Clean Code.'),
('Walter Isaacson', 'Biographer and journalist.'),
('Jane Austen', 'English novelist, 1775-1817.');

INSERT INTO publishers (publisher_name, contact_email, phone) VALUES
('Penguin Books', 'contact@penguin.com', '1800-111-222'),
('O''Reilly Media', 'info@oreilly.com', '1800-333-444'),
('HarperCollins', 'support@harpercollins.com', '1800-555-666'),
('Prentice Hall', 'sales@prenticehall.com', '1800-777-888');

INSERT INTO books (title, isbn, category_id, author_id, publisher_id, edition, rack_no, price, total_copies, available_copies, cover_color, description) VALUES
('1984', '9780451524935', 1, 1, 1, '1st', 'A1', 350.00, 5, 4, '#3D5A80', 'A dystopian social science fiction novel.'),
('Animal Farm', '9780451526342', 1, 1, 1, '2nd', 'A1', 220.00, 4, 4, '#98C1D9', 'An allegorical novella.'),
('Foundation', '9780553293357', 2, 2, 3, '1st', 'B2', 400.00, 3, 2, '#EE6C4D', 'The first novel in the Foundation series.'),
('Sapiens: A Brief History of Humankind', '9780062316097', 3, 3, 3, '1st', 'C1', 550.00, 6, 5, '#293241', 'A brief history of humankind.'),
('Clean Code', '9780132350884', 4, 4, 2, '1st', 'D3', 650.00, 4, 3, '#7A2E2E', 'A handbook of agile software craftsmanship.'),
('Steve Jobs', '9781451648539', 5, 5, 3, '1st', 'E2', 480.00, 3, 3, '#B8860B', 'The exclusive biography of Steve Jobs.'),
('Pride and Prejudice', '9780141439518', 1, 6, 1, '3rd', 'A2', 200.00, 5, 5, '#5B7B7A', 'A romantic novel of manners.'),
('The Pragmatic Programmer', '9780135957059', 4, 4, 2, '2nd', 'D3', 700.00, 3, 1, '#3D5A80', 'From journeyman to master.');

-- A couple of sample issues (one overdue, one active) for demo/reporting purposes
INSERT INTO book_issues (book_id, user_id, issue_date, due_date, status, issued_by) VALUES
(1, 2, CURDATE() - INTERVAL 20 DAY, CURDATE() - INTERVAL 6 DAY, 'issued', 1),   -- overdue
(3, 3, CURDATE() - INTERVAL 5 DAY,  CURDATE() + INTERVAL 9 DAY, 'issued', 1),  -- active
(5, 2, CURDATE() - INTERVAL 30 DAY, CURDATE() - INTERVAL 16 DAY, 'issued', 1), -- overdue
(8, 4, CURDATE() - INTERVAL 40 DAY, CURDATE() - INTERVAL 26 DAY, 'issued', 1); -- overdue

-- Fine for the overdue issue above (issue_id 1) -- 6 days late * 5.00/day = 30.00
INSERT INTO fines (issue_id, user_id, amount, reason, status) VALUES
(1, 2, 30.00, 'Late return', 'unpaid'),
(3, 2, 70.00, 'Late return', 'unpaid'),
(4, 4, 130.00, 'Late return', 'unpaid');
