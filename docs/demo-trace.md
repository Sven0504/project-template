# demo-trace.md
# Execution Trace for spec demo-001

spec_id: demo-001

command_executed: |
  git add docs/demo.txt
  git commit -m "feat(governance): add spec container and demo audit loop"
  git show --stat --name-only HEAD

output: |
  docs/demo.txt was created with content tracing back to demo-001.
  git show --stat --name-only HEAD shows docs/demo.txt in the commit.
  All changed files are within allowed paths (docs/).

matched_acceptance:
  - "Create docs/demo.txt → PASS (file exists at docs/demo.txt)"
  - "The change is visible in git diff or git show → PASS (confirmed by git show --stat)"

result: PASS

evidence_reference: |
  - File: docs/demo.txt (created by this trace)
  - git show --stat --name-only HEAD (see commit evidence in walkthrough)
  - All modifications within allowed paths: docs/, specs/, tests/, template/, README.md
  - No forbidden paths touched: src/, app/, components/, db/, migrations/
