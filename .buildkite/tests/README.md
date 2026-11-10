# .buildkite/tests — pipeline gate tests (WAVE-26503 S1/S2)

Run from the repo root, no repo dependencies:

- Lockfile secret-scan coverage: `bash .buildkite/tests/foundation-secret-scan-lockfiles.sh`
  (needs bash; plants stand-in tokens in a temp tree and asserts the extra-step
  scanner fails closed on package-lock.json, yarn.lock, pnpm-lock.yaml, deno.lock,
  and go.sum)
- S1 fork refusal: `bats .buildkite/tests/guard-content-policy-fork.bats`
  (needs bats; rg optional — without rg the positive controls assert the
  script reaches the rg-missing fail-closed branch instead of the scan)
- S2 guard order + gating proof: `python3 .buildkite/tests/pipeline-gating.py`
  (needs python3 + pyyaml)

Both exit non-zero on failure. They are not wired into `ci.sh`: the FPC
agent image is not known to carry bats/pyyaml, and breaking `node-gates`
on missing test tooling would be worse than no gate. Wiring belongs to
WAVE-26516 (L1 fail-closed lint).
