#!/usr/bin/env bash
# Assert foundation-secret-scan catches Slack webhook / GitHub OAuth shapes in
# lockfiles that gitleaks 8.30.1 skips under extend.useDefault. Generates
# stand-in tokens at runtime; nothing credential-shaped is committed.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCAN="$ROOT/.buildkite/scripts/foundation-secret-scan.sh"
[[ -x "$SCAN" ]] || { echo "missing $SCAN"; exit 2; }

fail=0
assert_script_has() {
  local pat="$1"
  if grep -qE "$pat" "$SCAN"; then
    echo "ok: scanner source contains $pat"
  else
    echo "fail: scanner source missing $pat"
    fail=1
  fi
}
assert_script_has 'gho_\[A-Za-z0-9\]\{36\}'
assert_script_has 'ghs_\[A-Za-z0-9\]\{36\}'
assert_script_has 'glpat-'
assert_script_has 'hooks\\.slack\\.com/services'

run_overlay() {
  local relpath="$1"
  local body="$2"
  local expect="$3"
  local work
  work="$(mktemp -d)"
  trap 'rm -rf -- "$work"' RETURN
  mkdir -p "$work/.buildkite/scripts" "$work/$(dirname "$relpath")"
  cp "$SCAN" "$work/.buildkite/scripts/foundation-secret-scan.sh"
  chmod +x "$work/.buildkite/scripts/foundation-secret-scan.sh"
  printf '%s\n' "$body" > "$work/$relpath"
  local rc=0
  (cd "$work" && bash .buildkite/scripts/foundation-secret-scan.sh >/dev/null 2>&1) || rc=$?
  if [[ "$expect" == hit && "$rc" -eq 1 ]]; then
    echo "ok: $relpath detected (exit $rc)"
  elif [[ "$expect" == clean && "$rc" -eq 0 ]]; then
    echo "ok: $relpath clean (exit $rc)"
  else
    echo "fail: $relpath expected $expect, got exit $rc"
    fail=1
  fi
}

webhook="https://hooks.slack.com/services/$(printf 'A%.0s' {1..10})/$(printf 'B%.0s' {1..10})/$(printf 'C%.0s' {1..24})"
gho="gho_$(printf 'D%.0s' {1..36})"
ghs="ghs_$(printf 'E%.0s' {1..36})"
glpat="glpat-$(printf 'F%.0s' {1..20})"

run_overlay package-lock.json "{\"resolved\":\"$webhook\"}" hit
run_overlay yarn.lock "token $gho" hit
run_overlay pnpm-lock.yaml "token $ghs" hit
run_overlay deno.lock "token $glpat" hit
run_overlay go.sum "token $webhook" hit
run_overlay package-lock.json '{"resolved":"https://registry.npmjs.org/left-pad/-/left-pad-1.3.0.tgz"}' clean

if (( fail > 0 )); then
  echo "foundation-secret-scan lockfile tests failed"
  exit 1
fi
echo "foundation-secret-scan lockfile tests passed"
