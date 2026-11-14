"""Real brand route/service/student-function checks using database doubles."""
import ast
from decimal import Decimal
from pathlib import Path
import unittest
from unittest.mock import Mock

import test_fragrance_insert as fragrance_helpers


class BrandFlowTests(unittest.TestCase):
    setUp = fragrance_helpers.FragranceFlowTests.setUp
    tearDown = fragrance_helpers.FragranceFlowTests.tearDown
    call = fragrance_helpers.FragranceFlowTests.call
    login = fragrance_helpers.FragranceFlowTests.login
    fragrance_form = fragrance_helpers.FragranceFlowTests.fragrance_form

    def test_admin_brand_insert_saves_country_id_and_returns_id(self):
        self.login()
        self.cursor.lastrowid = 6
        code,data = self.call('/api/brands', {'name':"L'Example",'country_id':'3'})
        self.assertEqual((code,data['brand_id']),(201,6))
        self.service._connect.assert_called_once_with(self.admin)
        self.connection.cursor.assert_called_once_with(dictionary=True)
        self.assertEqual(self.cursor.execute.call_args.args[1],("L'Example",3))
        self.connection.commit.assert_called_once()
        self.cursor.close.assert_called_once()
        self.connection.close.assert_called_once()

    def test_customer_cannot_select_admin_or_insert_brand(self):
        code,_ = self.call('/api/brands',{'name':'New','country_id':3,'role':'admin','is_staff':True})
        self.assertEqual(code,403)
        self.service._connect.assert_not_called()

    def test_brand_database_errors_propagate_without_commit_or_retry(self):
        self.login()
        for errno,status,phrase in [(1062,409,'already exists'),(1452,422,'country'),
                                   (1142,403,'MySQL refused'),(1146,503,'capitalization')]:
            with self.subTest(errno=errno):
                self.service._connect.reset_mock()
                self.connection.reset_mock()
                self.cursor.execute.side_effect=fragrance_helpers.DatabaseFailure(errno)
                code,data=self.call('/api/brands',{'name':'New','country_id':3})
                self.assertEqual(code,status)
                self.assertIn(phrase,data['error'])
                self.assertNotIn('PRIVATE',data['error'])
                self.assertNotIn('brand_id',data)
                self.connection.commit.assert_not_called()
                self.service._connect.assert_called_once_with(self.admin)
                self.connection.close.assert_called_once()

    def test_brand_failed_commit_never_reports_success_or_retries(self):
        self.login()
        self.connection.commit.side_effect=fragrance_helpers.DatabaseFailure(2013)
        code,data=self.call('/api/brands',{'name':'New','country_id':3})
        self.assertEqual(code,503)
        self.assertNotIn('brand_id',data)
        self.assertIn('Check whether the brand was saved',data['error'])
        self.cursor.execute.assert_called_once()
        self.connection.commit.assert_called_once()
        self.service._connect.assert_called_once_with(self.admin)
        self.connection.close.assert_called_once()

    def test_brand_then_fragrance_uses_returned_brand_id(self):
        self.login()
        brand_connection,fragrance_connection=Mock(),Mock()
        brand_connection.cursor.return_value.lastrowid=6
        fragrance_connection.cursor.return_value.lastrowid=209
        self.service._connect.side_effect=[brand_connection,fragrance_connection]
        code,brand=self.call('/api/brands',{'name':'New house','country_id':3})
        self.assertEqual(code,201)
        code,fragrance=self.call('/api/fragrances',self.fragrance_form(brand_id=brand['brand_id']))
        self.assertEqual((code,fragrance['fragrance_id']),(201,209))
        self.assertEqual(fragrance_connection.cursor.return_value.execute.call_args.args[1],
                         ('Team Example','Eau de Parfum',50,Decimal('125.50'),6))
        for connection in (brand_connection,fragrance_connection):
            connection.commit.assert_called_once()
            connection.close.assert_called_once()
        self.assertTrue(all(call.args==(self.admin,) for call in self.service._connect.call_args_list))

    def test_brand_missing_profiles_remains_unavailable_without_fallback(self):
        self.login()
        self.service.admin_config=None
        code,data=self.call('/api/brands',{'name':'New','country_id':3})
        self.assertEqual(code,501)
        self.assertNotIn('brand_id',data)
        self.service._connect.assert_not_called()


class BrandSourceTests(unittest.TestCase):
    def test_supplied_brand_body_only_renames_connection(self):
        root=Path(__file__).resolve().parents[1]
        source=ast.parse((root/'docs/supplied_catalog_script.txt').read_text())
        adapted=ast.parse((root/'student_code/brands.py').read_text())
        original=next(n for n in source.body if isinstance(n,ast.FunctionDef) and n.name=='insert_brand')
        actual=next(n for n in adapted.body if isinstance(n,ast.FunctionDef) and n.name=='insert_brand')

        class ConnectionName(ast.NodeTransformer):
            def visit_Name(self,node):
                if node.id=='mysql_conn':node.id='connection'
                return node

        original=ConnectionName().visit(original)
        self.assertEqual(ast.dump(ast.Module(body=actual.body,type_ignores=[]),include_attributes=False),
                         ast.dump(ast.Module(body=original.body,type_ignores=[]),include_attributes=False))
        self.assertEqual(actual.args.defaults,[])
        self.assertEqual([a.arg for a in actual.args.args],['connection','country_id','name'])


if __name__ == '__main__':
    unittest.main()
