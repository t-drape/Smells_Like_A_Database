
-- =========================================================
-- VERIFICATION QUERIES
-- Each query shows that a table, key or relationship works as intended
-- =========================================================
USE scent_db;

-- 1. All 13 tables exist
SHOW TABLES;

-- 2. Row count for every table (expected values in comments)
SELECT 'Country' AS table_name, COUNT(*) AS row_count FROM Country                          -- 5
UNION ALL SELECT 'Person',                   COUNT(*) FROM Person                          -- 30 (22 perfumers + 8 customers)
UNION ALL SELECT 'Perfumer',                 COUNT(*) FROM Perfumer                        -- 22
UNION ALL SELECT 'Customer',                 COUNT(*) FROM Customer                        -- 8
UNION ALL SELECT 'Brand',                    COUNT(*) FROM Brand                           -- 5
UNION ALL SELECT 'Store',                    COUNT(*) FROM Store                           -- 5
UNION ALL SELECT 'Fragrance',                COUNT(*) FROM Fragrance                       -- 208
UNION ALL SELECT 'Fragrance_Note',           COUNT(*) FROM Fragrance_Note                  -- 193
UNION ALL SELECT 'Fragrance_Ingredient',     COUNT(*) FROM Fragrance_Ingredient            -- 17
UNION ALL SELECT 'Fragrance_Has_Note',       COUNT(*) FROM Fragrance_Has_Note              -- 2018
UNION ALL SELECT 'Fragrance_Has_Ingredient', COUNT(*) FROM Fragrance_Has_Ingredient        -- 115
UNION ALL SELECT 'Store_Inventory',          COUNT(*) FROM Store_Inventory                 -- 25
UNION ALL SELECT 'Purchase_Record',          COUNT(*) FROM Purchase_Record;                -- 20

-- 3. Every foreign key in the database (what points to what)
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'scent_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- 4. One-to-many: Brand -> Fragrance (products and distinct scents per brand)
SELECT b.Name AS brand, c.Name AS country,
       COUNT(*) AS products, COUNT(DISTINCT f.Fragrance_Name) AS scents
FROM Brand b
JOIN Country c   ON c.Country_ID = b.Country_ID
JOIN Fragrance f ON f.Brand_ID = b.Brand_ID
GROUP BY b.Name, c.Name
ORDER BY products DESC;

-- 5. Subtype: Perfumer -> Fragrance (who created the most scents)
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS perfumer,
       COUNT(DISTINCT f.Fragrance_Name) AS scents_created
FROM Perfumer pf
JOIN Person p    ON p.Person_ID = pf.Person_ID
JOIN Fragrance f ON f.Perfumer_ID = pf.Person_ID
GROUP BY perfumer
ORDER BY scents_created DESC
LIMIT 10;

-- 6. Many-to-many: Fragrance <-> Note (the notes of one product)
SELECT f.Fragrance_Name, f.Strength, f.Size, n.Note_Name
FROM Fragrance f
JOIN Fragrance_Has_Note fn ON fn.Fragrance_ID = f.Fragrance_ID
JOIN Fragrance_Note n      ON n.Note_ID = fn.Note_ID
WHERE f.Fragrance_Name = 'Sauvage Eau de Toilette' AND f.Size = 100;

-- 7. Many-to-many, other direction: the most-used notes across scents
SELECT n.Note_Name, COUNT(DISTINCT f.Fragrance_Name) AS scents
FROM Fragrance_Note n
JOIN Fragrance_Has_Note fn ON fn.Note_ID = n.Note_ID
JOIN Fragrance f           ON f.Fragrance_ID = fn.Fragrance_ID
GROUP BY n.Note_Name
ORDER BY scents DESC
LIMIT 10;

-- 8. Many-to-many: Fragrance <-> Ingredient (natural vs synthetic per scent)
SELECT f.Fragrance_Name,
       GROUP_CONCAT(DISTINCT CASE WHEN i.Is_Natural THEN i.Ingredient_Name END SEPARATOR ', ')     AS natural_ingredients,
       GROUP_CONCAT(DISTINCT CASE WHEN NOT i.Is_Natural THEN i.Ingredient_Name END SEPARATOR ', ') AS synthetic_ingredients
FROM Fragrance f
JOIN Fragrance_Has_Ingredient fi ON fi.Fragrance_ID = f.Fragrance_ID
JOIN Fragrance_Ingredient i      ON i.Ingredient_ID = fi.Ingredient_ID
GROUP BY f.Fragrance_Name;

-- 9. Store inventory with product details, lowest stock first (0 = sold out)
SELECT s.City, b.Name AS brand, f.Fragrance_Name, f.Size, si.Num_Bottles
FROM Store_Inventory si
JOIN Store s     ON s.Store_ID = si.Store_ID
JOIN Fragrance f ON f.Fragrance_ID = si.Fragrance_ID
JOIN Brand b     ON b.Brand_ID = f.Brand_ID
ORDER BY si.Num_Bottles, s.City;

