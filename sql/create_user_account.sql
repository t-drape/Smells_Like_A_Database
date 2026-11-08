
-- CS317 Final Project
-- Smells Like a Database

-- Replace the placeholder with a password

CREATE USER IF NOT EXISTS 'customer'@'localhost'
IDENTIFIED BY 'customer_user_password'; -- Right here

-- Allow searches and reports
GRANT SELECT ON scent_db.*
TO 'customer'@'localhost';

-- Allow customer registration
GRANT INSERT ON scent_db.Person
TO 'customer'@'localhost';

GRANT INSERT ON scent_db.Customer
TO 'customer'@'localhost';

-- Allow a customer to update their account
GRANT UPDATE ON scent_db.Customer
To 'customer'@'localhost';

-- Allow a customer to delete their account
GRANT DELETE ON scent_db.Customer
To 'customer'@'localhost';

-- Verify the account permissions
SHOW GRANTS FOR 'customer'@'localhost';
