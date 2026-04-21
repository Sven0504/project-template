#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Governance CI check starting..."

# 抓這次 PR 的變更內容
git diff origin/main...HEAD > pr.diff

echo "[INFO] Checking PR content..."

# 檢查 PR 是否有 spec
if ! grep -qi "spec" pr.diff; then
  echo "[FAIL] No spec reference found in PR changes"
  exit 1
fi

# 檢查 PR 是否有 evidence
if ! grep -qi "evidence" pr.diff; then
  echo "[FAIL] No evidence reference found in PR changes"
  exit 1
fi

echo "[PASS] Governance CI check passed"
exit 0