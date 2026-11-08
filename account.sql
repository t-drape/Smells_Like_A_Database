
-- CS317 Final Project
-- Smells Like a Database

-- Replace the placeholder with a password

CREATE USER IF NOT EXISTS 'scent_app'@'localhost'
IDENTIFIED BY 'REPLACE_WITH_YOUR_PASSWORD'; -- Right here

-- Allow searches and reports
GRANT SELECT ON scent_db.*
TO 'scent_app'@'localhost';

-- Allow customer registration
GRANT INSERT ON scent_db.Person
TO 'scent_app'@'localhost';

GRANT INSERT ON scent_db.Customer
TO 'scent_app'@'localhost';

-- Allow recording purchases
GRANT INSERT ON scent_db.Purchase_Record
TO 'scent_app'@'localhost';

-- Allow inventory updates
GRANT UPDATE ON scent_db.Store_Inventory
TO 'scent_app'@'localhost';

-- No DELETE privileges are granted

-- Verify the account permissions
SHOW GRANTS FOR 'scent_app'@'localhost';
