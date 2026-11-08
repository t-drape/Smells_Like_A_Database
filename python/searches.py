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

def get_fragrances_with_natural_status():
    cursor = mysql_conn.cursor(dictionary=True)
    sql = """
SELECT Fragrance.Fragrance_Name, Brand.Name,
CASE
	WHEN COUNT(Fragrance_Ingredient.Ingredient_ID) = 0 Then 'No Ingredient Data'

	WHEN SUM(CASE WHEN Fragrance_Ingredient.Is_Natural != 1 THEN 1 ELSE 0 END) = 0 THEN 'Clean Fragrance'
    
    ELSE 'Contains Synthetic Ingredients'
END AS Natural_Status
FROM Fragrance
LEFT JOIN Fragrance_Has_Ingredient ON Fragrance.Fragrance_ID = Fragrance_Has_Ingredient.Fragrance_ID
LEFT JOIN Fragrance_Ingredient on Fragrance_Has_Ingredient.Ingredient_ID = Fragrance_Ingredient.Ingredient_ID
Inner Join Brand on Brand.Brand_ID = Fragrance.Brand_ID
GROUP BY Fragrance.Fragrance_Name, Brand.Name;
"""
    cursor.execute(sql)
    fragrances = cursor.fetchall()
    cursor.close()
    return fragrances

def get_fragrances_with_note():
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

def print_natural_fragrances(name_dictionary):
    print("Clean Fragrances:")
    for row in name_dictionary:
        fragrance = row["Fragrance_Name"]
        brand = row["Name"]
        natural_status = row["Natural_Status"]
        if natural_status == "Clean Fragrance":
            print(f"""
    Brand: {brand}
    Fragrance: {fragrance}
            """)



# print_fragrance_names(get_fragrances_with_note())
print_natural_fragrances(get_fragrances_with_natural_status())


mysql_conn.close()
