"""User-supplied brand INSERT adapted to explicit web inputs and a connection.

The SQL, parameter tuple, commit, lastrowid, close, and return are preserved.
The website passes an existing Country_ID directly from its country dropdown.
"""

ADD_BRAND_READY = True


def insert_brand(connection, country_id, name):
    cursor = connection.cursor(dictionary=True)
    sql = """
INSERT INTO BRAND (Name, Country_ID) Values (%s, %s);"""
    cursor.execute(sql, (name, country_id))
    connection.commit()
    brand_id = cursor.lastrowid
    cursor.close()
    return brand_id
