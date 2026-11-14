import mysql.connector

def register_customer(connection, first_name, last_name, email, country_id):
    cursor = connection.cursor()

    try:
        connection.start_transaction()

        # Create the person
        cursor.execute(
            """
            INSERT INTO Person (First_Name, Last_Name, Email, Country_ID)
            VALUES (%s, %s, %s, %s)
        """,
            (first_name, last_name, email, country_id),
        )

        person_id = cursor.lastrowid

        # Register the person as a customer
        cursor.execute(
            """
            INSERT INTO Customer (Person_ID)
            VALUES (%s)
        """,
            (person_id,),
        )

        connection.commit()
        return f"Customer #{person_id} registered successfully."

    except mysql.connector.IntegrityError:
        connection.rollback()
        return "Registration failed: Duplicate email or invalid country."

    except mysql.connector.Error:
        connection.rollback()
        return "Registration failed. No changes were saved."

    finally:
        cursor.close()
