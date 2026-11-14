"""Local classroom web application. Run python app.py --preview or python app.py --staff."""
import argparse
import getpass
import hashlib
import hmac
import json
import mimetypes
import os
import re
import secrets
import threading
import time
from datetime import date
from decimal import Decimal
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

from service import Service

ROOT = Path(__file__).resolve().parent
SESSION_SECONDS = 3600
ADD_FRAGRANCE_REFUSAL = "It looks like you can't add a fragrance! Come into one of our stores, or email us, and we will try to get the fragrance for you!"


class Problem(Exception):
    def __init__(self, message, status=400):
        self.message, self.status = message, status


def text_value(values, key, maximum=100):
    value = values.get(key, '')
    if not isinstance(value, str) or not value.strip() or len(value.strip()) > maximum:
        raise Problem('Please enter a valid ' + key.replace('_', ' ') + '.')
    return value.strip()


def positive_id(values, key):
    value = values.get(key)
    if isinstance(value, bool) or not str(value).isdigit():
        raise Problem('Please enter a positive ' + key.replace('_', ' ') + '.')
    value = int(value)
    if not 0 < value <= 2147483647:
        raise Problem('Please enter a valid ' + key.replace('_', ' ') + '.')
    return value


def fragrance_values(data):
    """Validate the five fields supported by the supplied fragrance INSERT."""
    price = str(data.get('price', ''))
    if not re.fullmatch(r'[0-9]{1,8}(?:\.[0-9]{1,2})?', price):
        raise Problem('Enter a price from 0 to 99999999.99, with at most two decimal places.')
    if any(data.get(key) not in (None, '') for key in ('perfumer_id', 'notes')):
        raise Problem('Perfumer and catalogue notes cannot be saved by this form. Reload and use the five supported fields.')
    return {
        'fragrance_name': text_value(data, 'fragrance_name', 100),
        'strength': text_value(data, 'strength', 45),
        'size': positive_id(data, 'size'),
        'price': Decimal(price),
        'brand_id': positive_id(data, 'brand_id'),
    }


