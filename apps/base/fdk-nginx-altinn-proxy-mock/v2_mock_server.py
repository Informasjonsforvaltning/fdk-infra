#!/usr/bin/env python3
from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

DATA_ROOT = Path("/mockdataV2")
BY_SSN = Path("/mockdataV2-by-ssn")
SUPERSET_FILE = DATA_ROOT / "authorizedparties.json"


def load_json(path: Path):
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


class Handler(BaseHTTPRequestHandler):
    def _write_json(self, payload, code=200):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path.split("?")[0] != "/accessmanagement/api/v1/resourceowner/authorizedparties":
            self._write_json({"error": "not found"}, code=404)
            return

        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length > 0 else b"{}"
        try:
            payload = json.loads(raw.decode("utf-8"))
        except Exception:
            payload = {}

        ssn = str(payload.get("value") or "").strip()
        if ssn and ssn.isdigit():
            target_name = f"{ssn}.json"
            for candidate in BY_SSN.iterdir():
                if candidate.name == target_name:
                    self._write_json(load_json(candidate), code=200)
                    return

        self._write_json(load_json(SUPERSET_FILE), code=200)

    def log_message(self, fmt, *args):
        return


def main():
    server = ThreadingHTTPServer(("127.0.0.1", 8081), Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()

