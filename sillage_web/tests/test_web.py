"""HTTP integration checks using a service double, not a MySQL database."""
import json
import threading
import unittest
from decimal import Decimal
from http.cookiejar import CookieJar
from urllib.error import HTTPError
from urllib.request import Request, build_opener, HTTPCookieProcessor

from app import ADD_FRAGRANCE_REFUSAL, make_server
from service import Service


class Refused(Exception):
    errno = 1142


class FakeService:
    preview = False
    def __init__(self):
        self.calls = []
        self.refuse = False
        self.fragrance_error = None
    def catalog(self):
        return Service(preview=True).catalog()
    def revenue(self, city=None):
        self.calls.append(('revenue', city))
        if self.refuse:
            raise Refused('PRIVATE SQL ERROR TEXT')
        return {'TotalRevenue': '450.00'}
    def discounts(self, cutoff=None):
        self.calls.append(('discounts', cutoff))
        return []
    def search(self, note):
        self.calls.append(('search', note))
        return [{'Fragrance_Name': 'Example'}]
    def natural(self):
        return []
    def register(self, *args):
        self.calls.append(('register', args))
        return 'Customer #99 registered successfully.'
    def purchase(self, *args):
        self.calls.append(('purchase', args))
        return 'Purchase completed successfully.'
    def stock_location(self, name):
        self.calls.append(('stock_location', name))
        return [{'City':'Prescott','Building':None,'Street':'Example St','Num_Bottles':4}]
    def top_seller(self):
        self.calls.append(('top_seller',))
        return [{'Fragrance_Name':'Example','Total_Purchases':7}]
    def add_fragrance(self, values, *, is_staff):
        self.calls.append(('add_fragrance', is_staff, values))
        if self.fragrance_error:
            raise self.fragrance_error
        if not is_staff:
            raise Refused('PRIVATE INSERT ERROR')
        return 209


