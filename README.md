# Smells Like a Database

**CS317 Files and Database Systems | Fall 2026**  
**Team:** Afonso Azevedo, TJ Drape, and John Markham

## Project overview

Smells Like a Database is a MySQL-backed application for a fictional niche fragrance stockist. Shoppers can search fragrances by their scent notes and find stores with available inventory. Store staff can register customers, update inventory, record purchases, and use reports to understand sales.

The database relates fragrances to brands, perfumers, ingredients, scent notes, store locations, customers, and purchases. The design contains 13 tables, including linking tables for fragrances and notes, fragrances and ingredients, and inventory held at individual stores.

## Requirements

- MySQL 8.0 or later, with a local MySQL server and a MySQL client or MySQL Workbench.
- Python 3 and the `mysql-connector-python` package for the Python database modules.
- !!!!! **Before submission:** TJ must confirm the final application's Python version, any additional packages, and the exact launch command. If applicable we should add a `requirements.txt` file with all dependencies.!!!!!

## Database setup

From the project directory, run the schema and sample-data script using an administrative MySQL account:

```bash
mysql -u root -p < sql/setup.sql
```

This creates the `scent_db` database, its tables, relationships, constraints, and sample data.

The application uses the limited account defined in `sql/account.sql`. Set an appropriate local password for `scent_app` when preparing the account script. Run the account script as a MySQL administrator:

```bash
mysql -u root -p < sql/account.sql
```

The `scent_app` account is granted SELECT access for reports and searches, INSERT on `Person`, `Customer`, and `Purchase_Record`, and UPDATE on `Store_Inventory`. It has no DELETE privilege. The application should connect through this account rather than through `root` or an administrative user.

## Running the application

**!!!!!We have to complete this section after TJ uploads the tested application.!!!!!!**

For the existing Python modules, an isolated environment can be set up with:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install mysql-connector-python
```

- **Final application entry point:** [TJ: exact file and launch command]
- **Additional dependencies:** [TJ: confirm and list]
- **Browser address, if it runs as a website:** [TJ: confirm]
- **Connection process:** [TJ: confirm how the application asks for the `scent_app` password]
- **Any special configuration or environment variables:** [TJ: confirm]

## Application features

The repository's Python modules contain database operations supporting the seven required categories. !!!!!!**Check this table against the final application interface before submission** so that each row describes a separate action a user can actually perform.!!!!!!

| Requirement | User action | Existing Python implementation |
| --- | --- | --- |
| Search (`WHERE`) | Search fragrances by scent note | `python/searches.py` |
| Combine related tables (`JOIN`) | Find stores that have a fragrance in stock | `python/storequery.py` |
| Summary (`GROUP BY`) | View the five best-selling fragrances | `python/storequery.py` |
| Subquery | View revenue for a selected city | `python/revenue.py` |
| Add (`INSERT`) | Register a customer | `python/customers.py` |
| Change (`UPDATE`) | Restock inventory at a store | `python/inventory.py` |
| Transaction | Record a purchase and reduce available inventory | `python/transactions.py` |

For the purchase operation, the database changes are committed together when successful and rolled back if the operation fails. MySQL constraints include a UNIQUE email for `Person`, foreign keys between related tables, and checks preventing negative prices or inventory.

**!!!!!Before submission:** confirm that the application also demonstrates a clear error when a constraint rejects an operation and that MySQL refuses a separate operation because `scent_app` lacks the required permission. These demonstrations do not count as two of the seven features.!!!!!

## Changes since the earlier database milestone

Comparing the earlier `sql/scent_DB_milestone.sql` with the current `sql/setup.sql`, the team retained the 13-table relational design and strengthened several definitions:

- Increased some text-field lengths, including `Fragrance.Fragrance_Name` and `Person.Email`, to accommodate larger values.
- Added a composite uniqueness requirement for a fragrance's brand, name, strength, and size.
- Added checks requiring a positive fragrance size, nonnegative fragrance price, and nonnegative inventory quantity.
- Made additional important fields mandatory with `NOT NULL` constraints.
- Expanded the sample data to better support searches, inventory queries, and reports.

**Team confirmation:** make sure this summary also reflects any later schema changes in TJ's final application.

## AI use

As already documented in [`docs/AI_use.md`](docs/AI_use.md)
## Team contributions

All three members contributed to the group project. 

| Team member | Specific contributions |
| --- | --- |
| Afonso Azevedo | !!!|
| TJ Drape | !!! |
| John Markham | !!!|

## Presentation

The team will present the project overview, ER diagram, relational schema, and a short fragrance-related fact, followed by a live demonstration of the application.
