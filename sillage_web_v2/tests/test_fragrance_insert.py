"""Real web/service/student-function chain with database connection doubles."""
import ast
from pathlib import Path
import threading
import unittest
from unittest.mock import Mock
from http.cookiejar import CookieJar
from urllib.request import build_opener, HTTPCookieProcessor

from app import ADD_FRAGRANCE_REFUSAL, make_server
from service import Service
import test_web as web_helpers


class DatabaseFailure(Exception):
    def __init__(self, errno):
        self.errno = errno
        super().__init__('PRIVATE DATABASE DETAIL')


class FragranceFlowTests(unittest.TestCase):
    # Reuse request helpers without inheriting unrelated tests.
    call = web_helpers.WebTests.call
    login = web_helpers.WebTests.login
    fragrance_form = web_helpers.WebTests.fragrance_form

    def setUp(self):
        self.admin = {'user':'admin'}
        self.customer = {'user':'customer'}
        self.service = Service({'user':'scent_app'}, customer_config=self.customer, admin_config=self.admin)
        self.connection = Mock()
        self.cursor = self.connection.cursor.return_value
        self.cursor.lastrowid = 209
        self.service._connect = Mock(return_value=self.connection)
        self.server = make_server(self.service, 0, 'test-team-password')
        self.thread = threading.Thread(target=self.server.serve_forever, kwargs={'poll_interval':.02}, daemon=True)
        self.thread.start()
        self.url = 'http://127.0.0.1:' + str(self.server.server_port)
        self.client = build_opener(HTTPCookieProcessor(CookieJar()))
        self.csrf = self.call('/api/status')[1]['csrf']

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()

    def test_admin_insert_commits_once_and_returns_generated_id(self):
        self.login()
        code,data=self.call('/api/fragrances',self.fragrance_form())
        self.assertEqual((code,data['fragrance_id']),(201,209))
        self.service._connect.assert_called_once_with(self.admin)
        self.connection.cursor.assert_called_once_with(dictionary=True)
        from decimal import Decimal
        self.assertEqual(self.cursor.execute.call_args.args[1],
                         ('Team Example','Eau de Parfum',50,Decimal('125.50'),1))
        self.connection.commit.assert_called_once()
        self.cursor.close.assert_called_once()
        self.connection.close.assert_called_once()

    def test_customer_mysql_refusal_uses_exact_message_without_admin_retry(self):
        self.cursor.execute.side_effect=DatabaseFailure(1142)
        code,data=self.call('/api/fragrances',self.fragrance_form(role='admin',is_staff=True))
        self.assertEqual((code,data['error']),(403,ADD_FRAGRANCE_REFUSAL))
        self.service._connect.assert_called_once_with(self.customer)
        self.connection.commit.assert_not_called()
        self.connection.close.assert_called_once()

    def test_commit_failure_does_not_report_saved_id_or_retry(self):
        self.login()
        self.connection.commit.side_effect=DatabaseFailure(2013)
        code,data=self.call('/api/fragrances',self.fragrance_form())
        self.assertEqual(code,503)
        self.assertNotIn('fragrance_id',data)
        self.assertNotIn('PRIVATE',data['error'])
        self.assertIn('Check whether the fragrance was saved',data['error'])
        self.service._connect.assert_called_once_with(self.admin)
        self.cursor.execute.assert_called_once()
        self.connection.commit.assert_called_once()
        self.connection.close.assert_called_once()

    def test_duplicate_and_foreign_key_failure_do_not_commit(self):
        self.login()
        for errno,status in [(1062,409),(1452,422)]:
            with self.subTest(errno=errno):
                self.connection.reset_mock()
                self.cursor.execute.side_effect=DatabaseFailure(errno)
                code,data=self.call('/api/fragrances',self.fragrance_form())
                self.assertEqual(code,status)
                self.assertNotIn('fragrance_id',data)
                self.connection.commit.assert_not_called()
                self.connection.close.assert_called_once()


class FragranceSourceTests(unittest.TestCase):
    def test_supplied_function_body_only_changes_connection_name(self):
        root=Path(__file__).resolve().parents[1]
        source=ast.parse((root/'docs/supplied_catalog_script.txt').read_text())
        adapted=ast.parse((root/'student_code/fragrances.py').read_text())
        original=next(n for n in source.body if isinstance(n,ast.FunctionDef) and n.name=='insert_fragrance')
        actual=next(n for n in adapted.body if isinstance(n,ast.FunctionDef) and n.name=='insert_fragrance')

        class ConnectionName(ast.NodeTransformer):
            def visit_Name(self,node):
                if node.id=='mysql_conn':
                    node.id='connection'
                return node

        original=ConnectionName().visit(original)
        expected=ast.dump(ast.Module(body=original.body,type_ignores=[]),include_attributes=False)
        observed=ast.dump(ast.Module(body=actual.body,type_ignores=[]),include_attributes=False)
        self.assertEqual(observed,expected)
        self.assertEqual(actual.args.defaults,[])
        self.assertEqual([a.arg for a in actual.args.args],['connection','name','strength','size','brand','price'])


if __name__ == '__main__':
    unittest.main()
