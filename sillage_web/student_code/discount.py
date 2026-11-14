# Student SQL and execute arguments preserved; connection is supplied by the web app.

def get_users_with_discount(connection, date_delta):
    cursor = connection.cursor(dictionary=True)
    sql = """
SELECT Concat(Person.First_Name, ' ', Person.Last_Name) AS Name, Fragrance.Price, Purchase_Date
From Purchase_Record
Inner Join Customer ON Purchase_Record.Customer_ID = Customer.Person_ID
Inner Join Person ON Customer.Person_ID = Person.Person_ID
Inner Join Fragrance ON Fragrance.Fragrance_ID = Purchase_Record.Fragrance_ID
Where Purchase_Record.Purchase_Date < %s AND
Fragrance.Price > 200;
        """
    cursor.execute(sql, (date_delta,))
    users = cursor.fetchall()
    cursor.close()
    return users
