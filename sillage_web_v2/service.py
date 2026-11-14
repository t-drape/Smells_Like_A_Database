"""Web adapters. All executed SQL comes unchanged from the supplied student files."""
import importlib
import json
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent
READS = json.loads((ROOT / 'data/student_catalog_reads.json').read_text())


def catalogue_payload(tables, preview=False):
    brands = {r['Brand_ID']: r['Name'] for r in tables['Brand']}
    notes = {r['Note_ID']: r['Note_Name'] for r in tables['Fragrance_Note']}
    ingredients = {r['Ingredient_ID']: r['Ingredient_Name'] for r in tables['Fragrance_Ingredient']}
    note_map, ingredient_map, stock = {}, {}, {}
    for r in tables['Fragrance_Has_Note']:
        note_map.setdefault(r['Fragrance_ID'], []).append(notes.get(r['Note_ID'], 'Unknown note'))
    for r in tables['Fragrance_Has_Ingredient']:
        ingredient_map.setdefault(r['Fragrance_ID'], []).append(ingredients.get(r['Ingredient_ID'], 'Unknown ingredient'))
    for r in tables['Store_Inventory']:
        stock.setdefault(r['Fragrance_ID'], []).append({'store_id': r['Store_ID'], 'bottles': r['Num_Bottles']})
    products = [{
        'id': r['Fragrance_ID'], 'name': r['Fragrance_Name'],
        'house': brands.get(r['Brand_ID'], 'Independent house'),
        'strength': r['Strength'], 'size': r['Size'], 'price': str(r['Price']),
        'notes': note_map.get(r['Fragrance_ID'], []),
        'ingredients': ingredient_map.get(r['Fragrance_ID'], []),
        'inventory': stock.get(r['Fragrance_ID'], []),
    } for r in tables['Fragrance']]
    return {
        'products': products,
        'brands': [{'id': r['Brand_ID'], 'name': r['Name']} for r in tables['Brand']],
        'countries': [{'id': r['Country_ID'], 'name': r['Name']} for r in tables['Country']],
        'stores': [{'id': r['Store_ID'], 'city': r['City'], 'street': r['Street']} for r in tables['Store']],
        'preview': preview,
    }


class Service:
    def __init__(self, config=None, preview=False, customer_config=None, admin_config=None):
        self.preview = preview
        self.config = config or {}
        self.customer_config = customer_config
        self.admin_config = admin_config
        if bool(customer_config) != bool(admin_config):
            raise ValueError('Configure both fragrance database accounts, or neither.')
        if customer_config and admin_config:
            names = [str(c.get('user', '')).strip() for c in (customer_config, admin_config)]
            if any(not name or name.lower() == 'root' for name in names):
                raise ValueError('Fragrance connections require named, non-root database accounts.')
            if names[0] == names[1]:
                raise ValueError('Use distinct customer and admin database accounts for this demonstration.')

    def _connect(self, config=None):
        if self.preview:
            raise RuntimeError('Preview mode does not connect to MySQL.')
        import mysql.connector
        return mysql.connector.connect(**(self.config if config is None else config))

    def catalog(self):
        if self.preview:
            return catalogue_payload(json.loads((ROOT / 'data/preview_catalog.json').read_text()), True)
        connection = self._connect()
        cursor = None
        try:
            cursor = connection.cursor(dictionary=True)
            tables = {}
            for name, student_statement in READS.items():
                # Exact constant SELECT statements from scent_DB_milestone.sql.
                # No table/column/statement text is taken from an HTTP request.
                cursor.execute(student_statement)
                tables[name] = cursor.fetchall()
            return catalogue_payload(tables)
        finally:
            if cursor is not None:
                cursor.close()
            connection.close()

    def _call(self, module, function, *args):
        student_function = getattr(importlib.import_module('student_code.' + module), function)
        connection = self._connect()
        try:
            return student_function(connection, *args)
        finally:
            connection.close()

    def search(self, note):
        return self._call('searches', 'get_fragrances_with_note', note)

    def natural(self):
        return self._call('searches', 'get_fragrances_with_natural_status')

    def register(self, first, last, email, country):
        return self._call('customers', 'register_customer', first, last, email, country)

    def purchase(self, customer, fragrance, store):
        return self._call('transactions', 'record_purchase', customer, fragrance, store)

    def restock(self, store_id, fragrance_id, bottles):
        # Same limited application profile as Record Purchase; the web route
        # requires a staff session. The supplied function owns the commit.
        return self._call('inventory', 'restock', store_id, fragrance_id, bottles)

    def revenue(self, city=None):
        if city:
            return self._call('revenue', 'get_specific_revenue', city)
        return self._call('revenue', 'get_gross_revenue')

    def discounts(self, cutoff=None):
        return self._call('discount', 'get_users_with_discount', cutoff or date.today() - timedelta(days=30))

    def stock_location(self, fragrance_name):
        return self._call('reports', 'stock_location', fragrance_name)

    def top_seller(self):
        return self._call('reports', 'top_seller')

    def add_brand(self, values):
        """Staff-only web route; use the configured admin profile without fallback."""
        module = importlib.import_module('student_code.brands')
        if not module.ADD_BRAND_READY:
            raise NotImplementedError('Brand insertion has not been completed.')
        if not self.admin_config:
            raise NotImplementedError('Brand database account has not been configured.')
        connection = self._connect(self.admin_config)
        try:
            brand_id = module.insert_brand(connection, **values)
            if isinstance(brand_id, bool) or not isinstance(brand_id, int) or brand_id <= 0:
                raise RuntimeError('The student function must return the saved Brand_ID.')
            return brand_id
        finally:
            connection.close()

    def add_fragrance(self, values, *, is_staff):
        """Route one student-owned operation; never manufacture a permission denial.

        is_staff must come from the verified server session, not request JSON.
        The student function owns all SQL, parameters, and save/error logic.
        """
        module = importlib.import_module('student_code.fragrances')
        if not module.ADD_FRAGRANCE_READY:
            raise NotImplementedError('Fragrance insertion has not been implemented.')
        profile = self.admin_config if is_staff else self.customer_config
        if not profile:
            raise NotImplementedError('Fragrance database accounts have not been configured.')
        connection = self._connect(profile)
        try:
            fragrance_id = module.insert_fragrance(
                connection, name=values['fragrance_name'], strength=values['strength'],
                size=values['size'], brand=values['brand_id'], price=values['price'],
            )
            if isinstance(fragrance_id, bool) or not isinstance(fragrance_id, int) or fragrance_id <= 0:
                raise RuntimeError('The student function must return the saved Fragrance_ID.')
            return fragrance_id
        finally:
            connection.close()
