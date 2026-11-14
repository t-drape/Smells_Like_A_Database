# SILLAGE — Smells Like a Database

A Python website built around the supplied fragrance mockup and the team's existing MySQL functions. The storefront keeps the olive and cream palette, spinning cards, reflections, marquee, group tabs, and sample-dialog visual treatment. Live mode connects to your existing database. Preview mode uses only public catalogue data extracted from your uploaded `setup.sql`.

The website includes Collection, Find in Stores, Top Sellers, Add Fragrance, and Add Brand tabs. Team Desk now includes Restock, connected to your supplied function unchanged. Add Fragrance now executes your latest supplied INSERT, commits, and returns its generated ID for existing brands. Add Brand now uses your corrected insertion function with an existing Country_ID, commits, returns its new ID, and refreshes the house choices.

Restock supplies the separate UPDATE action, so all seven distinct action categories now have connected supplied functions. The Add Fragrance implementation is connected; its real permission demonstration still needs testing against your MySQL server. Individual customer authentication/history remains optional team work. Start with `docs/CATALOG_SCRIPT_REVIEW.md`; the requirements map is in `docs/TEAM_WORK.md`.

**Updating an existing copy:** stop the server and extract the new ZIP into a separate folder first. Preserve any additional student code you completed locally. Both insertion scaffolds have now been replaced with your supplied functions adapted for web arguments. The latest update changes `app.py`, `service.py`, and `student_code/brands.py`; the earlier fragrance and Restock changes are included. Updating only app.py is not sufficient. Preserve any additional local changes before copying the new project files.

## Run with your existing MySQL server