def make_server(service, port=8000, staff_password=None):
    sessions, lock = {}, threading.Lock()
    password_salt = secrets.token_bytes(16)
    if staff_password and not callable(getattr(hashlib, 'pbkdf2_hmac', None)):
        raise RuntimeError(
            'Team-desk login requires hashlib.pbkdf2_hmac. Use a Python 3.10+ '
            'installation built with OpenSSL, and check that no local hashlib.py '
            'file or hashlib folder is hiding the standard-library module.'
        )

    def password_digest(password):
        # Some Python/OpenSSL builds do not expose scrypt. PBKDF2 avoids that
        # dependency while keeping a salted, deliberately expensive password hash.
        return hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), password_salt, 600_000)
    staff_digest = password_digest(staff_password) if staff_password else None

    class Handler(BaseHTTPRequestHandler):
        # Paths are a fixed allowlist: no filesystem paths supplied by the browser.
        ASSETS = {
            '/': ROOT / 'templates/index.html',
            '/static/style.css': ROOT / 'static/style.css',
            '/static/app.js': ROOT / 'static/app.js',
        }

        def log_message(self, fmt, *args):
            # Keep URL query strings and submitted data out of logs.
            print('%s %s' % (self.command, urlsplit(self.path).path))

        def session(self):
            cookie = SimpleCookie()
            try:
                cookie.load(self.headers.get('Cookie', ''))
                sid = cookie['sillage_session'].value if 'sillage_session' in cookie else None
            except Exception:
                sid = None
            with lock:
                now = time.time()
                for old in [k for k, v in sessions.items() if now - v['created'] > SESSION_SECONDS]:
                    sessions.pop(old, None)
                if sid not in sessions:
                    sid = secrets.token_urlsafe(32)
                    sessions[sid] = {'csrf': secrets.token_urlsafe(32), 'staff': False, 'created': now}
                self.sid, self.state = sid, sessions[sid]

        def send(self, status, body, content_type='application/json; charset=utf-8'):
            if not isinstance(body, bytes):
                body = json.dumps(body, default=str, ensure_ascii=False).encode()
            self.send_response(status)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', str(len(body)))
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.send_header('X-Frame-Options', 'DENY')
            self.send_header('Referrer-Policy', 'same-origin')
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'")
            self.send_header('Set-Cookie', 'sillage_session=' + self.sid + '; HttpOnly; SameSite=Strict; Path=/; Max-Age=3600')
            self.end_headers()
            self.wfile.write(body)

        def staff_only(self):
            if not self.state.get('staff'):
                raise Problem('Sign in to the team desk to use this feature.', 403)

        def live_only(self):
            if service.preview:
                raise Problem('This preview uses an uploaded catalogue snapshot. Run the app with MySQL to use this feature.', 503)

        def dispatch(self, method):
            self.session()
            try:
                self.route(method)
            except Problem as exc:
                self.send(exc.status, {'error': exc.message})
            except NotImplementedError:
                feature = 'brands' if urlsplit(self.path).path == '/api/brands' else 'fragrances'
                self.send(501, {'error': 'Adding ' + feature + ' is not available yet.'})
            except Exception as exc:
                errno = getattr(exc, 'errno', None)
                adding = urlsplit(self.path).path == '/api/fragrances' and method == 'POST'
                adding_brand = urlsplit(self.path).path == '/api/brands' and method == 'POST'
                restocking = urlsplit(self.path).path == '/api/restock' and method == 'POST'
                if adding and not self.state.get('staff') and errno in (1142, 1143):
                    message = ADD_FRAGRANCE_REFUSAL
                    status = 403
                elif adding and errno == 1062:
                    message = 'That fragrance, strength, and bottle size already exist for this house.'
                    status = 409
                elif adding and errno == 1452:
                    message = 'Choose an existing house for this fragrance.'
                    status = 422
                elif adding and errno in (1048, 1264, 1366, 1406, 3819):
                    message = 'One or more fragrance values do not meet the database requirements.'
                    status = 422
                elif adding and errno in (2006, 2013):
                    message = 'The database connection was lost. Check whether the fragrance was saved before trying again.'
                    status = 503
                elif adding_brand and errno == 1062:
                    message = 'A brand with that name already exists.'
                    status = 409
                elif adding_brand and errno == 1452:
                    message = 'Choose an existing country for this brand.'
                    status = 422
                elif adding_brand and errno in (1048, 1264, 1366, 1406, 3819):
                    message = 'One or more brand values do not meet the database requirements.'
                    status = 422
                elif adding_brand and errno == 1146:
                    message = 'The brand table could not be found. Ask the team to check its database name and capitalization.'
                    status = 503
                elif adding_brand and errno in (2006, 2013):
                    message = 'The database connection was lost. Check whether the brand was saved before trying again.'
                    status = 503
                elif restocking and errno in (1264, 1690, 3819):
                    message = 'The resulting bottle count exceeds the inventory limits. Check the current stock and quantity.'
                    status = 422
                elif errno in (1044, 1142, 1143, 1227, 1370):
                    message = 'MySQL refused this operation for the configured database account.'
                    status = 403
                elif errno == 1242:
                    message = 'More than one store matches that city. The current store report requires a unique city.'
                    status = 422
                else:
                    message = 'The database request could not be completed. Check the server connection and application account.'
                    status = 503
                # Error number only; never expose credentials, SQL or a traceback to visitors.
                print('Request failed; database error number:', errno)
                self.send(status, {'error': message})

        def route(self, method):
            parsed = urlsplit(self.path)
            path, query = parsed.path, parse_qs(parsed.query)
            if method == 'GET':
                if path in self.ASSETS:
                    file = self.ASSETS[path]
                    self.send(200, file.read_bytes(), mimetypes.guess_type(str(file))[0] + '; charset=utf-8')
                elif path == '/api/status':
                    self.send(200, {'csrf': self.state['csrf'], 'staff': self.state['staff'], 'staff_enabled': staff_digest is not None, 'preview': service.preview})
                elif path == '/api/catalog':
                    self.send(200, service.catalog())
                elif path == '/api/search':
                    self.live_only()
                    note = text_value({'note': query.get('note', [''])[0]}, 'note', 45)
                    self.send(200, {'rows': service.search(note)})
                elif path == '/api/natural':
                    self.live_only()
                    self.send(200, {'rows': service.natural()})
                elif path == '/api/stock':
                    self.live_only()
                    name = text_value({'fragrance_name': query.get('fragrance_name', [''])[0]}, 'fragrance_name', 100)
                    self.send(200, {'rows': service.stock_location(name)})
                elif path == '/api/top-sellers':
                    self.live_only()
                    self.send(200, {'rows': service.top_seller()})
                elif path in ('/api/revenue', '/api/discounts'):
                    self.staff_only()
                    self.live_only()
                    if path == '/api/revenue':
                        city = query.get('city', [''])[0].strip()
                        if len(city) > 45:
                            raise Problem('The city must be 45 characters or fewer.')
                        self.send(200, service.revenue(city or None))
                    else:
                        cutoff = query.get('before', [''])[0]
                        try:
                            cutoff = date.fromisoformat(cutoff) if cutoff else None
                        except ValueError:
                            raise Problem('Please choose a valid cutoff date.')
                        self.send(200, {'rows': service.discounts(cutoff)})
                else:
                    raise Problem('Page not found.', 404)
                return

            if method != 'POST':
                raise Problem('Method not allowed.', 405)
            if self.headers.get('Content-Type', '').split(';')[0] != 'application/json':
                raise Problem('Please send JSON.', 415)
            try:
                size = int(self.headers.get('Content-Length', 0))
            except ValueError:
                raise Problem('Invalid request size.')
            if not 0 < size <= 16384:
                raise Problem('The form is too large or empty.', 413)
            csrf = self.headers.get('X-CSRF-Token', '')
            if not hmac.compare_digest(csrf, self.state['csrf']):
                raise Problem('Your form has expired. Reload the page and try again.', 403)
            try:
                data = json.loads(self.rfile.read(size))
            except (ValueError, UnicodeDecodeError):
                raise Problem('The form could not be read.')
            if not isinstance(data, dict):
                raise Problem('Please submit a form object.')

            if path == '/api/staff/login':
                if staff_digest is None:
                    raise Problem('The team desk is disabled. Start the local app with --staff.', 503)
                password = data.get('password', '')
                if not isinstance(password, str) or len(password) > 1024:
                    raise Problem('Invalid team password.', 401)
                if not hmac.compare_digest(password_digest(password), staff_digest):
                    raise Problem('Invalid team password.', 401)
                with lock:
                    sessions.pop(self.sid, None)
                    self.sid = secrets.token_urlsafe(32)
                    self.state = {'csrf': secrets.token_urlsafe(32), 'staff': True, 'created': time.time()}
                    sessions[self.sid] = self.state
                self.send(200, {'csrf': self.state['csrf'], 'staff': True})
            elif path == '/api/staff/logout':
                with lock:
                    sessions.pop(self.sid, None)
                self.session()
                self.send(200, {'csrf': self.state['csrf'], 'staff': False})
            elif path == '/api/register':
                self.live_only()
                first, last = text_value(data, 'first_name', 45), text_value(data, 'last_name', 45)
                email = text_value(data, 'email', 100)
                if '@' not in email or '.' not in email.rsplit('@', 1)[1] or any(ch.isspace() for ch in email):
                    raise Problem('Please enter a valid email address.')
                country = positive_id(data, 'country_id')
                message = service.register(first, last, email, country)
                self.send(200 if 'registered successfully.' in message else 422, {'message': message})
            elif path == '/api/fragrances':
                self.live_only()
                # Both visitors and staff reach MySQL. Only the verified session
                # chooses the account; browser-supplied role/user fields are ignored.
                values = fragrance_values(data)
                fragrance_id = service.add_fragrance(values, is_staff=bool(self.state.get('staff')))
                self.send(201, {'message': 'Fragrance added successfully.', 'fragrance_id': fragrance_id})
            elif path == '/api/purchase':
                self.staff_only()
                self.live_only()
                customer, fragrance, store = [positive_id(data, key) for key in ('customer_id', 'fragrance_id', 'store_id')]
                message = service.purchase(customer, fragrance, store)
                self.send(200 if message == 'Purchase completed successfully.' else 422, {'message': message})
            elif path == '/api/restock':
                self.staff_only()
                self.live_only()
                store, fragrance, bottles = [positive_id(data, key) for key in ('store_id', 'fragrance_id', 'bottles')]
                message = service.restock(store, fragrance, bottles)
                self.send(200 if message == 'Restock completed.' else 422, {'message': message})
            elif path == '/api/brands':
                self.staff_only()
                self.live_only()
                values = {'name': text_value(data, 'name', 60), 'country_id': positive_id(data, 'country_id')}
                brand_id = service.add_brand(values)
                self.send(201, {'message': 'Brand added successfully.', 'brand_id': brand_id})
            else:
                raise Problem('Page not found.', 404)

        def do_GET(self):
            self.dispatch('GET')

        def do_POST(self):
            self.dispatch('POST')

    return ThreadingHTTPServer(('127.0.0.1', port), Handler)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--preview', action='store_true', help='Use catalogue snapshot; disable database features')
    parser.add_argument('--staff', action='store_true', help='Prompt for a separate team-desk password')
    parser.add_argument('--fragrance-accounts', action='store_true', help='Configure customer/admin MySQL accounts for Add Fragrance and Add Brand')
    parser.add_argument('--port', type=int, default=8000)
    args = parser.parse_args()
    config = None
    customer_config = admin_config = None
    if not args.preview:
        try:
            import mysql.connector
        except ImportError:
            parser.error('Install mysql-connector-python with: python -m pip install -r requirements.txt')
        user = os.environ.get('MYSQL_USER', 'scent_app')
        if user.lower() == 'root':
            parser.error('Use your team-created limited application account, not root.')
        config = {
            'host': os.environ.get('MYSQL_HOST', 'localhost'),
            'port': int(os.environ.get('MYSQL_PORT', '3306')),
            'user': user,
            'password': os.environ.get('MYSQL_PASSWORD') or getpass.getpass('MySQL application password: '),
            'database': os.environ.get('MYSQL_DATABASE', 'scent_db'),
            'connection_timeout': 8,
        }
        role_env = ('MYSQL_CUSTOMER_USER', 'MYSQL_CUSTOMER_PASSWORD', 'MYSQL_ADMIN_USER', 'MYSQL_ADMIN_PASSWORD')
        if args.fragrance_accounts or any(name in os.environ for name in role_env):
            profiles = []
            for role, default_user in [('CUSTOMER', 'customer'), ('ADMIN', 'admin')]:
                profile = dict(config)
                profile['user'] = os.environ.get('MYSQL_' + role + '_USER', default_user).strip()
                if not profile['user'] or profile['user'].lower() == 'root':
                    parser.error('Use the team-created non-root customer/admin accounts for Add Fragrance.')
                # Never fall back to the base application's password or connection.
                password_key = 'MYSQL_' + role + '_PASSWORD'
                profile['password'] = os.environ.get(password_key)
                if profile['password'] is None:
                    profile['password'] = getpass.getpass('MySQL password for ' + profile['user'] + ' (catalogue additions): ')
                profiles.append(profile)
            customer_config, admin_config = profiles
    staff_password = os.environ.get('SILLAGE_STAFF_PASSWORD')
    if args.staff and not staff_password:
        staff_password = getpass.getpass('Choose a team-desk password for this run (blank disables it): ')
    try:
        service = Service(config, preview=args.preview, customer_config=customer_config, admin_config=admin_config)
    except ValueError as exc:
        parser.error(str(exc))
    try:
        server = make_server(service, args.port, staff_password)
    except RuntimeError as exc:
        parser.error(str(exc))
    print('SILLAGE: http://127.0.0.1:%d' % server.server_port)
    print('Mode:', 'catalogue preview; no database writes' if args.preview else 'live MySQL')
    print('This local class demo uses Python HTTPServer. Stop with Ctrl+C.')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
