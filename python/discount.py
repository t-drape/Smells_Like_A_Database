import mysql.connector

from datetime import date, timedelta


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


def get_discount_date():
    today = date.today()
    discount_date = today - timedelta(days=30)
    return discount_date


def get_users_with_discount(date_delta=get_discount_date()):
    cursor = mysql_conn.cursor(dictionary=True)
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


def normalize_users_with_discount_data(data_dictionary):
    for row in data_dictionary:
        name = row["Name"]
        date = row["Purchase_Date"]

        print(f"""
Hi {name}!
We like you. You haven't purchased since {date}.
Here's a discount code for you!
        """)

normalize_users_with_discount_data(get_users_with_discount())


mysql_conn.close()