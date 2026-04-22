#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Governance CI check starting..."

# ----------------------------
# 基本防呆
# ----------------------------
if [[ -z "${GITHUB_EVENT_PATH:-}" ]]; then
  echo "[FAIL] GITHUB_EVENT_PATH not set"
  exit 1
fi

if [[ ! -f "$GITHUB_EVENT_PATH" ]]; then
  echo "[FAIL] Event file not found"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[FAIL] jq not installed"
  exit 1
fi

# ----------------------------
# 讀 PR body
# ----------------------------
PR_BODY=$(jq -r .pull_request.body "$GITHUB_EVENT_PATH")

if [[ -z "$(echo "$PR_BODY" | tr -d '[:space:]')" ]]; then
  echo "[FAIL] PR body is empty"
  exit 1
fi

echo "[INFO] PR body loaded"

# ----------------------------
# 檢查 spec_id（必須非空）
# ----------------------------
SPEC_ID=$(echo "$PR_BODY" | grep -i "spec_id:" | sed 's/.*spec_id:[[:space:]]*//I' || true)

if [[ -z "$(echo "$SPEC_ID" | tr -d '[:space:]')" ]]; then
  echo "[FAIL] spec_id missing or empty"
  exit 1
fi

# 擋 placeholder
if echo "$SPEC_ID" | grep -qiE "replace|tbd|example|na"; then
  echo "[FAIL] spec_id is placeholder: $SPEC_ID"
  exit 1
fi

echo "[PASS] spec_id OK → $SPEC_ID"

# ----------------------------
# 檢查 Evidence（不能只有標題）
# ----------------------------
EVIDENCE_BLOCK=$(echo "$PR_BODY" | awk '/## Evidence/{flag=1;next}/##/{flag=0}flag')

if [[ -z "$(echo "$EVIDENCE_BLOCK" | grep -E '[a-zA-Z0-9]')" ]]; then
  echo "[FAIL] Evidence section empty"
  exit 1
fi

echo "[PASS] Evidence OK"

# ----------------------------
# 檢查 Mapping（必須有實際對應）
# ----------------------------
MAPPING_BLOCK=$(echo "$PR_BODY" | awk '/## Acceptance to Evidence Mapping/{flag=1;next}/##/{flag=0}flag')

if [[ -z "$(echo "$MAPPING_BLOCK" | grep '→')" ]]; then
  echo "[FAIL] Acceptance to Evidence Mapping missing or invalid"
  exit 1
fi

echo "[PASS] Mapping OK"

# ----------------------------
# 檢查 Acceptance checklist
# ----------------------------
ACCEPTANCE_BLOCK=$(echo "$PR_BODY" | awk '/## Acceptance/{flag=1;next}/##/{flag=0}flag')

CHECKLIST_COUNT=$(echo "$ACCEPTANCE_BLOCK" | grep -c "\[.\]" || true)

if [[ "$CHECKLIST_COUNT" -lt 1 ]]; then
  echo "[FAIL] Acceptance checklist missing"
  exit 1
fi

echo "[PASS] Acceptance checklist OK ($CHECKLIST_COUNT items)"

# ----------------------------
# 全部通過
# ----------------------------
echo "[PASS] Governance CI check passed"
exit 0