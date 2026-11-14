# Student SQL and execute arguments preserved; connection is supplied by the web app.

def get_gross_revenue(connection):
    cursor = connection.cursor(dictionary=True)
    sql = """SELECT SUM(Fragrance.Price) AS TotalRevenue
      From Purchase_Record Inner Join Fragrance ON
        Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID;"""
    cursor.execute(sql)
    revenue = cursor.fetchone()
    cursor.close()
    return revenue

def get_specific_revenue(connection, user_input):
    cursor = connection.cursor(dictionary=True)
    sql = """SELECT SUM(Fragrance.Price) AS TotalRevenue
        From Purchase_Record Inner Join Fragrance ON
        Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID
        WHERE Purchase_Record.Store_ID = (
        SELECT Store_ID From Store WHERE 
        Store.City = %s
        );"""
    cursor.execute(sql, (user_input,))
    revenue = cursor.fetchone()
    cursor.close()
    return revenue
