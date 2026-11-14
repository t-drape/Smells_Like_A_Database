"""Connection selection tests. These do not implement or execute SQL."""
import unittest
from decimal import Decimal
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
        self.fragrance_values = {'fragrance_name':"L'Example", 'strength':'Eau de Parfum',
                                 'size':50, 'brand_id':3, 'price':Decimal('125.50')}

    def test_accounts_selected_from_server_role(self):
        for staff, profile in [(False,self.customer),(True,self.admin)]:
            with self.subTest(staff=staff):
                function = Mock(return_value=209)
                module = SimpleNamespace(ADD_FRAGRANCE_READY=True, insert_fragrance=function)
                with patch('service.importlib.import_module', return_value=module):
                    self.assertEqual(self.service.add_fragrance(self.fragrance_values, is_staff=staff), 209)
                self.service._connect.assert_called_with(profile)
                function.assert_called_once_with(self.connection, name="L'Example", strength='Eau de Parfum',
                                                 size=50, brand=3, price=Decimal('125.50'))
                self.connection.close.assert_called()

    def test_student_database_exception_reaches_http_layer_unchanged(self):
        error = Exception('database error')
        error.errno = 1142
        module = SimpleNamespace(ADD_FRAGRANCE_READY=True, insert_fragrance=Mock(side_effect=error))
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(Exception) as caught:
                self.service.add_fragrance(self.fragrance_values, is_staff=False)
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
        module = SimpleNamespace(ADD_FRAGRANCE_READY=True, insert_fragrance=Mock(return_value=None))
        with patch('service.importlib.import_module', return_value=module):
            with self.assertRaises(RuntimeError):
                self.service.add_fragrance(self.fragrance_values, is_staff=True)
        self.connection.close.assert_called_once()

    def test_restock_runs_supplied_function_and_closes_base_connection(self):
        cursor = self.connection.cursor.return_value
        cursor.rowcount = 1
        self.assertEqual(self.service.restock(2,7,12),'Restock completed.')
        self.service._connect.assert_called_once_with()
        # Verify the form's store/fragrance/count order reaches the student's
        # existing execute tuple in the correct count/store/fragrance order.
        self.assertEqual(cursor.execute.call_args.args[1],(12,2,7))
        self.connection.commit.assert_called_once()
        self.connection.rollback.assert_not_called()
        cursor.close.assert_called_once()
        self.connection.close.assert_called_once()

    def test_restock_missing_row_does_not_commit(self):
        self.connection.cursor.return_value.rowcount=0
        self.assertEqual(self.service.restock(2,7,12),'Not a currently stocked item')
        self.connection.commit.assert_not_called()
        self.connection.close.assert_called_once()

    def test_restock_exception_closes_connection_without_retry(self):
        error=Exception('database refused')
        self.connection.cursor.return_value.execute.side_effect=error
        with self.assertRaises(Exception) as caught:
            self.service.restock(2,7,12)
        self.assertIs(caught.exception,error)
        self.service._connect.assert_called_once_with()
        self.connection.commit.assert_not_called()
        self.connection.close.assert_called_once()

    def test_brand_uses_admin_connection_and_student_save_contract(self):
        function=Mock(return_value=6)
        module=SimpleNamespace(ADD_BRAND_READY=True,insert_brand=function)
        with patch('service.importlib.import_module',return_value=module):
            self.assertEqual(self.service.add_brand({'name':'House','country_id':3}),6)
        self.service._connect.assert_called_once_with(self.admin)
        function.assert_called_once_with(self.connection,name='House',country_id=3)
        self.connection.commit.assert_not_called()
        self.connection.rollback.assert_not_called()
        self.connection.close.assert_called_once()

    def test_pending_brand_function_and_missing_admin_do_not_connect(self):
        for ready in (False,True):
            service=Service({'user':'scent_app'})
            service._connect=Mock()
            module=SimpleNamespace(ADD_BRAND_READY=ready)
            with patch('service.importlib.import_module',return_value=module):
                with self.assertRaises(NotImplementedError):
                    service.add_brand({})
            service._connect.assert_not_called()

    def test_brand_error_and_invalid_return_close_connection(self):
        error=Exception('refused');error.errno=1142
        function=Mock(side_effect=error)
        module=SimpleNamespace(ADD_BRAND_READY=True,insert_brand=function)
        with patch('service.importlib.import_module',return_value=module):
            with self.assertRaises(Exception) as caught:
                self.service.add_brand({})
            self.assertIs(caught.exception,error)
            function.side_effect=None
            for value in (None,True,0,-1,'6'):
                function.return_value=value
                with self.assertRaises(RuntimeError):
                    self.service.add_brand({})
        self.assertEqual(self.connection.close.call_count,6)
        self.connection.commit.assert_not_called()
        self.connection.rollback.assert_not_called()


if __name__ == '__main__':
    unittest.main()
