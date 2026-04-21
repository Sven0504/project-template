spec_id: governance-ci-fix-001

command_executed: |
  Edited scripts/ci-governance-check.sh
  Created specs/governance-ci-fix-001.md
  Created docs/governance-ci-fix-001-trace.md

output: |
  Governance CI check now inspects PR diff content.
  This PR contains a dedicated spec and trace for the CI governance fix.

matched_acceptance:
  - "Update scripts/ci-governance-check.sh to inspect PR diff → PASS"
  - "Add a trace file documenting this governance fix → PASS"
  - "No production paths are modified → PASS"

result: PASS

evidence_reference: |
  - scripts/ci-governance-check.sh
  - specs/governance-ci-fix-001.md
  - docs/governance-ci-fix-001-trace.md