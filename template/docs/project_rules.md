# project_rules.md
# 此檔案為專案骨架範本，每個新專案應複製並填寫以下欄位

project_name: "<REPLACE_WITH_PROJECT_NAME>"

current_phase: "<REPLACE_WITH_PHASE>"  # e.g. Foundation / Governance / Feature

source_of_truth:
  - specs/
  - tests/
  - docs/adr/
  - BOOTSTRAP_CHECKLIST.md

bootstrap_checklist_canonical_path: docs/BOOTSTRAP_CHECKLIST.md

active_specs:
  - "<REPLACE: e.g. specs/feature-x.md>"

immutable_paths:
  - src/
  - app/
  - components/
  - db/
  - migrations/
  # Add project-specific immutable paths below

allowed_paths:
  - docs/
  - template/
  - scripts/
  - .github/
  - README.md
  # Add project-specific allowed paths below

domain_constraints:
  - "No production business logic in governance phase"
  - "No pricing / batch / audit domain logic changes without ADR"
  - "<REPLACE: Add project-specific constraints>"

next_step_allowed:
  - "Create new specs under specs/"
  - "Add ADR under docs/adr/"
  - "Update README.md for usage clarity"
  - "<REPLACE: Add phase-specific allowed steps>"

next_step_forbidden:
  - "Modify any path under immutable_paths"
  - "Skip ADR for cross-domain changes"
  - "Merge without evidence in PR template"
  - "<REPLACE: Add phase-specific forbidden steps>"
