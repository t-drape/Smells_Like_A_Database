use scent_db;
SELECT Concat(Person.First_Name, ' ', Person.Last_Name) AS Name, Fragrance.Price, Purchase_Date From Purchase_Record
Inner Join Customer ON Purchase_Record.Customer_ID = Customer.Person_ID
Inner Join Person ON Customer.Person_ID = Person.Person_ID
Inner Join Fragrance ON Fragrance.Fragrance_ID = Purchase_Record.Fragrance_ID
Where Purchase_Record.Purchase_Date < '2026-11-10 00:00:00' AND
Fragrance.Price > 200;