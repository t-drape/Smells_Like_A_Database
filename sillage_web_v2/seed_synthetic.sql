-- Synthetic SILLAGE demo data for the existing scent_db schema (MySQL 8.0+).
--
-- Intended to run AFTER sql/setup.sql, which contains the real catalogue and
-- small original sample. This script does not DROP tables or alter the schema.
-- It adds 1,500 fictional customers, additional store stock, and 10,000 sales.
-- Names are invented combinations; every email uses the reserved example.com
-- domain. Dates cover approximately the 21 months before initialization.
--
-- Run from the sillage_web_v2 directory after loading setup.sql:
--   mysql -u root -p scent_db < sql/seed_synthetic.sql
-- For a fresh reset and both scripts in one command, use initialize_demo.sql.
--
-- Run ONCE on a freshly initialized database. Re-running intentionally fails
-- on the fixed synthetic Person_ID values instead of adding duplicates.

USE `scent_db`;

-- A predictable 1..10,000 sequence, built using only standard MySQL SQL.
-- The temporary tables disappear when the MySQL connection closes.
CREATE TEMPORARY TABLE `_synthetic_digit` (
    `d` TINYINT UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=MEMORY;

INSERT INTO `_synthetic_digit` (`d`)
VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

CREATE TEMPORARY TABLE `_synthetic_sequence` (
    `n` INT NOT NULL PRIMARY KEY
) ENGINE=MEMORY;

INSERT INTO `_synthetic_sequence` (`n`)
SELECT 1 + units.d + 10 * tens.d + 100 * hundreds.d + 1000 * thousands.d
FROM `_synthetic_digit` AS units
CROSS JOIN `_synthetic_digit` AS tens
CROSS JOIN `_synthetic_digit` AS hundreds
CROSS JOIN `_synthetic_digit` AS thousands;

-- A transaction makes the extra inserts all-or-nothing if the client stops
-- at an error. The baseline setup.sql is intentionally outside this transaction.
START TRANSACTION;

-- 1,500 synthetic people. IDs 50001..51500 avoid the original Person IDs.
-- Country IDs 1..5 are the countries in the existing catalogue.
INSERT INTO `Person` (`Person_ID`, `First_Name`, `Last_Name`, `Email`, `Country_ID`)
SELECT
    50000 + n,
    ELT(1 + MOD(n * 13, 24),
        'Alex', 'Amelia', 'Ana', 'Beatriz', 'Daniel', 'Emma',
        'Ethan', 'Fatima', 'Gabriel', 'Hugo', 'Isabella', 'Joao',
        'Leila', 'Lucas', 'Maya', 'Miguel', 'Noah', 'Olivia',
        'Rafael', 'Sofia', 'Thomas', 'Yasmin', 'Zoe', 'Mateo'),
    ELT(1 + MOD(n * 7 + FLOOR(n / 24), 24),
        'Azevedo', 'Bennett', 'Chen', 'Costa', 'Dubois', 'Fernandez',
        'Ferreira', 'Garcia', 'Johnson', 'Kim', 'Laurent', 'Martins',
        'Moreau', 'Murphy', 'Oliveira', 'Patel', 'Pereira', 'Rossi',
        'Silva', 'Smith', 'Sousa', 'Taylor', 'Walker', 'Wilson'),
    CONCAT('sillage-demo-', LPAD(n, 5, '0'), '@example.com'),
    CASE
        WHEN MOD(CRC32(CONCAT('country-', n)), 100) < 25 THEN 1 -- France
        WHEN MOD(CRC32(CONCAT('country-', n)), 100) < 45 THEN 2 -- UK
        WHEN MOD(CRC32(CONCAT('country-', n)), 100) < 80 THEN 3 -- USA
        WHEN MOD(CRC32(CONCAT('country-', n)), 100) < 95 THEN 4 -- Portugal
        ELSE 5 -- Spain
    END
FROM `_synthetic_sequence`
WHERE n <= 1500;

INSERT INTO `Customer` (`Person_ID`)
SELECT 50000 + n
FROM `_synthetic_sequence`
WHERE n <= 1500;

-- Broaden the inventory across the 10 established stores and 208 products.
-- Preserve the 50 original inventory rows, including their deliberate stockouts.
-- Keep some additional products out of individual stores, and some at zero.
INSERT INTO `Store_Inventory` (`Store_ID`, `Fragrance_ID`, `Num_Bottles`)
SELECT
    s.Store_ID,
    f.Fragrance_ID,
    CASE
        WHEN MOD(s.Store_ID * 19 + f.Fragrance_ID * 7, 17) = 0 THEN 0
        WHEN MOD(f.Fragrance_ID, 9) = 0 THEN 3 + MOD(s.Store_ID * 5 + f.Fragrance_ID, 9)
        ELSE 10 + MOD(s.Store_ID * 13 + f.Fragrance_ID * 11, 36)
    END
FROM `Store` AS s
CROSS JOIN `Fragrance` AS f
LEFT JOIN `Store_Inventory` AS existing
    ON existing.Store_ID = s.Store_ID
    AND existing.Fragrance_ID = f.Fragrance_ID
WHERE existing.Store_ID IS NULL
  AND MOD(s.Store_ID * 7 + f.Fragrance_ID * 11, 10) < 8;

-- 10,000 historical sales. IDs 50001..60000 avoid the original purchases.
-- Every sale references a real customer, store, and existing fragrance.
-- About 1 in 7 purchases favors five featured scents, producing a plausible
-- top-sellers report while the remaining purchases cover the full catalogue.
-- CRC32 of a row number and a distinct label gives deterministic variation:
-- stores have different traffic levels and some customers shop more often.
-- Inventory is the *current* stock snapshot after historical restocking;
-- it is not decremented a second time for these already completed purchases.
INSERT INTO `Purchase_Record`
    (`Purchase_ID`, `Purchase_Date`, `Customer_ID`, `Fragrance_ID`, `Store_ID`)
SELECT
    50000 + n,
    TIMESTAMP(
        DATE_SUB(CURRENT_DATE(), INTERVAL MOD(CRC32(CONCAT('day-', n)), 640) DAY),
        MAKETIME(
            9 + MOD(CRC32(CONCAT('hour-', n)), 11),
            MOD(CRC32(CONCAT('minute-', n)), 60),
            0
        )
    ),
    50001 + CASE
        WHEN MOD(CRC32(CONCAT('loyal-', n)), 10) < 3
            THEN MOD(CRC32(CONCAT('vip-', n)), 150)
        ELSE MOD(CRC32(CONCAT('buyer-', n)), 1500)
    END,
    CASE
        WHEN MOD(CRC32(CONCAT('featured-', n)), 7) = 0 THEN
            CASE MOD(CRC32(CONCAT('hit-', n)), 5)
                WHEN 0 THEN 2
                WHEN 1 THEN 72
                WHEN 2 THEN 94
                WHEN 3 THEN 144
                ELSE 178
            END
        ELSE 1 + MOD(CRC32(CONCAT('product-', n)), 208)
    END,
    CASE
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 18 THEN 1 -- Paris
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 34 THEN 2 -- London
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 49 THEN 3 -- New York
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 55 THEN 4 -- Prescott
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 67 THEN 5 -- Lisbon
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 77 THEN 6 -- Los Angeles
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 85 THEN 7 -- Chicago
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 91 THEN 8 -- Lyon
        WHEN MOD(CRC32(CONCAT('store-', n)), 100) < 96 THEN 9 -- Manchester
        ELSE 10 -- Porto
    END
FROM `_synthetic_sequence`;

COMMIT;

DROP TEMPORARY TABLE `_synthetic_sequence`;
DROP TEMPORARY TABLE `_synthetic_digit`;

-- Quick sanity check. The exact inventory count depends on the existing rows.
SELECT 'Person' AS table_name, COUNT(*) AS total_rows FROM `Person`
UNION ALL SELECT 'Customer', COUNT(*) FROM `Customer`
UNION ALL SELECT 'Fragrance', COUNT(*) FROM `Fragrance`
UNION ALL SELECT 'Store_Inventory', COUNT(*) FROM `Store_Inventory`
UNION ALL SELECT 'Purchase_Record', COUNT(*) FROM `Purchase_Record`;
