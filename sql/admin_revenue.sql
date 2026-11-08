use scent_db;


SELECT * FROM Purchase_Record;


-- Gross Revenue Across Stores
SELECT SUM(Fragrance.Price) AS TotalRevenue From Purchase_Record
Inner Join Fragrance ON Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID;

-- Revenue By Store
-- For this, the user will click on a checkbox next to the available stores
SELECT SUM(Fragrance.Price) AS TotalRevenue From Purchase_Record
Inner Join Fragrance ON Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID
WHERE Purchase_Record.Store_ID = (
SELECT Store_ID From Store WHERE 
Store.City = 'Scottsdale' -- Replace 'Scottsdale' with a wildcard for user input
);

SELECT * FROM Store;

