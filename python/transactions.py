import mysql.connector


def record_purchase(connection, customer_id, fragrance_id, store_id):
    cursor = connection.cursor()

    try:
        if connection.in_transaction:
            connection.rollback()
        connection.start_transaction()

        # Reduce inventory by one bottle
        cursor.execute(
            """
            UPDATE Store_Inventory
            SET Num_Bottles = Num_Bottles - 1
            WHERE Store_ID = %s
              AND Fragrance_ID = %s
              AND Num_Bottles > 0
        """,
            (store_id, fragrance_id),
        )

        if cursor.rowcount == 0:
            connection.rollback()
            return "Purchase failed: Fragrance is out of stock."

        # Record the purchase
        cursor.execute(
            """
            INSERT INTO Purchase_Record
            (Purchase_Date, Customer_ID, Fragrance_ID, Store_ID)
            VALUES (NOW(), %s, %s, %s)
        """,
            (customer_id, fragrance_id, store_id),
        )

        connection.commit()
        return "Purchase completed successfully."

    except mysql.connector.Error:
        connection.rollback()
        return "Purchase failed. No changes were saved."

    finally:
        cursor.close()
