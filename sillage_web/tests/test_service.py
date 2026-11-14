"""Connection selection tests. These do not implement or execute SQL."""
import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch

from service import Service


class ServiceTests(unittest.TestCase):
    def setUp(self):
        self.customer = {'user': 'customer', 'password': 'test-customer-only'}
        self.admin = {'user': 'admin', 'password': 'test-admin-only'}
        self.service = Service({'user':'scent_app'}, customer_config=self.customer, admin_config=self.admin)
        self.connection = Mock()
        self.service._connect = Mock(return_value=self.connection)

    def test_accounts_selected_from_server_role(self):
        for staff, profile in [(False,self.customer),(True,self.admin)]:
            with self.subTest(staff=staff):
                function = Mock(return_value=209)
                module = SimpleNamespace(ADD_FRAGRANCE_READY=True, add_fragrance=function)
                with patch('service.importlib.import_module', return_value=module):
                    self.assertEqual(self.service.add_fragrance({'fragrance_name':'Example'}, is_staff=staff), 209)
                self.service._connect.assert_called_with(profile)
                function.assert_called_once_with(self.connection, fragrance_name='Example')
                self.connection.close.assert_called()

    def test_student_database_exception_reaches_http_layer_unchanged(self):
        error = Exception('database error')
        error.errno = 1142
        module = SimpleNamespace(ADD_FRAGRANCE_READY=True, add_fragrance=Mock(side_effect=error))
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(Exception) as caught:
                self.service.add_fragrance({}, is_staff=False)
        self.assertIs(caught.exception, error)
        self.connection.close.assert_called_once()
        self.connection.commit.assert_not_called()
        self.connection.rollback.assert_not_called()

    def test_pending_function_does_not_open_connection(self):
        module = SimpleNamespace(ADD_FRAGRANCE_READY=False)
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(NotImplementedError):
                self.service.add_fragrance({}, is_staff=False)
        self.service._connect.assert_not_called()

    def test_missing_role_config_does_not_fall_back_to_application_account(self):
        service = Service({'user':'scent_app'})
        service._connect = Mock()
        module = SimpleNamespace(ADD_FRAGRANCE_READY=True)
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(NotImplementedError):
                service.add_fragrance({}, is_staff=True)
        service._connect.assert_not_called()

    def test_invalid_profile_pairs_rejected(self):
        pairs = [(self.customer,None),(self.customer,{'user':'root'}),
                 (self.customer,{'user':'customer'}),(self.customer,{'user':''})]
        for customer, admin in pairs:
            with self.subTest(customer=customer,admin=admin):
                with self.assertRaises(ValueError):
                    Service(customer_config=customer, admin_config=admin)

    def test_stock_and_seller_adapters_call_supplied_function_names(self):
        self.service._call = Mock(return_value=[])
        self.service.stock_location("L'Example")
        self.service._call.assert_called_with('reports','stock_location',"L'Example")
        self.service.top_seller()
        self.service._call.assert_called_with('reports','top_seller')

    def test_incomplete_student_result_is_not_accepted_as_success(self):
        module = SimpleNamespace(ADD_FRAGRANCE_READY=True, add_fragrance=Mock(return_value=None))
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(RuntimeError):
                self.service.add_fragrance({}, is_staff=True)
        self.connection.close.assert_called_once()


if __name__ == '__main__':
    unittest.main()
