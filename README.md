# Athenaeum — Library Management System

A modern, responsive Library Management System built with **PHP (PDO/MySQLi)**, **MySQL**, and **Bootstrap 5**. Supports two roles — **Admin** and **Student** — with full book, circulation, and fine management.

## Features

- Secure login & self-registration (bcrypt password hashing, CSRF protection)
- Admin dashboard with live statistics (titles, availability, overdue, fines collected)
- Full CRUD for Books, Categories, Authors, Publishers
- Book availability tracking (total vs. available copies)
- Issue books to students, with duplicate-loan and blocked-account checks
- Return & renew workflow with renewal limits
- Automatic fine calculation for late returns ($5/day, configurable)
- Student management (create, edit, block/unblock, delete)
- Book search by title, author, ISBN, or category (admin + student)
- Reports: Issued / Returned / Available / Overdue, printable
- Fully responsive UI (desktop, tablet, mobile) with an off-canvas sidebar on small screens
- Sample data included for instant testing

## Tech Stack

| Layer      | Technology                          |
|------------|--------------------------------------|
| Frontend   | HTML5, CSS3, JavaScript, Bootstrap 5 |
| Backend    | PHP 8 (PDO)                          |
| Database   | MySQL / MariaDB                      |

## Project Structure

```
library-management-system/
├── admin/                 Admin-only pages (dashboard, books, categories, authors,
│                           publishers, issue, returns, fines, students, reports)
├── student/                Student-only pages (dashboard, browse, my books, fines)
├── auth/                   login.php, register.php, logout.php
├── config/                 database.php (connection), config.php (app settings)
├── includes/                functions.php (helpers), header.php, footer.php
├── assets/
│   ├── css/style.css        Design system (navy / parchment / brass theme)
│   └── js/script.js         Sidebar toggle, validation, live search, confirmations
├── sql/library_db.sql       Schema + sample data
└── index.php                 Role-based redirect
```

## Setup

1. **Create the database.**
   Import the schema and sample data:
   ```bash
   mysql -u root -p < sql/library_db.sql
   ```
   This creates the `library_db` database with 8 tables and sample books, users, and loans.

2. **Configure the connection.**
   Edit `config/database.php` if your MySQL credentials differ from the defaults
   (`localhost` / `root` / no password).

3. **Set the base URL.**
   In `config/config.php`, set `BASE_URL` to match where you place the project,
   e.g. `/library-management-system` or `''` if served from the web root.

4. **Serve the app.**
   Point Apache/Nginx (or PHP's built-in server) at the project root:
   ```bash
   php -S localhost:8000
   ```
   Then visit `http://localhost:8000/`.

5. **Log in with a demo account** (password for both: `Password123`):
   - **Admin:** admin@library.com
   - **Student:** aisha@student.com

## Database Tables

`users` · `books` · `categories` · `authors` · `publishers` · `book_issues` · `returns` · `fines`

## Notes on Business Logic

- **Fine calculation** — `calculate_fine()` in `includes/functions.php` charges `FINE_PER_DAY`
  for every day past the due date. `sync_overdue_fines()` runs on dashboard/report/fine pages
  to keep outstanding fines current for books still on loan.
- **Renewals** — capped at `MAX_RENEWALS` (default 2) and blocked once a loan is overdue.
- **Copy tracking** — editing a book's total copy count preserves any copies currently checked out.
- **Security** — all forms use CSRF tokens on state-changing POST requests; passwords are hashed
  with bcrypt; all output is escaped via the `h()` helper; all queries use prepared statements.

## Customization

- Loan period, fine rate, and renewal limit are configured at the top of `config/config.php`.
- Colors, type, and layout live in `assets/css/style.css` under the `:root` custom properties.
