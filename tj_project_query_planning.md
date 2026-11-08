1. Gross Revenue (Grouped By Store)
		Data Needed:
			1. Purchase Record
			2. Store ID
			3. Fragrance Price
			4. Store Address
		Composite Data:
			5. Sum of fragrance price
			6. Group By Store ID
		Tables:
			A. Purchase_Record
			B. Fragrance
			C. Store
		Application:
			This query lets us aggregate the revenue across stores, allowing us to analyze the gross revenue, and identify which stores lead sales and which need to improve. 
		Query:
			SELECT Store.City, SUM(Fragrance.Price) AS PurchasePrice FROM Purchase_Record
			Inner Join Store ON Purchase_Record.Store_ID = Store.Store_ID
			Inner Join Fragrance On Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID
			Group By Store.Store_ID;
			
2. Note Filtered Search
		Data Needed:
			1. Fragrance ID
			2. Note ID
			3. Note Name
		Tables:
			A. Fragrance
			B. Fragrance_Note
			C. Fragrance_Has_Note
		Application:
			This query allows users to search for fragrances that share similar notes. If they like one fragrance, then maybe they'll like another with a similar note profile or notes. 
		Query:
			SELECT Fragrance_Note.Note_Name, Count() FROM Fragrance
			Inner Join Fragrance_Has_Note On Fragrance.Fragrance_ID = Fragrance_Has_Note.Fragrance_ID
			Inner Join Fragrance_Note on Fragrance_Has_Note.Note_ID = Fragrance_Note.Note_ID
			Group By Fragrance_Note.Note_ID;
		Note: 
			We will need a form that has the user click on a note name, or select a note id. So, to still get valuable data, the current query provides the count of all fragrances that have the given note.
3. Personalized Discount Algorithm / Repeated Purchase Incentive
		Data Needed:
			1. Purchase Record
			2. Purchase Record Date
			3. Customer ID
			4. (Optional) Purchase Price
		Tables:
			A. Purchase_Record
			B. Customer
		Application: 
			This query gives us the ability to send out personalized discount codes based on when a customer's last purchase was, how much it was, and other details. This will help the business drive repeat customers. 
		Query:
			SELECT Concat(Person.First_Name, ' ', Person.Last_Name) AS Name, Fragrance.Price From Purchase_Record
			Inner Join Customer ON Purchase_Record.Customer_ID = Customer.Person_ID
			Inner Join Person ON Customer.Person_ID = Person.Person_ID
			Inner Join Fragrance ON Fragrance.Fragrance_ID = Purchase_Record.Fragrance_ID
			Where Purchase_Record.Purchase_Date < '2026-10-10 00:00:00';
		Note:
			We will change this date value to reflect an actual datetime reading instead of being a fixed value. Also, we can extend this to only include purchases that are over X amount of dollars.

Note: Minor change to the DB. We'll need to adjust Purchase Record to allow a user to buy multiple fragrances in a single purchase. 
			
