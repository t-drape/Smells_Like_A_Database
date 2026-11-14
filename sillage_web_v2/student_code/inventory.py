def restock(connection, store_id, fragrance_id, bottles):
    cursor = connection.cursor()
    sql = """
    UPDATE Store_Inventory
    SET Num_Bottles = Num_Bottles + %s
    WHERE Store_ID = %s
    AND Fragrance_ID = %s;
    """
    cursor.execute(sql, (bottles, store_id, fragrance_id))

    if cursor.rowcount == 0:
        cursor.close()
        return "Not a currently stocked item"

    connection.commit()
    cursor.close()
    return "Restock completed."
