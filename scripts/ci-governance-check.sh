#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Governance CI check starting..."

# 取得 PR 描述
PR_BODY=$(jq -r .pull_request.body "$GITHUB_EVENT_PATH")

echo "[INFO] Checking PR description..."

# 檢查 spec
if ! echo "$PR_BODY" | grep -qi "spec"; then
  echo "[FAIL] No spec found in PR description"
  exit 1
fi

# 檢查 evidence
if ! echo "$PR_BODY" | grep -qi "evidence"; then
  echo "[FAIL] No evidence found in PR description"
  exit 1
fi

echo "[PASS] Governance CI check passed"
exit 0