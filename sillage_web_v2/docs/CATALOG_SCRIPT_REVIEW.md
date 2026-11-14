# Brand and fragrance insertion connected

## Current feature status

| Feature | Status | Database implementation |
| --- | --- | --- |
| Restock | Connected in Team Desk; verified staff and live mode required. | Your supplied `student_code/inventory.py` function remains unchanged. |
| Add Fragrance | Connected and enabled for existing brands. Configure customer/admin database profiles before use. | Your latest `insert_fragrance` is adapted in `student_code/fragrances.py`. SQL, execute tuple, commit, generated ID, cursor close, and return are preserved. |
| Add Brand | Connected and enabled for existing countries. Verified staff and the admin database profile are required. | Your latest insert_brand is adapted in `student_code/brands.py`, with SQL, bindings, commit, ID, close, and return retained. Check the table-name case described below. |
| Create Country | Not offered by the website. | The supplied terminal helper still has SQL, binding, saving, and return problems. |

The latest full user script, updated with your newest get_country_id and insert_brand functions, is preserved as `docs/supplied_catalog_script.txt`. Older text snapshots are historical references, including `supplied_catalog_script_before_saved_insert.txt`. The website imports the adapted brand and fragrance functions, not the terminal script or its country/input helpers.

## What is now fixed in your supplied insertion functions

The SQL directly inserts the selected Brand_ID, so the earlier name-versus-ID mismatch and nested query are gone. The five execute values match the five columns. You added a commit and returned the generated ID after the commit. Your `all_brands` helper is now present. Your newest insert_brand now takes country_id, binds the name and ID in column order, commits, and returns its generated ID. The earlier brand parameter-order, country-value-type, missing-commit, and missing-ID findings are resolved for the website.

The AI disclosure comment on `cursor.lastrowid` is preserved exactly. The SQL, parameter tuple, and commit come from your latest submission; the earlier advice about obtaining the ID is separately acknowledged by that comment.

## Exact web adaptation

The importable function is now:

```python
def insert_fragrance(connection, name, strength, size, brand, price):
```

This is an interface change. The function body changes only `mysql_conn` to the supplied `connection` in the cursor and commit calls. An AST comparison verifies that every other statement in the body is unchanged. The function keeps its `insert_fragrance` name and the argument names used in your existing execute tuple. `ADD_FRAGRANCE_READY` is now True.

| Website field | Function argument | SQL column |
| --- | --- | --- |
| fragrance_name | name | Fragrance_Name |
| strength | strength | Strength |
| size | size | Size |
| price | price | Price |
| brand_id | brand | Brand_ID |

`service.py` passes the trusted connection and maps the form's field names to these arguments. The form collects an existing brand ID, so it does not call terminal `get_brand()` or attempt automatic brand creation. The website validates name/strength lengths, positive integer size/brand ID, and a nonnegative price with at most two decimal places. MySQL remains authoritative for foreign keys, unique variants, and other constraints.

The earlier optional Perfumer ID and Catalogue Notes inputs were removed because the supplied five-column INSERT does not store them. Requests containing nonempty values for these old fields are rejected rather than silently dropping user input. Their database columns remain unchanged and receive their existing defaults. Scent-note associations, ingredients, and store inventory are separate actions.

Module-level connection creation, embedded credentials, terminal input helpers, and the final global connection close are not included in the importable module. Startup prompts still collect the configured database credentials. Each web request calls the function explicitly and the service closes its connection afterward. No new SQL, parameter-binding implementation, commit/rollback logic, or grant statements were authored for this adaptation.

## Brand function adaptation

```python
def insert_brand(connection, country_id, name):
```

The form sends an existing integer country_id and a name of at most 60 characters. `service.py` passes these as keyword arguments to the supplied function on the admin connection. The body changes only mysql_conn to connection in cursor and commit calls. ADD_BRAND_READY is now True. The SQL remains exactly as you supplied it, including the uppercase BRAND identifier, and the tuple remains `(name, country_id)`.

The website already has country IDs from its existing catalogue query, so it does not call get_country_id or get_country and does not add a new lookup query. Your helper remains in the source record for the terminal workflow. After a successful brand insert, the page displays the ID and refreshes the house list used by Add Fragrance.

## Table-name compatibility and separate terminal-helper limitations

