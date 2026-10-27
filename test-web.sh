#!/bin/sh
# Usage: sh test-web.sh
# The server must already be running:  python3 server.py
# Asks the website questions with curl and checks the replies.

URL="http://localhost:8000"
FAILED=0

# check "<name>" "<address>" "<text that must appear in the reply>"
check() {
  reply=$(curl -s "$URL$2")
  if echo "$reply" | grep -qF -- "$3"; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 -> got '$reply', expected it to contain '$3'"
    FAILED=1
  fi
}

check "home page loads"       "/"                               "Exponent Calculator"
check "2 ^ 10"                "/calculate?base=2&exponent=10"   "2 ^ 10 = 1024"
check "5 ^ 0"                 "/calculate?base=5&exponent=0"    "5 ^ 0 = 1"
check "square root of 9"      "/calculate?base=9&exponent=0.5"  "9 ^ 0.5 = 3"
check "abc is rejected"       "/calculate?base=abc&exponent=2"  "\"ok\": false"
check "-8 ^ 0.5 is rejected"  "/calculate?base=-8&exponent=0.5" "\"ok\": false"

if [ "$FAILED" -eq 0 ]; then
  echo "All website tests passed"
else
  echo "Some website tests failed"
fi
exit $FAILED