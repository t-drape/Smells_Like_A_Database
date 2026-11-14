import mysql.connector


def stock_location(connection, fragrance_name):
    cursor = connection.cursor(dictionary=True)
    sql = """
    SELECT Store.City, Store.Building, Store.Street, Store_Inventory.Num_Bottles
    FROM Fragrance
      JOIN Store_Inventory
        ON Fragrance.Fragrance_ID = Store_Inventory.Fragrance_ID
      JOIN Store
        ON Store_Inventory.Store_ID = Store.Store_ID
    WHERE Fragrance.Fragrance_Name = %s
    AND Store_Inventory.Num_Bottles > 0
    ORDER BY Store_Inventory.Num_Bottles DESC;
    """
    cursor.execute(sql, (fragrance_name,))
    rows = cursor.fetchall()
    cursor.close()
    return rows


def top_seller(connection):
    cursor = connection.cursor(dictionary=True)
    sql = """
    SELECT Fragrance.Fragrance_Name,
           COUNT(*) AS Total_Purchases
    FROM Purchase_Record
      JOIN Fragrance
        ON Purchase_Record.Fragrance_ID = Fragrance.Fragrance_ID
    GROUP BY Fragrance.Fragrance_ID, Fragrance.Fragrance_Name
    ORDER BY Total_Purchases DESC
    LIMIT 5;
    """
    cursor.execute(sql)
    rows = cursor.fetchall()
    cursor.close()
    return rows
