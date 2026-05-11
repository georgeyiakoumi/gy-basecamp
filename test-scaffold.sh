#!/bin/bash

# ─────────────────────────────────────────────────────────────
# test-scaffold.sh
# Integration test for create-project.sh.
#
# Runs the script with pre-set inputs across key add-on
# combinations and asserts the output is correct — files,
# dependencies, GitHub repo, .env.local.
#
# Usage:
#   bash test-scaffold.sh
#
# Prerequisites: gh auth login, Node.js 18+, internet access.
# Cleanup: the test creates real GitHub repos. They are deleted
# automatically at the end unless --no-cleanup is passed.
# ─────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP=true
PASS=0
FAIL=0
FAILURES=()

# ── Flags ─────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --no-cleanup) CLEANUP=false ;;
  esac
done

# ── Colours ───────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────
pass() { echo -e "  ${GREEN}✓${RESET} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✗${RESET} $1"; ((FAIL++)); FAILURES+=("$1"); }

assert_file() {
  local file="$1"
  if [ -f "$file" ]; then pass "File exists: $file"
  else fail "Missing file: $file"; fi
}

assert_no_file() {
  local file="$1"
  if [ ! -f "$file" ]; then pass "Correctly absent: $file"
  else fail "Should not exist: $file"; fi
}

assert_dir() {
  local dir="$1"
  if [ -d "$dir" ]; then pass "Dir exists: $dir"
  else fail "Missing dir: $dir"; fi
}

assert_no_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then pass "Correctly absent: $dir"
  else fail "Should not exist: $dir"; fi
}

assert_contains() {
  local file="$1" pattern="$2"
  if grep -q "$pattern" "$file" 2>/dev/null; then pass "Contains '$pattern' in $file"
  else fail "Missing '$pattern' in $file"; fi
}

assert_not_contains() {
  local file="$1" pattern="$2"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then pass "Does not contain '$pattern' in $file"
  else fail "Should not contain '$pattern' in $file"; fi
}

assert_github_repo() {
  local repo="$1"
  if gh repo view "georgeyiakoumi/$repo" &>/dev/null; then pass "GitHub repo exists: $repo"
  else fail "GitHub repo missing: $repo"; fi
}

cleanup_project() {
  local name="$1" dir="$2"
  if [ "$CLEANUP" = true ]; then
    gh repo delete "georgeyiakoumi/$name" --yes 2>/dev/null || true
    rm -rf "$dir/$name" 2>/dev/null || true
    echo -e "  ${YELLOW}↳ Cleaned up: $name${RESET}"
  fi
}

# ── Determine test output dir ─────────────────────────────────
DRIVE_PATH="/Volumes/T7 Editing"
if [ -d "$DRIVE_PATH" ]; then
  TEST_DIR="$DRIVE_PATH/Projects"
else
  TEST_DIR="$HOME/Projects"
fi
mkdir -p "$TEST_DIR"

# ─────────────────────────────────────────────────────────────
# Test 1: Web app — no add-ons
# ─────────────────────────────────────────────────────────────
run_test_1() {
  local NAME="test-scaffold-web-plain-$$"
  echo ""
  echo -e "${BOLD}${CYAN}Test 1: Web app — no add-ons${RESET}"

  # Feed answers to the script's prompts:
  # Project name, project type (1=web app), supabase (n),
  # charts (n), shiki (n), sidebar (n), dark mode (Y),
  # visibility (1=private), confirm (y)
  printf '%s\n' \
    "$NAME" \
    "1" \
    "n" \
    "n" \
    "n" \
    "n" \
    "Y" \
    "1" \
    "y" \
    | bash "$SCRIPT_DIR/create-project.sh" > /dev/null 2>&1 || true

  local DIR="$TEST_DIR/$NAME"

  # Core files
  assert_file "$DIR/CLAUDE.md"
  assert_file "$DIR/package.json"
  assert_file "$DIR/app/globals.css"
  assert_file "$DIR/app/layout.tsx"
  assert_file "$DIR/app/page.tsx"
  assert_file "$DIR/.env.local"
  assert_file "$DIR/netlify.toml"
  assert_file "$DIR/lib/utils.ts"

  # No Supabase
  assert_no_dir "$DIR/lib/supabase"
  assert_no_file "$DIR/supabase/config.toml"

  # Dark mode wired into layout
  assert_contains "$DIR/app/layout.tsx" "ThemeProvider"
  assert_contains "$DIR/package.json" "next-themes"

  # No charts, no shiki
  assert_not_contains "$DIR/package.json" "recharts"
  assert_not_contains "$DIR/package.json" "shiki"

  # CLAUDE.md has project identity header
  assert_contains "$DIR/CLAUDE.md" "Type: Web app"

  # GitHub repo
  assert_github_repo "$NAME"

  cleanup_project "$NAME" "$TEST_DIR"
}

