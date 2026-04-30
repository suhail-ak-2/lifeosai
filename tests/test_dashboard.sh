#!/usr/bin/env bash
# Tests for scripts/dashboard.sh
# Validates that the dashboard produces expected output sections.
# Requires LIFEOSAI_API_URL, LIFEOSAI_COMPANY_ID, LIFEOSAI_AGENT_ID to be set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DASHBOARD="$SCRIPT_DIR/scripts/dashboard.sh"
PASS=0
FAIL=0

assert_contains() {
  local label="$1"
  local pattern="$2"
  local text="$3"
  if echo "$text" | grep -q "$pattern"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label (expected pattern: $pattern)"
    FAIL=$((FAIL + 1))
  fi
}

echo "Running dashboard tests..."
echo ""

# Capture dashboard output
output=$(bash "$DASHBOARD" 2>&1)
exit_code=$?

# Test 1: Script exits successfully
if [ "$exit_code" -eq 0 ]; then
  echo "  PASS: Script exits with code 0"
  PASS=$((PASS + 1))
else
  echo "  FAIL: Script exited with code $exit_code"
  FAIL=$((FAIL + 1))
fi

# Test 2-7: Output contains expected sections
assert_contains "Has header"          "# Company Dashboard"          "$output"
assert_contains "Has timestamp"       "Generated:"                   "$output"
assert_contains "Has agents section"  "## Agents"                    "$output"
assert_contains "Has task summary"    "## Task Summary"              "$output"
assert_contains "Has recent activity" "## Recent Activity"           "$output"
assert_contains "Has summary"         "## Summary"                   "$output"

# Test 8: Task summary shows known statuses
assert_contains "Shows todo status"        "todo"         "$output"
assert_contains "Shows in_progress status" "in_progress"  "$output"
assert_contains "Shows done status"        "done"         "$output"
assert_contains "Shows blocked status"     "blocked"      "$output"

# Test 9: Agent table has headers
assert_contains "Agent table has Name column"   "Name"            "$output"
assert_contains "Agent table has Status column" "Status"          "$output"

# Test 10: Footer present
assert_contains "Has footer" "Dashboard v1.0" "$output"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