| Location | Current issue | Scope / action |
| --- | --- | --- |
| INSERT INTO BRAND | The supplied schema names the table Brand. MySQL can treat table-name case as significant, depending on server configuration. | The supplied SQL is preserved exactly. On a case-sensitive server, change its identifier to match the existing Brand table before your demo. Do not rename or recreate populated tables. A missing-table error receives a distinct app message. |
| create_country SQL | The statement has no value placeholder and does not specify the correct columns for the supplied schema. | If you want a separate new-country feature, supply the corrected SQL. The current website selects existing countries only. |
| create_country parameters | `(country)` is a string, not a one-item parameter tuple. | Correct the parameter sequence when implementing country creation. |
| create_country saving/return | It has no commit and returns None. | Implement the intended saving/return behavior if this optional terminal path is needed. |
| get_country_id and get_brand_id | Each indexes its fetched row without handling a missing match. | If retaining the terminal helpers, handle fetchone returning None. The web forms use existing IDs directly and do not invoke these helpers. |
| Terminal default arguments | Input and lookup helpers run when the insertion functions are defined. They do not collect fresh values on each call. | The web adaptation already replaces these defaults with explicit request values. |
| Standalone script ending | The supplied full script defines insert_fragrance and closes the connection without explicitly calling it. | The web routes explicitly call the adapted functions. If using the terminal script separately, provide the invocation before closing. |

These terminal-helper issues do not block brand/fragrance insertion through the website using existing countries. The BRAND/Brand spelling does need to match on a case-sensitive database server. [MySQL documents how table-name case depends on server configuration](https://dev.mysql.com/doc/refman/8.4/en/identifier-case-sensitivity.html).

## Run and demonstrate Add Brand and Add Fragrance

Start the extracted project with:

```bash
python app.py --staff --fragrance-accounts
```

Enter the base application, customer, and admin MySQL passwords when prompted, plus a separate website team-desk password. The role usernames default to customer and admin, with MYSQL_CUSTOMER_USER and MYSQL_ADMIN_USER overrides. Configure the actual grants yourself; the app does not create users or run SQL setup files. Do not rerun the destructive setup dump on your populated database.

1. Sign in to Team Desk and open Add Brand. Select an existing country, enter a new brand name, and submit. Confirm the returned Brand_ID and saved row in Workbench. The new house should appear in Add Fragrance after refresh.
2. Sign out, then pick that brand or another existing brand and a new fragrance/strength/size combination.
3. Without signing in to Team Desk, submit Add Fragrance. The function attempts its real INSERT using the customer connection. If MySQL returns error 1142 or 1143, the website displays exactly: “It looks like you can't add a fragrance! Come into one of our stores, or email us, and we will try to get the fragrance for you!”
4. Verify that the refused attempt added no row. A simulated unit-test error is not the assignment's live permission demonstration.
5. Sign in to Team Desk and submit valid test values. The server selects the admin connection. The function commits and returns its new ID; the website displays that ID and refreshes the catalogue.
6. Verify the saved column values in Workbench. Repeating the same brand/name/strength/size combination should produce a duplicate message.
7. Sign out and repeat with another valid combination to confirm the customer connection is selected again. Browser-supplied role/user values cannot select an account.

If your customer account is over-granted, MySQL may accept and save its INSERT. The app does not fabricate a refusal. Existing broad grants or roles must be reviewed by your team.

Adding a fragrance does not add a Store_Inventory row. Restock only updates an existing store/fragrance row, including a row currently holding zero bottles. New store/fragrance associations remain a separate team-owned database action.

## Verification and limits

64 backend tests passed using service/connection doubles. New tests exercise the HTTP route, actual service adapter, and actual student fragrance function together: admin success/returned ID, customer permission failure with exact text, duplicate/foreign-key errors, failed commit, and no admin retry. Additional tests exercise actual brand insertion, duplicate/foreign-key/permission/missing-table errors, failed commit, staff enforcement, and inserting a brand then passing its returned ID into a fragrance insertion. Source-preservation tests compare both supplied and adapted insertion bodies after renaming only the connection variable. Python compilation and JavaScript syntax checks passed.

No live MySQL test against your server was possible here. Browser visual checks remain local because Chromium could not launch in this workspace during the earlier checks. The existing styling is retained.

The supplied function has no local try/finally or explicit rollback on exceptions; this behavior was not rewritten. The service closes the connection on failure. Connection loss during commit can leave the save outcome uncertain, so the website asks you to check whether the row exists before resubmitting. It never automatically retries an INSERT.

## Files that interact with the database

- `student_code/brands.py`: newly connected adapted function; executes your latest supplied brand INSERT and commit.
- `student_code/fragrances.py`: previously connected fragrance INSERT; unchanged by the brand update.
- `service.py`: calls insert_brand on the admin connection. Existing fragrance profile selection is unchanged. It adds no SQL or transaction statements.
- `student_code/inventory.py` and all other prior student database modules: unchanged by this update.
- `app.py`: HTTP/session validation and messages; it does not connect to MySQL or execute SQL.
- SQL files: all unchanged; no new SQL file was created.

## References

- [Connector/Python lastrowid](https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlcursor-lastrowid.html)
- [Connector/Python insertion and commit](https://dev.mysql.com/doc/connector-python/en/connector-python-example-cursor-transaction.html)
- [MySQL table-name case sensitivity](https://dev.mysql.com/doc/refman/8.4/en/identifier-case-sensitivity.html)
- [Python default arguments](https://docs.python.org/3/tutorial/controlflow.html#default-argument-values)