# ─────────────────────────────────────────────────────────────
# Test 2: Web app — all add-ons (Supabase, charts, shiki, sidebar)
# ─────────────────────────────────────────────────────────────
run_test_2() {
  local NAME="test-scaffold-web-full-$$"
  echo ""
  echo -e "${BOLD}${CYAN}Test 2: Web app — all add-ons${RESET}"

  printf '%s\n' \
    "$NAME" \
    "1" \
    "y" \
    "y" \
    "y" \
    "y" \
    "Y" \
    "1" \
    "y" \
    | bash "$SCRIPT_DIR/create-project.sh" > /dev/null 2>&1 || true

  local DIR="$TEST_DIR/$NAME"

  # Supabase
  assert_file "$DIR/lib/supabase/client.ts"
  assert_file "$DIR/lib/supabase/server.ts"
  assert_contains "$DIR/.env.local" "NEXT_PUBLIC_SUPABASE_URL"

  # Charts
  assert_contains "$DIR/package.json" "recharts"
  assert_contains "$DIR/app/globals.css" "--chart-1"

  # Shiki
  assert_contains "$DIR/package.json" "shiki"

  # Sidebar
  assert_contains "$DIR/app/globals.css" "--sidebar"

  # Dark mode
  assert_contains "$DIR/app/layout.tsx" "ThemeProvider"

  # GitHub repo
  assert_github_repo "$NAME"

  cleanup_project "$NAME" "$TEST_DIR"
}

# ─────────────────────────────────────────────────────────────
# Test 3: Prototype — no deployment, no Supabase
# ─────────────────────────────────────────────────────────────
run_test_3() {
  local NAME="test-scaffold-proto-$$"
  echo ""
  echo -e "${BOLD}${CYAN}Test 3: Prototype — no deployment target${RESET}"

  printf '%s\n' \
    "$NAME" \
    "5" \
    "n" \
    "n" \
    "n" \
    "Y" \
    "1" \
    "y" \
    | bash "$SCRIPT_DIR/create-project.sh" > /dev/null 2>&1 || true

  local DIR="$TEST_DIR/$NAME"

  # No Netlify config
  assert_no_file "$DIR/netlify.toml"

  # No Supabase
  assert_no_dir "$DIR/lib/supabase"

  # CLAUDE.md has correct type
  assert_contains "$DIR/CLAUDE.md" "Type: Prototype"

  # Core files still present
  assert_file "$DIR/app/page.tsx"
  assert_file "$DIR/package.json"

  # GitHub repo
  assert_github_repo "$NAME"

  cleanup_project "$NAME" "$TEST_DIR"
}

# ─────────────────────────────────────────────────────────────
# Test 4: Content site — Strapi subfolder created
# ─────────────────────────────────────────────────────────────
run_test_4() {
  local NAME="test-scaffold-content-$$"
  echo ""
  echo -e "${BOLD}${CYAN}Test 4: Content site — Strapi scaffold${RESET}"

  # Content site: no Supabase prompt (auto-included), no charts,
  # no shiki, no sidebar, dark mode Y, private, confirm y
  printf '%s\n' \
    "$NAME" \
    "3" \
    "n" \
    "n" \
    "n" \
    "Y" \
    "1" \
    "y" \
    | bash "$SCRIPT_DIR/create-project.sh" > /dev/null 2>&1 || true

  local DIR="$TEST_DIR/$NAME"

  # Strapi subfolder
  assert_dir "$DIR/strapi"
  assert_file "$DIR/strapi/README.md"

  # Supabase included automatically
  assert_file "$DIR/lib/supabase/client.ts"
  assert_contains "$DIR/.env.local" "NEXT_PUBLIC_STRAPI_URL"

  # GitHub repo
  assert_github_repo "$NAME"

  cleanup_project "$NAME" "$TEST_DIR"
}

# ─────────────────────────────────────────────────────────────
# Run all tests
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   create-project.sh test suite   ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════╝${RESET}"
echo ""
echo -e "Output dir: ${CYAN}$TEST_DIR${RESET}"
if [ "$CLEANUP" = false ]; then
  echo -e "${YELLOW}--no-cleanup: repos and folders will not be deleted${RESET}"
fi

run_test_1
run_test_2
run_test_3
run_test_4

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Results: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"

if [ ${#FAILURES[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}${BOLD}Failures:${RESET}"
  for f in "${FAILURES[@]}"; do
    echo -e "  ${RED}✗${RESET} $f"
  done
  exit 1
else
  echo ""
  echo -e "${GREEN}${BOLD}All tests passed.${RESET}"
fi
