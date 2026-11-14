# Remaining team work and local demonstration

The interface and existing-function integration are implemented. This list separates the supplied database features from missing assignment work. No new required SQL, parameterization, grant decisions, or transaction logic has been authored here.

## Seven distinct actions

| Requirement | Candidate user action | Supplied function / status |
| --- | --- | --- |
| Search with WHERE | Search for fragrances by exact note | `get_fragrances_with_note`; connected. |
| JOIN | Find stores with a fragrance in stock | `stock_location`; connected under Find in Stores using the newly supplied function unchanged. |
| GROUP BY plus aggregate | View the five best-selling fragrance variants | `top_seller` uses GROUP BY/COUNT; connected under Top Sellers using the newly supplied function unchanged. |
| Subquery | View revenue for one store city | `get_specific_revenue`; connected. City must match at most one Store row with the current query. |
| INSERT | Register a customer | `register_customer`; connected, including original Person + Customer transaction. |
| UPDATE | A separate, meaningful record-change action | **Missing.** The UPDATE inside the purchase transaction cannot also count as a second distinct user action. Team must supply the function and choose the permissions. |
| Transaction | Record a one-bottle purchase | `record_purchase`; connected through team desk, original logic unchanged. |

Gross revenue, ingredient classification, and purchase follow-up remain additional actions. Add Fragrance can become another INSERT action once the team implements it, but it does not replace the missing standalone UPDATE feature. Constraint and permission demonstrations are separate requirements.

## Functions/features to supply

- A separate update function with the team's SQL, parameterization, permission decisions, and intended form fields. Once supplied, it can be connected to a staff or customer form as appropriate.
- For customer accounts: authentication storage/schema decision, credential verification that returns the trusted customer identity, and a customer-specific purchase-history function. Supply any associated schema/grant changes yourselves. This is necessary for actual login and own-history behavior, but is not a separate new assignment requirement by itself.
- For Add Fragrance: complete `student_code/fragrances.py`, verify effective customer/admin permissions, and run the real refusal/success demonstration. The form and profile selection are ready; the INSERT implementation is not supplied. See `ADD_FRAGRANCE_TEAM_GUIDE.md`. This replaces the earlier revenue-page refusal proposal, which the existing SELECT grants would allow.
- Sample fulfillment and multi-item checkout are absent from the supplied backend. They are optional; the interface currently makes no claim to process them.

## Local checks with your running server

1. Start `python app.py --staff` with the intended limited database username. Do not recreate your populated database. Open the website and confirm the footer says connected to MySQL.
2. Check the carousel at desktop size and at a narrow mobile size. Try previous/next, pointer dragging, pause/resume, keyboard focus, mode tabs, group selection, catalogue search/sort, details, and bag removal. Escape should close a dialog. The top design was translated from the mockup's numeric styles; browser visual verification was blocked in the build workspace.
3. Use Search by Note with a known note and a nonexistent note. The exact-note query should return results and then a friendly empty result. An apostrophe-containing input must remain a value, never query text; the student's original parameter tuple is unchanged.
4. Run Find in Stores, Top Sellers, the ingredient report, and each team-desk report. Stock Location searches by name across matching variants; Top Sellers counts individual Fragrance_ID variants. Empty revenue totals display $0.00. Purchase follow-up returns historical purchase rows, not necessarily inactive customers.
5. Register a new test customer, then submit the same email again to demonstrate the UNIQUE constraint and the existing friendly registration failure message. Record the successful returned customer ID.
6. For a successful purchase, choose that valid customer ID and a fragrance/store pair with positive stock. Record the before count, submit once, and verify one purchase plus a one-bottle inventory reduction in Workbench.
7. For rollback, choose a positive-stock fragrance/store pair and a positive customer ID your team has verified does not exist. The inventory UPDATE will be followed by a foreign-key failure on the purchase INSERT. The existing function rolls back. Verify the inventory and purchase count before/after in Workbench. The app reports “Purchase failed. No changes were saved.” Do not use a zero-stock pair for this particular demonstration: that returns before the INSERT and does not demonstrate undoing a successful first change.
8. After completing the student insertion function, start with `--staff --fragrance-accounts` and demonstrate Add Fragrance with customer and admin database profiles. Follow the detailed guide to verify the actual refused INSERT and successful saved row. A Python “Sign in” message, simulated test error, unavailable message, or disabled button does not demonstrate MySQL refusing an operation.
9. Add and demonstrate the team's standalone update action. Confirm all seven actions have distinct requirement assignments.
10. Confirm each member can explain the original SQL, the existing execute argument tuples, the transaction's rowcount check and rollback, the account grants, and the interface changes. Complete the contribution table and AI disclosure in README.

## Existing-query implications to understand

- Revenue sums current Fragrance.Price values; no sale price is stored in Purchase_Record, so it is not immutable historical revenue.
- Store-city revenue uses a scalar subquery. Multiple stores sharing the entered city produce a MySQL error; the interface reports the limitation without exposing the raw error.
- The discount function finds older purchase rows above a price threshold; a customer with a more recent purchase can still appear and can appear multiple times. No discount code is generated or sent.
- Natural classification is based on recorded ingredients and the team's original CASE expression, not a health/safety claim or proof that ingredient data is complete.
- `create_user_account.sql`'s UPDATE Customer permission does not permit editing names or email stored in Person, and its SELECT on all database tables does not enforce customer-specific rows. Review the intended account and update feature together.

These points are documented without changing the team's graded database work.
