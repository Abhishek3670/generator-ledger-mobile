#!/usr/bin/env python3
"""
Simple reverse-proxy server for Flutter web.
- Serves static files from build/web/
- Proxies /api/* requests to the backend API (avoids CORS issues)
"""

import http.server
import urllib.request
import urllib.error
import os
import sys

API_BACKEND = os.environ.get("API_BACKEND", "http://192.168.29.71:8000")
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")
PORT = int(os.environ.get("PORT", "8080"))

class ProxyHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_OPTIONS(self):
        """Handle CORS preflight."""
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header(
            "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS"
        )
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Access-Control-Max-Age", "600")
        self.end_headers()

    def _proxy(self, method):
        backends = [
            os.environ.get("API_BACKEND", "http://192.168.29.71:8000"),
            "http://192.168.29.60:8001",
        ]

        body = None
        if method in ("POST", "PUT", "PATCH"):
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length) if length else None

        headers = {}
        for key in ("Content-Type", "Authorization", "Accept"):
            val = self.headers.get(key)
            if val:
                headers[key] = val

        last_exception = None
        for backend in backends:
            url = f"{backend}{self.path}"
            try:
                req = urllib.request.Request(url, data=body, headers=headers, method=method)
                with urllib.request.urlopen(req, timeout=5) as resp:
                    resp_body = resp.read()
                    self.send_response(resp.status)
                    for key, val in resp.getheaders():
                        if key.lower() not in ("transfer-encoding", "connection"):
                            self.send_header(key, val)
                    self.send_header("Access-Control-Allow-Origin", "*")
                    self.end_headers()
                    self.wfile.write(resp_body)
                    return
            except Exception as e:
                last_exception = e
                continue

        self.send_response(502)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(
            f"Proxy error: All backends failed. Last error: {last_exception}".encode()
        )

    def do_GET(self):
        if self.path.startswith("/api/"):
            self._proxy("GET")
        else:
            super().do_GET()

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def do_POST(self):
        self._proxy("POST")

    def do_PUT(self):
        self._proxy("PUT")

    def do_DELETE(self):
        self._proxy("DELETE")

    def do_PATCH(self):
        self._proxy("PATCH")


if __name__ == "__main__":
    print(f"Serving Flutter web from: {WEB_DIR}")
    print(f"Proxying /api/* to: {API_BACKEND}")
    print(f"Listening on: 0.0.0.0:{PORT}")
    server = http.server.HTTPServer(("0.0.0.0", PORT), ProxyHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()
