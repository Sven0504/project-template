#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Governance CI check starting..."

# 檢查 README 是否包含 Spec / Evidence（最小 PR Gate 模擬）
if ! grep -q "Spec" README.md; then
  echo "[FAIL] README missing Spec section"
  exit 1
fi

if ! grep -q "Evidence" README.md; then
  echo "[FAIL] README missing Evidence section"
  exit 1
fi

# 檢查是否存在至少一個 trace 檔案
if ! ls docs/*trace.md >/dev/null 2>&1; then
  echo "[FAIL] No trace file found in docs/"
  exit 1
fi

echo "[PASS] Governance CI check passed"
exit 0