class WebTests(unittest.TestCase):
    def setUp(self):
        self.service = FakeService()
        self.server = make_server(self.service, 0, 'test-team-password')
        self.thread = threading.Thread(target=self.server.serve_forever, kwargs={'poll_interval': .02}, daemon=True)
        self.thread.start()
        self.url = 'http://127.0.0.1:' + str(self.server.server_port)
        self.client = build_opener(HTTPCookieProcessor(CookieJar()))
        _, info = self.call('/api/status')
        self.csrf = info['csrf']
    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
    def call(self, path, body=None, csrf=True):
        headers = {}
        data = None
        if body is not None:
            data = json.dumps(body).encode()
            headers['Content-Type'] = 'application/json'
            if csrf:
                headers['X-CSRF-Token'] = self.csrf
        request = Request(self.url + path, data=data, headers=headers)
        try:
            response = self.client.open(request)
        except HTTPError as exc:
            response = exc
        with response:
            return response.status, json.loads(response.read())
    def login(self):
        code, data = self.call('/api/staff/login', {'password': 'test-team-password'})
        self.assertEqual(code, 200)
        self.csrf = data['csrf']
    def test_private_reports_never_call_database_before_auth(self):
        for path in ['/api/revenue', '/api/discounts']:
            self.assertEqual(self.call(path)[0], 403)
        self.assertEqual(self.service.calls, [])
    def test_public_purchase_cannot_impersonate_customer(self):
        code, _ = self.call('/api/purchase', {'customer_id': 23, 'fragrance_id': 1, 'store_id': 1})
        self.assertEqual(code, 403)
        self.assertEqual(self.service.calls, [])
    def test_csrf_required_for_writes(self):
        code, _ = self.call('/api/register', {'first_name': 'Test'}, csrf=False)
        self.assertEqual(code, 403)
        self.assertEqual(self.service.calls, [])
    def test_wrong_password_is_rejected(self):
        self.assertEqual(self.call('/api/staff/login', {'password':'wrong'})[0], 401)
        self.assertEqual(self.call('/api/revenue')[0], 403)
    def test_login_logout_changes_access(self):
        old = self.csrf
        self.login()
        self.assertNotEqual(old, self.csrf)
        self.assertEqual(self.call('/api/revenue?city=Prescott')[1]['TotalRevenue'], '450.00')
        self.assertIn(('revenue', 'Prescott'), self.service.calls)
        self.assertEqual(self.call('/api/staff/logout', {})[0], 200)
        self.assertEqual(self.call('/api/revenue')[0], 403)
    def test_registration_maps_form_to_existing_function(self):
        code, data = self.call('/api/register', {'first_name':'Test','last_name':'Reader','email':'reader@example.com','country_id':'3'})
        self.assertEqual(code, 200)
        self.assertIn('registered successfully', data['message'])
        self.assertEqual(self.service.calls, [('register', ('Test','Reader','reader@example.com',3))])
    def test_invalid_registration_is_not_sent_to_database(self):
        self.assertEqual(self.call('/api/register', {'first_name':'Test','last_name':'Reader','email':'bad','country_id':3})[0], 400)
        self.assertEqual(self.service.calls, [])
    def test_purchase_is_staff_only_and_passes_integer_ids(self):
        self.login()
        self.assertEqual(self.call('/api/purchase', {'customer_id':'23','fragrance_id':'1','store_id':'1'})[0], 200)
        self.assertEqual(self.service.calls[-1], ('purchase', (23,1,1)))
    def test_refused_database_operation_has_friendly_message(self):
        self.login()
        self.service.refuse = True
        code, data = self.call('/api/revenue')
        self.assertEqual(code, 403)
        self.assertIn('MySQL refused', data['error'])
        self.assertNotIn('PRIVATE', data['error'])
    def test_exact_note_is_forwarded_as_data(self):
        self.assertEqual(self.call('/api/search?note=Vetiver')[0], 200)
        self.assertEqual(self.service.calls, [('search','Vetiver')])
    def test_preview_does_not_claim_to_save(self):
        self.service.preview = True
        self.assertEqual(self.call('/api/register', {'first_name':'Test'})[0], 503)
        self.assertEqual(self.service.calls, [])
    def test_catalogue_excludes_customer_and_purchase_data(self):
        code, data = self.call('/api/catalog')
        self.assertEqual(code, 200)
        self.assertEqual(len(data['products']), 208)
        self.assertEqual(set(data), {'products','brands','countries','stores','preview'})
        serialized = json.dumps(data)
        for key in ['Customer_ID','Purchase_ID','Email','First_Name']:
            self.assertNotIn(key, serialized)
    def test_no_arbitrary_file_access(self):
        self.assertEqual(self.call('/sql/account.sql')[0], 404)
        self.assertEqual(self.call('/../app.py')[0], 404)
    def test_second_browser_does_not_inherit_staff_session(self):
        self.login()
        self.client = build_opener(HTTPCookieProcessor(CookieJar()))
        self.assertEqual(self.call('/api/revenue')[0], 403)

    def fragrance_form(self, **changes):
        data = {'fragrance_name':'Team Example','strength':'Eau de Parfum','size':'50',
                'price':'125.50','brand_id':'1','perfumer_id':'','notes':''}
        data.update(changes)
        return data

    def test_stock_location_passes_exact_name_to_supplied_function(self):
        code, data = self.call('/api/stock?fragrance_name=L%27Example')
        self.assertEqual(code, 200)
        self.assertEqual(data['rows'][0]['Num_Bottles'], 4)
        self.assertEqual(self.service.calls, [('stock_location', "L'Example")])

    def test_stock_location_requires_a_name(self):
        self.assertEqual(self.call('/api/stock?fragrance_name=')[0], 400)
        self.assertEqual(self.service.calls, [])

    def test_top_sellers_exposes_the_report_result(self):
        code, data = self.call('/api/top-sellers')
        self.assertEqual(code, 200)
        self.assertEqual(data['rows'], [{'Fragrance_Name':'Example','Total_Purchases':7}])
        self.assertEqual(self.service.calls, [('top_seller',)])

    def test_customer_fragrance_attempt_reaches_service_and_refusal_has_exact_text(self):
        code, data = self.call('/api/fragrances', self.fragrance_form())
        self.assertEqual(code, 403)
        self.assertEqual(data['error'], ADD_FRAGRANCE_REFUSAL)
        self.assertEqual(self.service.calls[0][:2], ('add_fragrance', False))
        self.assertNotIn('PRIVATE', data['error'])

    def test_browser_cannot_choose_admin_connection(self):
        form = self.fragrance_form(role='admin', is_staff=True, user='admin')
        self.assertEqual(self.call('/api/fragrances', form)[0], 403)
        _, staff, values = self.service.calls[0]
        self.assertFalse(staff)
        self.assertNotIn('role', values)
        self.assertNotIn('user', values)

    def test_staff_fragrance_maps_typed_inputs_and_returns_id(self):
        self.login()
        code, data = self.call('/api/fragrances', self.fragrance_form())
        self.assertEqual(code, 201)
        self.assertEqual(data['fragrance_id'], 209)
        values = self.service.calls[-1][2]
        self.assertTrue(self.service.calls[-1][1])
        self.assertEqual(values['price'], Decimal('125.50'))
        self.assertEqual(values['size'], 50)
        self.assertEqual(values['brand_id'], 1)
        self.assertIsNone(values['perfumer_id'])
        self.assertIsNone(values['notes'])

    def test_logout_uses_customer_access_for_fragrance_submission(self):
        self.login()
        _, data = self.call('/api/staff/logout', {})
        self.csrf = data['csrf']
        self.assertEqual(self.call('/api/fragrances', self.fragrance_form())[0], 403)
        self.assertFalse(self.service.calls[-1][1])

    def test_missing_student_implementation_is_not_reported_as_mysql_refusal(self):
        self.service.fragrance_error = NotImplementedError('pending')
        code, data = self.call('/api/fragrances', self.fragrance_form())
        self.assertEqual(code, 501)
        self.assertNotEqual(data['error'], ADD_FRAGRANCE_REFUSAL)

    def test_staff_database_refusal_does_not_use_customer_message(self):
        self.login()
        self.service.fragrance_error = Refused('PRIVATE')
        code, data = self.call('/api/fragrances', self.fragrance_form())
        self.assertEqual(code, 403)
        self.assertIn('MySQL refused', data['error'])
        self.assertNotEqual(data['error'], ADD_FRAGRANCE_REFUSAL)

    def test_fragrance_duplicate_and_invalid_reference_are_not_permission_errors(self):
        for errno, status, message in [(1062,409,'already exist'),(1452,422,'valid perfumer')]:
            with self.subTest(errno=errno):
                exc = Exception('PRIVATE')
                exc.errno = errno
                self.service.fragrance_error = exc
                code, data = self.call('/api/fragrances', self.fragrance_form())
                self.assertEqual(code, status)
                self.assertIn(message, data['error'])
                self.assertNotEqual(data['error'], ADD_FRAGRANCE_REFUSAL)

    def test_invalid_fragrance_values_do_not_reach_database(self):
        invalid = [{'size':'0'},{'brand_id':'-1'},{'perfumer_id':'bad'},
                   {'price':'NaN'},{'price':'1.234'},{'price':'100000000.00'},
                   {'notes':'x'*256},{'fragrance_name':''},{'strength':'x'*46}]
        for changes in invalid:
            with self.subTest(changes=changes):
                self.assertEqual(self.call('/api/fragrances', self.fragrance_form(**changes))[0], 400)
        self.assertEqual(self.service.calls, [])

    def test_fragrance_submission_requires_csrf(self):
        self.assertEqual(self.call('/api/fragrances', self.fragrance_form(), csrf=False)[0], 403)
        self.assertEqual(self.service.calls, [])

    def test_preview_new_features_do_not_use_database_or_claim_success(self):
        self.service.preview = True
        for path in ['/api/stock?fragrance_name=Example','/api/top-sellers']:
            self.assertEqual(self.call(path)[0], 503)
        code, data = self.call('/api/fragrances', self.fragrance_form())
        self.assertEqual(code, 503)
        self.assertNotEqual(data['error'], ADD_FRAGRANCE_REFUSAL)
        self.assertEqual(self.service.calls, [])


if __name__ == '__main__':
    unittest.main()
