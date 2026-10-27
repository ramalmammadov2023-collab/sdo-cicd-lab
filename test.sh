#!/bin/sh
# Usage: ./test.sh [image]      (default image: expo:1.0)
# Runs the container with several inputs and checks the output / exit code.

IMAGE="${1:-expo:1.0}"
FAILED=0

# check "<base> <exponent>" "<expected output>"
check() {
  out=$(docker run --rm "$IMAGE" $1 2>/dev/null)
  if [ "$out" = "$2" ]; then
    echo "PASS: $1 -> $out"
  else
    echo "FAIL: $1 -> got '$out', expected '$2'"
    FAILED=1
  fi
}

# check_fails "<base> <exponent>"   (the program must exit with an error)
check_fails() {
  if docker run --rm "$IMAGE" $1 >/dev/null 2>&1; then
    echo "FAIL: '$1' should have failed but succeeded"
    FAILED=1
  else
    echo "PASS: '$1' failed as expected"
  fi
}

check "2 10"   "2 ^ 10 = 1024"
check "5 0"    "5 ^ 0 = 1"
check "2 -1"   "2 ^ -1 = 0.5"
check "9 0.5"  "9 ^ 0.5 = 3"
check_fails "abc 2"
check_fails "-8 0.5"

if [ "$FAILED" -eq 0 ]; then
  echo "All tests passed"
else
  echo "Some tests failed"
fi
exit $FAILED
