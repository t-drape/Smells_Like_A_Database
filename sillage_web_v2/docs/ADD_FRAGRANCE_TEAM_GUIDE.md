# Add Fragrance: connected function and local demonstration

Your latest supplied `insert_fragrance` is now connected and enabled. `ADD_FRAGRANCE_READY` is True in `student_code/fragrances.py`. Its SQL, execute tuple, commit, generated ID, cursor close, and return are retained. Only the function signature and connection variable are adapted for web requests.

## Function and field mapping

```python
def insert_fragrance(connection, name, strength, size, brand, price):
```

| Form field | Function argument | Validated input |
| --- | --- | --- |
| fragrance_name | name | Nonempty string, up to 100 characters. |
| strength | strength | Nonempty string, up to 45 characters. |
| size | size | Positive integer millilitres, within the database integer range. |
| brand_id | brand | Positive integer ID of an existing brand; MySQL verifies the foreign key. |
| price | price | Decimal from 0 to 99999999.99, at most two decimal places. |

The form no longer offers optional perfumer or descriptive notes fields because your INSERT does not save them. The schema remains unchanged. Nonempty old optional fields in a submitted request receive a validation error. New brands, country creation, scent-note associations, and new inventory rows are not created as part of this action.

The function commits before returning its generated ID. Its original AI-attribution comment on cursor.lastrowid is preserved. No extra commit, rollback, automatic retry, or alternate-user fallback was added in the adapter. The service closes the connection after the operation, including errors.

## Configure and run

```bash
python app.py --staff --fragrance-accounts
```

| Configuration | Purpose |
| --- | --- |
| MYSQL_HOST, MYSQL_PORT, MYSQL_DATABASE | Shared host, port, and database; defaults localhost, 3306, scent_db. |
| MYSQL_USER, MYSQL_PASSWORD | Base profile, normally scent_app; existing catalogue/reports, registration, purchase, and Restock. |
| MYSQL_CUSTOMER_USER, MYSQL_CUSTOMER_PASSWORD | Customer profile for Add Fragrance without a staff session. Default username customer. |
| MYSQL_ADMIN_USER, MYSQL_ADMIN_PASSWORD | Admin profile for Add Fragrance after staff sign-in and the connected staff-only Add Brand action. Default username admin. |
| SILLAGE_STAFF_PASSWORD | Optional alternative to prompting for the separate website team-desk password. |

Role passwords are prompted if not provided in the environment. Both role profiles must be configured together with distinct non-root usernames. The base password is never used as a fallback. Supplying the role environment variables also enables their configuration without the flag.

The supplied account scripts are reference copies and are never run automatically. Your populated database does not need to be recreated. Your team owns effective grants and any changes to them.

## Real permission demonstration

1. Verify the customer profile lacks INSERT on Fragrance and the admin profile has the intended permission. Existing roles/global/database grants can affect this distinction.
2. Choose an existing Brand_ID and a new combination of fragrance name, strength, and size.
3. Without a staff session, submit the Add Fragrance form. It reaches the actual student function on the customer connection. MySQL errors 1142 or 1143 produce exactly:

   > It looks like you can't add a fragrance! Come into one of our stores, or email us, and we will try to get the fragrance for you!

4. Confirm that no row was added. Preview/unavailable messages or simulated test exceptions do not count as a real database refusal.
5. Sign in through Team Desk and submit valid values. This selects the admin profile. The returned saved ID appears and the catalogue refreshes. Verify the row in Workbench.
6. Sign out, submit another valid combination, and confirm customer-profile selection again. Client-supplied role fields have no effect.

If the customer account is over-granted, MySQL may save its request. The app does not fake the intended refusal. Other failures have different messages: duplicate variant, invalid brand, invalid data, absent profile configuration, and lost connection. On connection loss, verify whether the row exists before resubmitting; there is no automatic retry.

## Remaining team work

Add Brand is now connected using the corrected country-ID function and the configured admin account. Its form refreshes the house list after saving. Your supplied query spells the table BRAND, while the schema uses Brand; match the case on a case-sensitive server before the live demonstration. Country creation remains a separate incomplete helper. See `CATALOG_SCRIPT_REVIEW.md` for the complete current review. Restock remains the separate UPDATE action.

Individual customer email/password login and purchase history remain separate, unimplemented features. This class demonstration uses the staff session to select the database profile; it does not authenticate a particular Customer row.
