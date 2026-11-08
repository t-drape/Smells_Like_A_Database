
-- CS317 Final Project
-- Smells Like a Database

-- Replace the placeholder with a password

-- This creates something akin to a "view" for the DB
-- Many different users an use the same view, DON'T run CREATE USER for every user
CREATE USER IF NOT EXISTS 'admin'@'localhost'
IDENTIFIED BY 'admin_user_password'; -- Right here

-- Allow searches and reports
GRANT SELECT ON scent_db.*
TO 'admin'@'localhost';

-- Allow INSERT for creating user accounts, brands, perfumes, etc.
GRANT INSERT ON scent_db.*
TO 'admin'@'localhost';

-- Allow updating for admin
GRANT UPDATE ON scent_db.*
TO 'admin'@'localhost';

-- DELETE privliges granted for admin
GRANT DELETE ON scent_db.*
TO 'admin'@'localhost';

-- Verify the account permissions
SHOW GRANTS FOR 'admin'@'localhost';
