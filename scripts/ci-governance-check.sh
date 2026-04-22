#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Governance CI check starting..."

# 基本防呆
if [[ -z "${GITHUB_EVENT_PATH:-}" ]]; then
  echo "[FAIL] GITHUB_EVENT_PATH is not set"
  exit 1
fi

if [[ ! -f "$GITHUB_EVENT_PATH" ]]; then
  echo "[FAIL] GITHUB_EVENT_PATH file not found: $GITHUB_EVENT_PATH"
  exit 1
fi

# 檢查 jq 是否存在
if ! command -v jq >/dev/null 2>&1; then
  echo "[FAIL] jq is required but not installed"
  exit 1
fi

# 只接受 pull_request 事件
EVENT_NAME="$(jq -r '.action? // empty' "$GITHUB_EVENT_PATH" >/dev/null 2>&1; jq -r '.pull_request | type' "$GITHUB_EVENT_PATH" 2>/dev/null || true)"
if [[ "$EVENT_NAME" != "object" ]]; then
  echo "[FAIL] This governance check only supports pull_request events"
  exit 1
fi

# 讀取 PR 資訊
PR_TITLE="$(jq -r '.pull_request.title // ""' "$GITHUB_EVENT_PATH")"
PR_BODY="$(jq -r '.pull_request.body // ""' "$GITHUB_EVENT_PATH")"
PR_NUMBER="$(jq -r '.pull_request.number // ""' "$GITHUB_EVENT_PATH")"

echo "[INFO] PR #$PR_NUMBER"
echo "[INFO] PR title: $PR_TITLE"

if [[ -z "$(echo "$PR_BODY" | tr -d '[:space:]')" ]]; then
  echo "[FAIL] PR body is empty"
  exit 1
fi

echo "[INFO] Checking PR description content..."

# --------------------------------------------------
# 工具函式
# --------------------------------------------------

fail() {
  echo "[FAIL] $1"
  exit 1
}

pass() {
  echo "[PASS] $1"
}

# 從某個 markdown section 擷取內容
# 例如：
#   extract_section "Spec"
# 會抓 ## Spec 到下一個 ## 標題之間的內容
extract_section() {
  local section_name="$1"
  echo "$PR_BODY" | awk -v target="## ${section_name}" '
    $0 ~ "^## " {
      if (found && $0 != target) exit
    }
    $0 == target {
      found=1
      next
    }
    found { print }
  '
}

# 判斷文字是否非空白
is_nonempty() {
  local content="$1"
  [[ -n "$(echo "$content" | tr -d '[:space:]')" ]]
}

# --------------------------------------------------
# 擷取各段
# --------------------------------------------------

SPEC_SECTION="$(extract_section "Spec")"
ACCEPTANCE_SECTION="$(extract_section "Acceptance")"
EVIDENCE_SECTION="$(extract_section "Evidence")"
MAPPING_SECTION="$(extract_section "Acceptance to Evidence Mapping")"

# --------------------------------------------------
# 1. Spec section 必須存在且有內容
# --------------------------------------------------
if ! is_nonempty "$SPEC_SECTION"; then
  fail "## Spec section is missing or empty"
fi
pass "## Spec section exists"

# spec_id 必須存在且不是空白 placeholder
SPEC_ID_LINE="$(echo "$SPEC_SECTION" | grep -iE 'spec_id:' || true)"
if [[ -z "$SPEC_ID_LINE" ]]; then
  fail "spec_id is missing in ## Spec section"
fi

SPEC_ID_VALUE="$(echo "$SPEC_ID_LINE" | sed -E 's/.*spec_id:[[:space:]]*//I' | tr -d '\r')"
if [[ -z "$(echo "$SPEC_ID_VALUE" | tr -d '[:space:]')" ]]; then
  fail "spec_id is empty"
fi

# 常見 placeholder 擋掉
if echo "$SPEC_ID_VALUE" | grep -qiE 'replace|tbd|n/a|na|example|your-spec-id'; then
  fail "spec_id contains placeholder value: $SPEC_ID_VALUE"
fi

pass "spec_id is present: $SPEC_ID_VALUE"

# --------------------------------------------------
# 2. Acceptance section 必須存在且至少有一條 checklist
# --------------------------------------------------
if ! is_nonempty "$ACCEPTANCE_SECTION"; then
  fail "## Acceptance section is missing or empty"
fi

ACCEPTANCE_COUNT="$(echo "$ACCEPTANCE_SECTION" | grep -cE '^[[:space:]]*-[[:space:]]*\[[ xX]\]' || true)"
if [[ "$ACCEPTANCE_COUNT" -lt 1 ]]; then
  fail "## Acceptance must contain at least one checklist item"
fi
pass "## Acceptance contains checklist items: $ACCEPTANCE_COUNT"

# --------------------------------------------------
# 3. Evidence section 必須存在且有實質內容
# --------------------------------------------------
if ! is_nonempty "$EVIDENCE_SECTION"; then
  fail "## Evidence section is missing or empty"
fi

# 不能只有標題，至少要有 command 或 output 的非空內容
EVIDENCE_COMMAND_LINE="$(echo "$EVIDENCE_SECTION" | grep -iE 'command:' || true)"
EVIDENCE_OUTPUT_LINE="$(echo "$EVIDENCE_SECTION" | grep -iE 'output:' || true)"

if [[ -z "$EVIDENCE_COMMAND_LINE" && -z "$EVIDENCE_OUTPUT_LINE" ]]; then
  fail "## Evidence must include command: or output:"
fi

# 簡單判斷 Evidence 不是只有空架子
NONEMPTY_EVIDENCE_LINES="$(echo "$EVIDENCE_SECTION" | grep -E '[[:alnum:]]' | wc -l | tr -d ' ')"
if [[ "$NONEMPTY_EVIDENCE_LINES" -lt 2 ]]; then
  fail "## Evidence content is too empty"
fi

pass "## Evidence has non-empty content"

# --------------------------------------------------
# 4. Acceptance to Evidence Mapping 必須存在且至少一條 mapping
# --------------------------------------------------
if ! is_nonempty "$MAPPING_SECTION"; then
  fail "## Acceptance to Evidence Mapping section is missing or empty"
fi

MAPPING_COUNT="$(echo "$MAPPING_SECTION" | grep -cE 'Acceptance[[:space:]]+[0-9]+.*→.*[[:alnum:]]' || true)"
if [[ "$MAPPING_COUNT" -lt 1 ]]; then
  fail "## Acceptance to Evidence Mapping must contain at least one valid mapping line"
fi

pass "## Acceptance to Evidence Mapping contains mappings: $MAPPING_COUNT"

# --------------------------------------------------
# 5. 額外保護：若 spec file 有填，禁止 placeholder
# --------------------------------------------------
SPEC_FILE_LINE="$(echo "$SPEC_SECTION" | grep -iE 'spec file:' || true)"
if [[ -n "$SPEC_FILE_LINE" ]]; then
  SPEC_FILE_VALUE="$(echo "$SPEC_FILE_LINE" | sed -E 's/.*spec file:[[:space:]]*//I' | tr -d '\r')"
  if echo "$SPEC_FILE_VALUE" | grep -qiE 'replace|tbd|example'; then
    fail "Spec file contains placeholder value: $SPEC_FILE_VALUE"
  fi
fi

# --------------------------------------------------
# 完成
# --------------------------------------------------
echo "[PASS] Governance CI check passed"
exit 0