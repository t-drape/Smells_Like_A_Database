"""User-supplied fragrance INSERT adapted for web inputs and a passed connection.

SQL, execute values, commit, lastrowid, cursor close, and return are retained.
The original terminal script is preserved in docs/supplied_catalog_script.txt.
"""

ADD_FRAGRANCE_READY = True


def insert_fragrance(connection, name, strength, size, brand, price):
    cursor = connection.cursor(dictionary=True)
    sql = """
INSERT INTO Fragrance (Fragrance_Name, Strength, Size, Price, Brand_ID) Values (%s, %s, %s, %s, %s);"""
    cursor.execute(sql, (name, strength, size, price, brand))
    connection.commit()
    fragrance_id = cursor.lastrowid # FROM AI, USED CHATGPT. NEEDED FOR WEBPAGE
    cursor.close()
    return fragrance_id