-- 10. Full purchase history (joins 4 tables)
SELECT pr.Purchase_ID, pr.Purchase_Date,
       CONCAT(p.First_Name, ' ', p.Last_Name) AS customer,
       s.City AS store, f.Fragrance_Name, f.Size, f.Price
FROM Purchase_Record pr
JOIN Person p    ON p.Person_ID = pr.Customer_ID
JOIN Store s     ON s.Store_ID = pr.Store_ID
JOIN Fragrance f ON f.Fragrance_ID = pr.Fragrance_ID
ORDER BY pr.Purchase_Date;

-- 11. Revenue per store
SELECT s.City, COUNT(*) AS sales, SUM(f.Price) AS revenue_usd
FROM Purchase_Record pr
JOIN Store s     ON s.Store_ID = pr.Store_ID
JOIN Fragrance f ON f.Fragrance_ID = pr.Fragrance_ID
GROUP BY s.City
ORDER BY revenue_usd DESC;

-- 12. Purchases per customer (LEFT JOIN keeps Noah, who has 0)
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS customer, COUNT(pr.Purchase_ID) AS purchases
FROM Customer c
JOIN Person p ON p.Person_ID = c.Person_ID
LEFT JOIN Purchase_Record pr ON pr.Customer_ID = c.Person_ID
GROUP BY customer
ORDER BY purchases DESC;

-- 13. Customers who bought in a store outside their home country
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS customer,
       hc.Name AS home_country, sc.Name AS store_country, s.City
FROM Purchase_Record pr
JOIN Person p   ON p.Person_ID = pr.Customer_ID
JOIN Country hc ON hc.Country_ID = p.Country_ID
JOIN Store s    ON s.Store_ID = pr.Store_ID
JOIN Country sc ON sc.Country_ID = s.Country_ID
WHERE p.Country_ID <> s.Country_ID;

-- 14. Data-quality checks: every query below should return 0
SELECT COUNT(*) AS purchases_of_products_not_stocked
FROM Purchase_Record pr
LEFT JOIN Store_Inventory si ON si.Store_ID = pr.Store_ID AND si.Fragrance_ID = pr.Fragrance_ID
WHERE si.Store_ID IS NULL;

SELECT COUNT(*) AS people_who_are_neither_perfumer_nor_customer
FROM Person p
WHERE p.Person_ID NOT IN (SELECT Person_ID FROM Perfumer)
  AND p.Person_ID NOT IN (SELECT Person_ID FROM Customer);

SELECT COUNT(*) AS fragrances_without_notes
FROM Fragrance f
WHERE f.Fragrance_ID NOT IN (SELECT Fragrance_ID FROM Fragrance_Has_Note);

-- =========================================================
-- CONSTRAINT TESTS (commented out so the script runs cleanly)
-- Each was run during development and failed with the error shown.
-- To re-test: remove the -- and run ONE line at a time.
-- =========================================================
-- Duplicate UNIQUE email                  -> Error 1062
-- INSERT INTO Person (First_Name, Last_Name, Email) VALUES ('Test', 'Dup', 'emma.laurent@example.com');
-- Foreign key to a country that does not exist -> Error 1452
-- INSERT INTO Store (City, Street, Country_ID) VALUES ('Nowhere', '1 Main St', 999);
-- A customer credited as a perfumer (FK checks Perfumer, not Person) -> Error 1452
-- INSERT INTO Fragrance (Fragrance_Name, Strength, Size, Price, Perfumer_ID, Brand_ID) VALUES ('Fake', 'Eau de Parfum', 50, 90, 23, 1);
-- Same product twice (composite UNIQUE brand + name + strength + size) -> Error 1062
-- INSERT INTO Fragrance (Fragrance_Name, Strength, Size, Price, Brand_ID) SELECT 'Aventus', 'Eau de Parfum', 100, 1, Brand_ID FROM Brand WHERE Name = 'Creed';
-- Negative price (CHECK)                  -> Error 3819
-- INSERT INTO Fragrance (Fragrance_Name, Strength, Size, Price, Brand_ID) VALUES ('Bad Price', 'Eau de Parfum', 50, -5, 1);
-- Same note linked twice to one fragrance (composite PK) -> Error 1062
-- INSERT INTO Fragrance_Has_Note (Fragrance_ID, Note_ID) SELECT Fragrance_ID, Note_ID FROM Fragrance_Has_Note LIMIT 1;
-- Negative stock (CHECK)                  -> Error 3819
-- UPDATE Store_Inventory SET Num_Bottles = -1 WHERE Store_ID = 1;
-- Deleting a fragrance that has purchases (FK protects child rows) -> Error 1451
-- DELETE FROM Fragrance WHERE Fragrance_Name = 'Aventus';