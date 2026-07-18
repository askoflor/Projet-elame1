#!/usr/bin/env python3
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse
import threading

HOST = '127.0.0.1'
PORT = 8080

users_by_email = {}
tokens = {}

class Handler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(204)

    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length).decode('utf-8') if length else ''
        try:
            data = json.loads(body) if body else {}
        except Exception:
            data = {}

        if parsed.path == '/api/v1/auth/register':
            email = data.get('email', '')
            password = data.get('password', '')
            role = data.get('role', 'CLIENT')
            if not email or not password:
                self._set_headers(400)
                self.wfile.write(json.dumps({'message':'Email et mot de passe requis'}).encode())
                return
            if email in users_by_email:
                self._set_headers(409)
                self.wfile.write(json.dumps({'message':'Utilisateur déjà existant'}).encode())
                return
            user = {'id': len(users_by_email)+1, 'email': email, 'role': role}
            users_by_email[email] = {'password': password, 'user': user}
            token = f"token-{hash(email)}-{__import__('time').time()}"
            tokens[token] = user
            self._set_headers(200)
            self.wfile.write(json.dumps({'token': token, 'user': user}).encode())
            return

        if parsed.path == '/api/v1/auth/login':
            email = data.get('email', '')
            password = data.get('password', '')
            stored = users_by_email.get(email)
            if not stored or stored.get('password') != password:
                self._set_headers(401)
                self.wfile.write(json.dumps({'message':'Email ou mot de passe incorrect'}).encode())
                return
            user = stored['user']
            token = f"token-{hash(email)}-{__import__('time').time()}"
            tokens[token] = user
            self._set_headers(200)
            self.wfile.write(json.dumps({'token': token, 'user': user}).encode())
            return

        if parsed.path == '/api/v1/auth/logout':
            auth = self.headers.get('Authorization','')
            if auth.startswith('Bearer '):
                token = auth[7:]
                tokens.pop(token, None)
            self._set_headers(200)
            self.wfile.write(json.dumps({'message':'Logged out'}).encode())
            return

        self._set_headers(404)
        self.wfile.write(json.dumps({'message':'Not found'}).encode())

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == '/api/v1/auth/me':
            auth = self.headers.get('Authorization','')
            if not auth.startswith('Bearer '):
                self._set_headers(401)
                self.wfile.write(json.dumps({'message':'Unauthorized'}).encode())
                return
            token = auth[7:]
            user = tokens.get(token)
            if not user:
                self._set_headers(401)
                self.wfile.write(json.dumps({'message':'Unauthorized'}).encode())
                return
            self._set_headers(200)
            self.wfile.write(json.dumps(user).encode())
            return
        self._set_headers(404)
        self.wfile.write(json.dumps({'message':'Not found'}).encode())

def run_server():
    server = HTTPServer((HOST, PORT), Handler)
    print(f"Mock server listening at http://{HOST}:{PORT}")
    server.serve_forever()

if __name__ == '__main__':
    run_server()
