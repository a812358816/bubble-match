#!/usr/bin/env python3
"""Local dev server for Godot HTML5 exports.

Serves files with correct MIME types, CORS headers, and pre-compressed support.
Usage: python3 serve.py [port]
"""

import http.server
import os
import sys
import gzip

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
ROOT = os.path.dirname(__file__)

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
    ".ttf": "font/ttf",
}

CORS_HEADERS = {
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "require-corp",
}

CACHE_MAX_AGE = 86400  # 1 day for immutable assets like wasm/pck


class GodotHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def guess_type(self, path):
        ext = os.path.splitext(path)[1].lower()
        return MIME_TYPES.get(ext, "application/octet-stream")

    def end_headers(self):
        for key, value in CORS_HEADERS.items():
            self.send_header(key, value)
        super().end_headers()

    def translate_path(self, path):
        """Map .gz paths to real files."""
        return super().translate_path(path)

    def send_head(self):
        """Serve .gz compressed version if available and client supports it."""
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            return super().send_head()

        accept_encoding = self.headers.get("Accept-Encoding", "")
        supports_gzip = "gzip" in accept_encoding

        # Try pre-compressed .gz for wasm/pck/js files
        if supports_gzip and path.endswith((".wasm", ".pck", ".js")):
            gz_path = path + ".gz"
            if os.path.isfile(gz_path):
                self.path = self.path + ".gz"
                self.send_response(200)
                self.send_header("Content-Type", self.guess_type(path))
                self.send_header("Content-Encoding", "gzip")
                self.send_header("Vary", "Accept-Encoding")
                self.send_header("Cache-Control", f"public, max-age={CACHE_MAX_AGE}, immutable")
                self.send_header("Content-Length", str(os.path.getsize(gz_path)))
                for key, value in CORS_HEADERS.items():
                    self.send_header(key, value)
                self.end_headers()
                return open(gz_path, "rb")

        # Cache headers for immutable assets
        if path.endswith((".wasm", ".pck")):
            self.send_response(200)
            self.send_header("Cache-Control", f"public, max-age={CACHE_MAX_AGE}, immutable")

        return super().send_head()


def ensure_compressed():
    """Generate .gz files for large assets if missing."""
    for name in ["index.wasm", "index.pck", "index.js"]:
        fpath = os.path.join(ROOT, name)
        gz_path = fpath + ".gz"
        if os.path.isfile(fpath):
            if not os.path.isfile(gz_path) or os.path.getmtime(fpath) > os.path.getmtime(gz_path):
                size = os.path.getsize(fpath)
                print(f"  Compressing {name} ({size / 1024 / 1024:.1f}MB) ... ", end="", flush=True)
                with open(fpath, "rb") as src:
                    with gzip.open(gz_path, "wb", compresslevel=9) as dst:
                        dst.write(src.read())
                gz_size = os.path.getsize(gz_path)
                print(f"{gz_size / 1024 / 1024:.1f}MB ({(1 - gz_size / size) * 100:.0f}% saved)")
                print(f"  {name} → {gz_size / 1024 / 1024:.1f}MB ({int((1 - gz_size / size) * 100)}% saved)")


if __name__ == "__main__":
    ensure_compressed()
    print(f"Bubble Match — http://localhost:{PORT}")
    print("Press Ctrl+C to stop.")
    http.server.HTTPServer(("0.0.0.0", PORT), GodotHandler).serve_forever()
