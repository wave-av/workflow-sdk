#!/usr/bin/env bash
# foundation-secret-scan — GHA parity with _checks.yml job `checks`, step
# "Secret scan (fail-closed, allowlist-aware)". Patterns copied verbatim from
# the vendored _checks.yml; keep in sync with wave-foundation checks.yml@v1  # guard:allow shared checks repo mention (verified-safe reference)
# on every v1.x bump, exactly like the GHA file.
set -euo pipefail
cd "$(dirname "$0")/../.."

# Real-secret patterns. Lines tagged "pragma: allowlist secret" (e.g. test fixtures / regex
# definitions) are skipped — that's how a vetting module can define key-shapes without tripping.
# Include Slack incoming webhooks and GitHub OAuth/App/refresh + GitLab PAT shapes:
# gitleaks 8.30.1 with extend.useDefault skips lockfiles (package-lock.json, yarn.lock,
# pnpm-lock.yaml, deno.lock, go.sum) and content-policy.sh applies the same lockfile
# ignores, so those families would otherwise have no required gate in lockfiles.
HITS=$(grep -rIEn '(sk-[A-Za-z0-9]{20}|sk_(live|test)_[A-Za-z0-9]{20}|npm_[A-Za-z0-9]{30}|sbp_[a-f0-9]{40}|github_pat_[A-Za-z0-9_]{40}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{30}|gho_[A-Za-z0-9]{36}|ghs_[A-Za-z0-9]{36}|ghu_[A-Za-z0-9]{36}|ghr_[A-Za-z0-9]{36}|glpat-[A-Za-z0-9_-]{20,}|AIzaSy[A-Za-z0-9_-]{20}|xai-[A-Za-z0-9]{40}|xoxb-[A-Za-z0-9-]+|hooks\.slack\.com/services/[A-Za-z0-9]+/[A-Za-z0-9]+/[A-Za-z0-9]+|-----BEGIN [A-Z ]*PRIVATE KEY)' \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist . | grep -v 'allowlist secret' \
  | { [ -f .github/.secret-allowlist ] && grep -vFf .github/.secret-allowlist || cat; } || true)
if [ -n "$HITS" ]; then echo "secret-like pattern found — do not commit credentials"; echo "$HITS"; exit 1; fi
echo "secret-scan clean"
