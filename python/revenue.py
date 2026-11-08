import mysql.connector


# Change these to your own MySQL login
MYSQL_USER = "admin"
MYSQL_PASSWORD = "admin_user_password"

mysql_conn = mysql.connector.connect(
    host="localhost",
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database="scent_db"
)

def get_gross_revenue():
    cursor = mysql_conn.cursor(dictionary=True)
    sql = """SELECT SUM(Fragrance.Price) AS TotalRevenue
      From Purchase_Record Inner Join Fragrance ON
        Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID;"""
    cursor.execute(sql)
    revenue = cursor.fetchone()
    cursor.close()
    return revenue

def get_store():
    return input("City: ")

def get_specific_revenue(user_input=get_store()):
    cursor = mysql_conn.cursor(dictionary=True)
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


def normalize_revenue_from_sql(revenue_dictionary):
    total_revenue = revenue_dictionary["TotalRevenue"]
    return float(total_revenue)

print(f"Gross Revenue: {normalize_revenue_from_sql(get_gross_revenue()):.2f}")
print(f"Specific Revenue: {normalize_revenue_from_sql(get_specific_revenue()):.2f}")

mysql_conn.close()
