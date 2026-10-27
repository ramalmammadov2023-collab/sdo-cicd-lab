# A very small web server. It does two things:
#   1. shows index.html when you open the page
#   2. runs our C program (inside Docker) when the page asks for a calculation
#
# Start it with:  python3 server.py
# Then open:      http://localhost:8000

import json
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

IMAGE = "expo:1.0"   # the image we built in Level 1
PORT = 8000


class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        url = urlparse(self.path)

        if url.path == "/":
            self.show_page()
        elif url.path == "/calculate":
            self.calculate(parse_qs(url.query))
        else:
            self.send_error(404)

    # Send index.html to the browser
    def show_page(self):
        with open("index.html", "rb") as f:
            page = f.read()
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(page)

    # Run: docker run --rm expo:1.0 <base> <exponent>
    def calculate(self, query):
        base = query.get("base", [""])[0]
        exponent = query.get("exponent", [""])[0]

        # The inputs go in as separate arguments (not as a shell command),
        # so the user cannot sneak extra commands in.
        run = subprocess.run(
            ["docker", "run", "--rm", IMAGE, base, exponent],
            capture_output=True, text=True, timeout=20
        )

        # Exit code 0 = success. Anything else = the C program reported an error.
        if run.returncode == 0:
            answer = {"ok": True, "output": run.stdout.strip()}
        else:
            answer = {"ok": False, "output": run.stderr.strip() or "Something went wrong."}

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(answer).encode())


print("Open http://localhost:%d in your browser (Ctrl+C to stop)" % PORT)
HTTPServer(("localhost", PORT), Handler).serve_forever()