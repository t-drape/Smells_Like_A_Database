import mysql.connector


# Change these to your own MySQL login
MYSQL_USER = "customer"
MYSQL_PASSWORD = "customer_user_password"

mysql_conn = mysql.connector.connect(
    host="localhost",
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database="scent_db"
)

def get_note():
    return str(input("Fragrance Note: "))

def get_fragrances_with_note(user_input=get_note()):
    cursor = mysql_conn.cursor(dictionary=True)
    sql = """SELECT DISTINCT Fragrance.Fragrance_Name FROM Fragrance_Note
INNER JOIN Fragrance_Has_Note ON Fragrance_Note.Note_ID = Fragrance_Has_Note.Note_ID
INNER JOIN Fragrance ON Fragrance.Fragrance_ID = Fragrance_Has_Note.Fragrance_ID
WHERE Fragrance_Note.Note_Name = %s;"""
    cursor.execute(sql, (user_input,))
    fragrances = cursor.fetchall()
    cursor.close()
    return fragrances


def print_fragrance_names(name_dictionary):
    print("Fragrances:")
    for row in name_dictionary:
        fragrance = row["Fragrance_Name"]
        print(fragrance)


print_fragrance_names(get_fragrances_with_note())


mysql_conn.close()
