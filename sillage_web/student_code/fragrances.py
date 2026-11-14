"""Interface scaffold only. The team must write the graded database implementation.

Read docs/ADD_FRAGRANCE_TEAM_GUIDE.md for the input/output contract.
No INSERT, SQL parameter binding, commit, rollback, or grants are provided here.
"""

ADD_FRAGRANCE_READY = False


def add_fragrance(connection, fragrance_name, strength, size, price, brand_id,
                  perfumer_id=None, notes=None):
    """Return the new positive integer Fragrance_ID after successfully saving.

    The caller supplies a connection already authenticated as the appropriate
    MySQL account. Do not create a different connection or select an account
    here. Preserve the original MySQL exception on failure so the web layer
    can distinguish permission refusal from invalid data.

    Set ADD_FRAGRANCE_READY to True after implementing and testing this function,
    then restart the Python web server.
    """
    raise NotImplementedError('The team has not implemented fragrance insertion yet.')
