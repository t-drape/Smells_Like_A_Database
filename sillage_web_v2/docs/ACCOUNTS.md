# MySQL accounts and website customers

There are two distinct identities. A MySQL account authorizes Python to connect to the database. A website customer identifies a person using the application. The same database login can serve many different customer sessions.

| Identity | Where it belongs | What it controls |
| --- | --- | --- |
| MySQL account, e.g. `scent_app` | MySQL account system; credentials kept in Python's server configuration | Which database objects and operations the Python connection can use. |
| Website customer | Your application's Person/Customer data plus authentication data your team still needs to supply | Which person's account and purchase records the application should show. |
| Website staff role | Trusted, verified application identity/session | Whether a visitor can reach reports and staff actions. |

An account is not a view or a GRANT. CREATE USER establishes an account; GRANT assigns privileges to it. MySQL identifies an account using both user and host. In `'customer'@'localhost'`, localhost refers to where the Python database client connects from, not the customer's browser or home address. The names `customer` and `admin` have no automatic special meaning.

If Maya and Liam are both browsing, the application can create two different website sessions while using the same configured database username for their SQL connections. MySQL sees that shared database identity. It does not automatically know that one request came from Maya and the next from Liam.

For a real customer login, Python must verify the supplied credentials against the customer's stored password hash, then associate the authenticated customer ID with the session. When requesting history, Python obtains that trusted ID from the session and passes it to the team's customer-filtered query. It must not trust a customer ID from a URL, hidden field, or browser selection as proof of identity. Parameterization and checking ownership solve different problems; both matter.

Your current registration function inserts into Person and Customer. Customer has Person_ID, and Person has names/email/country. There is no password-hash field/table or login-verification function in the supplied files. Therefore, registering a customer row currently does not provide a usable email/password login. The integration does not invent one or expose purchase history without authentication.

## Current database account routing

| Feature/request | MySQL connection profile |
| --- | --- |
| Catalogue, searches, registration, purchase transaction, revenue, follow-up, Stock Location, Top Sellers, Restock | Base application profile: MYSQL_USER, default scent_app. |
| Add Brand (staff-only) or Add Fragrance with a verified team-desk session | MYSQL_ADMIN_USER profile, default admin when the optional profiles are configured. |
| Add Fragrance without a staff session | MYSQL_CUSTOMER_USER profile, default customer when the optional profiles are configured. |

Add Fragrance and Add Brand use the extra profiles. Add Brand is restricted to verified staff by the web route and uses only the admin profile. Restock is also staff-only, but uses the base application profile, as Record Purchase already does; its supplied grant includes UPDATE on Store_Inventory. The server selects the profile from its authenticated staff session; role or username fields submitted by the browser cannot select an admin connection. Neither missing profile falls back to another account. Enable the profiles with --fragrance-accounts or the corresponding environment variables to use the connected brand and fragrance functions. The website does not create countries; the brand form selects an existing country ID.

The current schema still lacks individual customer login. Non-staff visitors use customer-level database access for this classroom demonstration; this is not authentication of a particular Customer row. The team-desk password remains separate from all database passwords.

The supplied admin script grants INSERT on Fragrance through its database-level INSERT grant. The customer script grants INSERT on Person and Customer, but not Fragrance. If those are the server's effective permissions, the same student function can succeed for admin and fail for customer. The team must verify the effective grants. The latest supplied fragrance INSERT, parameterization, commit, and returned ID are now connected without changing their logic.

Both access categories may open and submit Add Fragrance. The route validates form values and CSRF, then calls the student function on the selected connection. It does not pre-reject a customer because of their application role. Only a MySQL table/column permission error on that insertion attempt produces the requested friendly customer refusal message.

The fragrance function is enabled. Missing role configuration still makes it unavailable. A missing function, preview mode, bad foreign key, duplicate row, or connection failure is not described as proof of MySQL refusal. If customer has broader INSERT privileges from other grants or roles, MySQL may actually accept and save the row; the app does not fake a rejection. See ADD_FRAGRANCE_TEAM_GUIDE.md for the implementation and demonstration steps.

## Why the earlier revenue-page permission proposal does not work with the supplied grants

The idea works only if the database rejects the query through the limited connection. These are separate outcomes:

| Test | What it proves | Counts as MySQL refusal? |
| --- | --- | --- |
| Python checks a website role and returns “Forbidden” before querying | Application access control | No |
| The configured limited MySQL connection attempts the query and MySQL returns a privilege error | Database privilege enforcement | Yes |

Your supplied `create_user_account.sql` grants the `customer` account SELECT on `scent_db.*`. The revenue query reads Fragrance and Purchase_Record, so those grants currently allow the query. The SQL name `admin` does not make it the only account permitted to calculate revenue. `account.sql` also grants broad SELECT to `scent_app`.

If you retained the revenue-page approach, your team would need to make the grant/design decision and provide the corresponding SQL. The current Add Fragrance approach instead uses the INSERT distinction already present in your supplied scripts. The assignment explicitly reserves that work for you. If the customer account retains ordinary full SELECT access to Purchase_Record and Fragrance, basic table grants cannot separately forbid calculating their SUM. Restricting access to purchase records also affects your planned customer-history feature; decide that data-access design together.

Once a team's revised limited account actually lacks the necessary privilege, this app's outer error handler can display “MySQL refused this operation for the configured database account.” That is different from its “Sign in to the team desk” application message. The original customer/purchase functions handle some database errors themselves and return their original messages.

For existing reports, a database username is still selected at startup through MYSQL_USER; the team-desk password does not change that report connection. Add Fragrance and Add Brand use the separate profiles described above. To exercise a revenue query under the SQL `customer` identity, your team can run locally with that configured username and sign in to the team desk to reach the report. With the supplied grants it will be allowed. Do not present that as a refused operation, and do not test with root.

The existing `account.sql` deliberately does not grant DELETE, but no forbidden-operation function was supplied. Any demonstration using that limitation still needs a team-written database operation and safe demonstration data. Tests that simulate error 1142 only check the user-facing error handler; they cannot prove your actual grants.

## Limited accounts and team decisions

The assignment requires limited, non-root database access. The base account remains the team's scent_app. The additional profiles implement your requested customer/admin Add Fragrance demonstration using the existing team-defined account names. Review the final account arrangement and the scope of the supplied broad admin grants against the course requirements.

The website creates no MySQL accounts and changes no grants. Database credentials stay on the server. No account/grant SQL has been rewritten by AI.

References: [MySQL access control](https://dev.mysql.com/doc/refman/8.4/en/access-control.html), [GRANT](https://dev.mysql.com/doc/refman/8.4/en/grant.html), and [Connector/Python connection arguments](https://dev.mysql.com/doc/connector-python/en/connector-python-connectargs.html).
