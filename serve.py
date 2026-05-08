#!/usr/bin/env python3
"""Local dev server for Godot HTML5 exports.

Serves files with correct MIME types and CORS headers required by Godot 4.6.
Usage: python3 serve.py [port]
"""

import http.server
import os
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

MIME_TYPES = {
    ".html": "text/html",
    ".js": "text/javascript",
    ".wasm": "application/wasm",
    ".pck": "application/octet-stream",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".svg": "image/svg+xml",
    ".ico": "image/x-icon",
    ".json": "application/json",
    ".css": "text/css",
}

CORS_HEADERS = {
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "require-corp",
}


class GodotHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.dirname(__file__), **kwargs)

    def guess_type(self, path):
        ext = os.path.splitext(path)[1].lower()
        return MIME_TYPES.get(ext, "application/octet-stream")

    def end_headers(self):
        for key, value in CORS_HEADERS.items():
            self.send_header(key, value)
        super().end_headers()


if __name__ == "__main__":
    print(f"Bubble Match — local server")
    print(f"http://localhost:{PORT}")
    print("Press Ctrl+C to stop.")
    http.server.HTTPServer(("0.0.0.0", PORT), GodotHandler).serve_forever()
