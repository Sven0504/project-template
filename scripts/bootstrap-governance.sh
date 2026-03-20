#!/usr/bin/env bash
# bootstrap-governance.sh
# Purpose : Idempotent governance scaffold for project-template repos
# Behavior: Creates required governance files; logs INIT or SKIP per file
# Usage   : bash scripts/bootstrap-governance.sh
# Exit    : 0 = success, 1 = error

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# ─────────────────────────────────────────────
# STEP 1: Ensure directories exist (must run before any file operation)
#         Required for fully empty repos — no errors if dir already exists
# ─────────────────────────────────────────────
mkdir -p docs
mkdir -p docs/adr
mkdir -p template/docs
mkdir -p scripts
mkdir -p .github

# ─────────────────────────────────────────────
# STEP 2: Helper — idempotent file creation with INIT/SKIP logging
# ─────────────────────────────────────────────
create_file_if_missing() {
  local target_path="$1"
  local content="${2:-}"   # optional, default empty

  if [ -e "$target_path" ]; then
    echo "[SKIP] $target_path already exists"
  else
    echo "[INIT] Creating $target_path"
    printf '%s' "$content" > "$target_path" || {
      echo "[ERROR] Failed to write $target_path" >&2
      exit 1
    }
  fi
}

# ─────────────────────────────────────────────
# STEP 3: Bootstrap governance files
# ─────────────────────────────────────────────

create_file_if_missing "docs/BOOTSTRAP_CHECKLIST.md" \
"# BOOTSTRAP CHECKLIST

## Required Steps
- [ ] Fill in project_name in template/docs/project_rules.md
- [ ] Set current_phase
- [ ] Define active_specs
- [ ] Review immutable_paths and allowed_paths
- [ ] Confirm domain_constraints apply to this project
- [ ] Link first ADR under docs/adr/
"

create_file_if_missing "docs/adr/.gitkeep" ""

create_file_if_missing "template/docs/project_rules.md" \
"# project_rules.md
# Fill in all fields before first commit

project_name: \"<REPLACE_WITH_PROJECT_NAME>\"
current_phase: \"<REPLACE_WITH_PHASE>\"

source_of_truth:
  - specs/
  - tests/
  - docs/adr/
  - BOOTSTRAP_CHECKLIST.md

active_specs: []
immutable_paths: []
allowed_paths: []
domain_constraints: []
next_step_allowed: []
next_step_forbidden: []
"

# ─────────────────────────────────────────────
# STEP 4: Done
# ─────────────────────────────────────────────
echo "[DONE] bootstrap-governance.sh completed successfully"
exit 0
