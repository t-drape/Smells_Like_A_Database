# Stock report sales report and fragrance form additions

## Provenance and changed files

| File | Change | Database work authored by AI? |
| --- | --- | --- |
| `student_code/reports.py` | New file containing the user's stock_location and top_seller functions verbatim. | No; both SQL strings, parameter arguments, fetches, and cursor handling were supplied by the user. |
| `student_code/fragrances.py` | New function interface, readiness flag, and explicit NotImplementedError. | No INSERT, SQL parameter binding, commit, rollback, or grants supplied. Team must implement them. |
| `service.py` | Calls the two new report functions; exposes existing Brand data to the form; selects and closes the customer/admin connection for Add Fragrance. | Connection/routing boilerplate only. It does not save, commit, roll back, or retry the pending insert. |
| `app.py` | Adds report routes, fragrance form validation, trusted-session-based role selection, optional credential prompts, and differentiated error messages. | Web integration only; it does not execute SQL. |
| `templates/index.html` | Adds Collection, Find in Stores, Top Sellers, and Add Fragrance tabs. | No. |
| `static/app.js` | Adds keyboard-accessible tab behavior, report rendering, the fragrance form, and refresh behavior. | No SQL or database credentials in browser code. |
| `static/style.css` | Styles the tabs and forms within the existing design. | No. |
| `tests/test_web.py`, `tests/test_service.py` | Tests routing, authorization, input handling, error mapping, and profile selection with doubles. | No actual SQL or transaction implementation; simulated exceptions are not a real permission demo. |
| `sql/create_admin_account.sql`, `sql/create_user_account.sql` | Copies of the previously supplied scripts, included as reference. | No; copied unchanged. |

The previous adapted `searches.py`, `revenue.py`, and `discount.py` are unchanged by this addition. `customers.py` and `transactions.py` remain byte-identical to their originals. The original adaptation diff remains applicable; its new addendum records this addition.

## Query behavior preserved

Stock Location searches by exact Fragrance_Name, joins inventory and store data, excludes zero stock, and orders by descending bottle count. The query does not accept a Fragrance_ID, brand, strength, or size. A shared name can therefore return inventory from multiple variants or houses, and the same store can appear repeatedly. The website states this and displays each returned row; it does not aggregate or silently alter the query.

Top Sellers counts Purchase_Record rows grouped by Fragrance_ID and name, descending, limited to five. It counts variants separately, including when their displayed names match. With tied counts, the supplied SQL does not define a secondary order. The website does not claim that the report is lifetime revenue or combine equal names.

Brand choices for Add Fragrance come from the existing, unchanged catalogue table read. No extra SELECT was authored for that dropdown. The optional perfumer field accepts an ID because no additional lookup query was supplied; the database foreign key remains authoritative.

## Account routing

The older modules and two new reports still use the base account, default scent_app. Add Fragrance alone uses the configured customer profile for non-staff sessions and the admin profile for verified staff sessions. Neither role is taken from the submitted JSON. Missing configuration never falls back to the other profile or the base account.

The chosen profiles are the existing team-defined account names, with optional configuration overrides. The website changes no grants. The team owns effective-permission checks and any corrections to the supplied broad admin grants.

## Validation completed

36 Python HTTP/service tests passed using simulated database behavior. Python compilation and JavaScript syntax checks passed. The original-source preservation checks cover the older adapted functions and the two newly supplied report functions. No live MySQL test was possible from this workspace. Chromium again failed to launch because the workspace rejected a required socket operation, so browser layout and interaction verification still need a local run.

The Add Fragrance form currently returns unavailable until the team implements the function and enables its readiness flag. The exact customer refusal message has been tested against a simulated MySQL error, not demonstrated against your live server. Nothing in preview mode claims a successful write or a real database refusal.

## Team-desk password compatibility correction

Only `app.py` and `tests/test_web.py` contain functional code changes for this correction. The password digest uses PBKDF2-HMAC-SHA256 (600,000 iterations) instead of scrypt. The salt, password comparison, session behavior, and MySQL credential handling are retained. Startup reports an actionable error if PBKDF2 is unavailable. Two regression tests cover login with a hashlib module lacking scrypt and startup when PBKDF2 is also missing. README and the adaptation report document the correction. All 36 tests pass; the database adapter, student modules, and SQL files are unchanged from the preceding download.

## Restock and Add Brand update — November 13, 2026

Restock is connected unchanged in `student_code/inventory.py`. `service.py` calls it through the base connection, and `app.py` validates positive integer inputs and requires staff authentication and CSRF. The Team Desk form displays the current inventory and refreshes it after a successful update.

Add Brand now has a collection tab and Team Desk shortcut. `student_code/brands.py` is a new, explicitly unfinished interface for the student-owned insertion function. `service.py` selects only the configured admin connection; `app.py` requires staff authentication and validates a 60-character brand name and existing country ID. The current catalogue reads provide all dropdown choices. No new lookup SQL was authored.

`templates/index.html` and `static/app.js` contain the UI changes. The existing styling is reused without changes. The previous Add Fragrance implementation scaffold is unchanged, and the new supplied insertion script is stored for review as `docs/supplied_catalog_script.txt`, not imported. The complete issue checklist is in `docs/CATALOG_SCRIPT_REVIEW.md`.

The current suite has 51 passing tests using service/connection doubles. Python compilation and JavaScript syntax checks passed. No live MySQL execution or successful browser visual test was possible in this workspace. The earlier test counts above describe the preceding versions.

## Fragrance INSERT activation — latest complete user submission

The latest user-supplied fragrance function now inserts Brand_ID directly, commits, obtains lastrowid, closes its cursor, and returns the ID. This body is preserved in `student_code/fragrances.py`; only the connection variable and required function parameters are adapted. The function remains named insert_fragrance. Its AI-attribution comment is retained, and ADD_FRAGRANCE_READY is True.

`service.py` maps the five validated web fields to the function's existing argument names using the trusted customer/admin connection. `app.py` accepts the five supported fields, rejects nonempty old optional fields, and gives a useful connection-loss message without retrying. `static/app.js` removes the unsupported perfumer/notes controls. New tests cover the HTTP/service/function chain and exact source preservation. The suite has 57 passing tests using doubles. No live MySQL or browser visual result is claimed.

Add Brand remains a scaffold with ADD_BRAND_READY False; its parameter order, country-ID input, and returned-ID contract still need correction. All SQL files and other student modules are unchanged by this activation. The older sections above describe earlier versions; current instructions are in ADD_FRAGRANCE_TEAM_GUIDE.md and CATALOG_SCRIPT_REVIEW.md.

## Brand INSERT activation — November 14, 2026

The latest user function now accepts country_id, binds `(name, country_id)`, commits, returns cursor.lastrowid, and closes the cursor. Its body is copied into `student_code/brands.py` with only mysql_conn renamed to connection, required web arguments, and ADD_BRAND_READY True. `service.py` calls insert_brand with the existing dropdown's country ID on the admin connection. No new lookup query is needed. The provided get_country_id helper is preserved in the source record but is not executed by the web route.

The supplied uppercase BRAND identifier is preserved exactly. It differs from Brand in the supplied schema and needs a matching spelling on case-sensitive servers. `app.py` now distinguishes missing-table errors and connection loss during brand creation. There is no automatic retry or credential fallback.

64 backend tests pass using doubles, including the actual brand insertion chain, permissions, commit failures, source preservation, and creating a brand then passing its returned ID into a fragrance insertion. All other student functions, including fragrance and Restock, are unchanged. All SQL files and catalogue reads are unchanged. Current documentation supersedes the earlier pending-brand notes above. Live MySQL testing remains local.
