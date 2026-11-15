-- Fresh database initialization INCLUDING large synthetic demo data.
--
-- WARNING: setup.sql DROPS AND RECREATES all scent_db tables. This destroys
-- existing customer registrations, purchases, edits, and inventory changes.
-- Back up any database you care about before executing this file.
--
-- Run from the sillage_web_v2 directory using the MySQL command-line client:
--   mysql -u root -p < sql/initialize_demo.sql
--
-- SOURCE is a MySQL CLIENT command, not server SQL. Use the command above,
-- not the SQL editor in MySQL Workbench, to run this two-file initialization.
SOURCE sql/setup.sql
SOURCE sql/seed_synthetic.sql