Use Python 3.10 or newer. From this folder:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python app.py --staff
```

On Windows, activate with `.venv\Scripts\activate` instead.

Open **http://127.0.0.1:8000**. Enter your MySQL application-account password in the terminal when prompted. Then choose a separate password for the team desk for this run. The team desk is linked in the website footer. Never give website customers the database password.

The defaults are `localhost`, port `3306`, database `scent_db`, user `scent_app`. That user is the limited application account already defined by your team's `account.sql`. This project does not create an account or change its permissions. If your existing account or host has a different name, set these environment variables before starting:

```bash
export MYSQL_HOST=localhost
export MYSQL_PORT=3306
export MYSQL_DATABASE=scent_db
export MYSQL_USER=scent_app
python app.py --staff
```

To use Add Fragrance and Add Brand, enable the customer/admin database profiles with:

```bash
python app.py --staff --fragrance-accounts
```

This asks for the additional database passwords. `MYSQL_CUSTOMER_USER` and `MYSQL_ADMIN_USER` default to the team-defined `customer` and `admin` usernames. Their corresponding `MYSQL_CUSTOMER_PASSWORD` and `MYSQL_ADMIN_PASSWORD` environment variables are optional alternatives to prompts. These profiles share the base host/port/database. Add Fragrance uses the customer/admin profiles; Add Brand uses the admin profile after staff authentication. Other features, including Restock, use the base application account. Read the guide before demonstrating permissions. The app never changes grants.

`MYSQL_PASSWORD` and `SILLAGE_STAFF_PASSWORD` are optional environment variables; terminal prompts avoid placing passwords in source files. PowerShell uses `$env:MYSQL_USER = "scent_app"`, etc. Use `--port 8080` if port 8000 is busy. Run `python app.py` without `--staff` to leave the team desk disabled (unless its password is supplied through the environment).

**Your database already exists: do not run the setup SQL again.** `sql/setup.sql` is an unchanged copy of your uploaded dump and contains destructive table-recreation commands. It is included for reference or an intentionally empty development database. The app never runs it. `sql/account.sql` is also unchanged; your team owns all account/grant decisions. Do not assume CREATE USER IF NOT EXISTS changes an existing account's password or removes its old grants.

The server binds to this computer only. Your browser contacts Python; Python contacts MySQL. If MySQL runs on another computer, configure its reachable host and use the account your team has authorized for that connection. This local classroom server is not an Internet deployment.

## Password-hashing compatibility fix

The team-desk login in `app.py` now uses `hashlib.pbkdf2_hmac` with SHA-256 and 600,000 iterations instead of `hashlib.scrypt`, which is missing from some Python builds. The 16-byte random salt and constant-time comparison are retained. Startup and login use the same function. This password hash is held only in memory for the running server; no stored database hashes need conversion, and your MySQL passwords are unaffected.

For an existing installation encountering `AttributeError: module 'hashlib' has no attribute 'scrypt'`, stop the server, replace only `app.py` with the corrected file, and restart using your usual command. This preserves any SQL or student Python work you have added locally. No dependency installation or SQL change is required for this fix on a Python build with PBKDF2 available.

If `pbkdf2_hmac` is also unavailable, startup now explains the requirement. Check that your project does not contain a local `hashlib.py` file or `hashlib` folder hiding the standard library, and use a supported Python installation built with OpenSSL. Do not replace password hashing with plain SHA-256.

## Preview without a database

```bash
python app.py --preview
```

This needs no installed Python packages. Alternatively, open `Sillage_Preview.html` directly in your browser. The preview includes 208 bottle variants from the supplied dump. It supports the carousel, grouping, product details, catalogue filtering, a tab-local bag, and all public tab/form layouts. The team-only Restock form is available in the running Python app after staff sign-in. It deliberately does not fake successful registration, purchases, reports, sample requests, or login.

## Connected features

| Website action | Existing student code | Behavior |
| --- | --- | --- |
| Search by note | `student_code/searches.py` → `get_fragrances_with_note` | Runs the original exact-note WHERE/JOIN query with the existing parameter tuple. |
| Find in Stores | `student_code/reports.py` → `stock_location` | Runs the supplied exact-name JOIN query, showing positive stock in descending order. |
| Top Sellers | `student_code/reports.py` → `top_seller` | Runs the supplied GROUP BY/COUNT query for the top five variants. |
| Add Fragrance | `student_code/fragrances.py` → `insert_fragrance` | Connected: your supplied five-column INSERT, commit, and returned ID; customer/admin profile selected from the server session. |
| Add Brand | `student_code/brands.py` → `insert_brand` | Connected: staff-only admin profile, existing country ID, supplied INSERT/commit, returned ID, and catalogue refresh. |
| Team desk → Restock | `student_code/inventory.py` → `restock` | Runs the supplied standalone UPDATE unchanged; adds bottles to an existing store/fragrance row. |
| Ingredient report | `student_code/searches.py` → `get_fragrances_with_natural_status` | Displays the original grouped classification, including unknown/mixed results. |
| Register customer | `student_code/customers.py` → `register_customer` | Creates Person and Customer through the original transaction. Duplicate email/invalid country use the student's friendly error. |
| Team desk → Revenue → All stores | `student_code/revenue.py` → `get_gross_revenue` | Runs the original total revenue query. |
| Team desk → Revenue → Store city | `student_code/revenue.py` → `get_specific_revenue` | Runs the existing subquery for a city. A duplicate-city subquery error receives a friendly message. |
| Team desk → Purchase follow-up | `student_code/discount.py` → `get_users_with_discount` | Lists purchase rows older than a chosen date where the current fragrance price exceeds $200. |
| Team desk → Record purchase | `student_code/transactions.py` → `record_purchase` | Decreases stock and records one bottle using the original COMMIT/ROLLBACK logic. |

The public catalogue uses nine **unchanged** `SELECT * FROM ...;` statements from your `scent_DB_milestone.sql`. They are stored in `data/student_catalog_reads.json`. The adapter exposes only product, brand, note, ingredient, country, store, and inventory fields. It never exposes Person, Customer, or Purchase_Record through the public catalogue. House/ingredient browsing and catalogue name filtering operate on this catalogue in the browser; they are not additional SQL features.

## What changed

- `customers.py` and `transactions.py` are byte-for-byte copies of the uploaded `(1).py` files, with simpler filenames.
- `searches.py`, `revenue.py`, and `discount.py` accept a connection as an argument instead of connecting at import time. Browser inputs are passed explicitly, so importing a module no longer opens a terminal prompt, prints a report, closes a global connection, or stores a database password.
- `reports.py` contains the supplied report functions verbatim. `inventory.py` contains your new Restock function unchanged. `fragrances.py` now contains your supplied INSERT body with only the connection variable adapted. `brands.py` likewise contains the corrected user-supplied INSERT body with only the connection variable adapted. The consolidated terminal source is preserved for review, including the new get_country_id helper and the remaining country-creation limitations.
- SQL string contents and existing `cursor.execute(...)` argument expressions are unchanged. The duplicate revenue function in the discount script is omitted because the revenue module already provides it. Presentation-only print helpers are omitted.
- The new `service.py` connects these existing functions to web requests. Each operation gets its own connection, which closes afterward. Customer and purchase functions retain control of their transactions.
- The new `app.py` supplies the local HTTP server, JSON routes, form validation, browser sessions, CSRF checks, team-desk access, and friendly outer error handling. It uses the Python standard library. The only runtime package is your existing MySQL connector.
- `templates/index.html`, `static/style.css`, and `static/app.js` provide the website. No React build, Node server, or alternate database is needed.
- `data/preview_catalog.json` is a public-catalogue snapshot parsed from your upload; it contains no customer or purchase records.

The mockup's invented fragrances are replaced with your real catalogue. A carousel shows up to nine distinct fragrance names for its group; Explore opens all matching bottle sizes in the catalogue below. A pause control, responsive layout, keyboard controls, functional dialogs, and catalogue section were added. Inter is used if installed, with Arial/Helvetica fallbacks; exact font rendering may differ from the mockup.

## Brand table-name compatibility

Your supplied brand INSERT spells the table `BRAND`; the supplied schema uses `Brand`. The SQL is preserved exactly for attribution. On a case-sensitive server, make that spelling match your actual table before the live demonstration. Do not rename or recreate your populated table to work around this. A missing-table error receives a distinct message in the app. The full explanation is in `docs/CATALOG_SCRIPT_REVIEW.md`.

## Accounts and permissions

Read `docs/ACCOUNTS.md`. Existing features and the two new reports use the base configured application account. **Catalogue additions use separate profiles:** Add Fragrance uses admin for verified staff and customer for other visitors; Add Brand is staff-only and uses admin. Restock follows the existing Record Purchase model: staff-only in Python, with the base MySQL application account. The browser cannot choose the profile by submitting a role. The team-desk password is separate from all database passwords.

The Add Fragrance endpoint allows both access categories to reach the student database function; it does not pre-reject customers in Python. Only an actual MySQL permission exception on a customer insertion attempt produces your requested message: “It looks like you can't add a fragrance! Come into one of our stores, or email us, and we will try to get the fragrance for you!” Missing code/configuration and preview mode return unavailable instead of a fabricated denial. No customer request or email is created by that message.

Registration is not yet authentication. Your schema has customer identity rows but no password hashes or website-role records, and the supplied Python has no credential-verification function. Customer sign-in/history and checkout remain unavailable. A visitor cannot supply a customer ID to view someone else's purchases or buy on their behalf. Recording a purchase is available only through the team desk.

The bag is a browser-tab selection, with one entry per bottle variant. It does not reserve stock, process payments, or implement a multi-item checkout. The sample dialog does not collect personal data or promise a shipment because no sample-request backend was supplied.

## Verification

```bash
python -m unittest discover -s tests -v
python -m compileall -q app.py service.py student_code tests
```

64 HTTP/service/source tests cover anonymous vs staff access, browser-session isolation, CSRF, validation, registration/purchase argument mapping, new report routing, profile selection, spoofed role fields, exact refusal text, missing student implementation, preview behavior, public-data limits, restock validation/results/connection cleanup, brand access/error handling, and the actual brand and fragrance functions wired through HTTP and the service with database doubles, including adding a brand then using its returned ID for a fragrance. The suite also simulates a hashlib module without scrypt, verifies successful and unsuccessful team-desk logins, and checks the diagnostic when PBKDF2 is missing. These use service/connection doubles, **not MySQL**; the simulated error is not the assignment's permission demonstration.

The original vs adapted SQL strings and execute-call expressions were compared structurally, including the supplied report functions and latest fragrance INSERT. Both insertion bodies match their latest supplied versions after only renaming mysql_conn to connection; the AI-attribution comment on lastrowid is retained. `docs/source_verification.json` records the checks and source hashes; the registration and purchase files also match byte-for-byte. Python compilation and JavaScript syntax checks passed.

Live MySQL execution has not been tested from this workspace because your server connection is not available here. A local Chromium visual/interaction check was attempted, but this workspace prevented the browser process from launching. Complete the short manual checklist in `docs/TEAM_WORK.md` on your computer before your demo.

## AI use and team ownership

Suggested disclosure: “We used AI to implement the website interface and general web integration around our supplied database functions, and to identify remaining integration gaps. The existing SQL, parameterization, account SQL, and transaction bodies were reused without changes. AI also explained how to retrieve and return cursor.lastrowid for the webpage; that assistance is marked in the submitted fragrance function.” Review this sentence for your team's actual earlier AI use, including any seed-data assistance, before submission.

| Contributor | Work to confirm before submission |
| --- | --- |
| TJ Drape | Fill in the work actually completed. |
| Afonso Azevedo | Fill in the work actually completed. |
| John Markham | Fill in the work actually completed. |
| AI assistance | Website layout, browser interactions, general Python web integration, integration tests, and documentation. |

No schema changes were made in this integration. The uploaded `setup.sql` already differs from the older milestone schema (for example, longer email/fragrance fields and CHECK constraints); document those team changes accurately in your final submission.

## Current feature additions and ownership

`docs/FEATURE_ADDITIONS.md` lists the earlier stock/sales/fragrance changes. `docs/CATALOG_SCRIPT_REVIEW.md` covers Restock, Add Brand, and the supplied insertion-script defects. `docs/ADD_FRAGRANCE_TEAM_GUIDE.md` describes the connected function, five-field mapping, account configuration, real customer/admin permission demonstration, and separate country-creation limitations. `docs/Python_Adaptation_Diff.html` contains the earlier complete diffs plus dated addenda with exact functional diffs for subsequent additions.

The two additional role-account SQL files under `sql/` are unchanged copies of your supplied scripts for reference. Review the actual effective permissions and password literals before submission; these scripts are not executed by the website. No new grant SQL or INSERT statement has been authored here; the connected brand and fragrance INSERTs and commits come from your latest supplied functions.
