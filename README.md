# project-template

> **此 repo 的角色：Project Template（非 Governance Kernel）**
>
> 本 repo 是新專案的**起始骨架**（scaffold），提供治理結構與規範範本。
> ❌ 本 repo **不是** Governance Kernel，不持有執行層治理規則的唯一來源。
> ✅ 每個新專案從本 repo 複製後，需自行維護其 `project_rules.md` 等文件。

---

## 使用方式

### 1. 從此 repo 建立新專案

```bash
# 方法一：直接 clone 後重新 init
git clone https://github.com/<your-org>/project-template my-new-project
cd my-new-project
rm -rf .git
git init
git checkout -b main
```

```bash
# 方法二：使用 GitHub Template Repository 功能
# 點擊 GitHub 頁面上的「Use this template」按鈕
```

### 2. 執行 Bootstrap Script

```bash
# 在新專案目錄中執行（需要 bash 環境）
bash scripts/bootstrap-governance.sh
```

**執行行為：**
- 首次執行：輸出 `[INIT] Creating <path>` 並建立所有治理文件
- 再次執行：輸出 `[SKIP] <path> already exists`（冪等，不覆寫）
- 成功結束：`exit 0`；發生錯誤：`exit 1`

---

## 責任邊界

### 需要每個專案自行填寫的檔案

| 檔案 | 說明 |
|------|------|
| `template/docs/project_rules.md` | 填入 `project_name`、`current_phase`、`active_specs`、`domain_constraints` 等 |
| `docs/BOOTSTRAP_CHECKLIST.md` | 確認每個步驟已完成 |
| `.github/PULL_REQUEST_TEMPLATE.md` | 填入 Acceptance to Evidence Mapping |

### 外部治理依賴

以下規則**來自外部治理文件（非此 repo 管轄）**，各專案須自行引用或遵循：

**External Governance Dependencies (Minimum Set)**

| 文件 | 說明 |
|------|------|
| `agent_execution_protocol.md` | Agent 執行協議規範 |
| `execution_determinism.md` | 執行確定性規則 |
| `spec_execution_mapping.md` | Spec 與執行映射關係 |
| `execution_trace_spec.md` | 執行追蹤格式規範 |

> 若專案引入 Governance Kernel，上述文件由 Kernel 統一管理。

---

## 目錄結構說明

```
project-template/
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md   # PR 範本（含驗收映射）
├── docs/
│   ├── BOOTSTRAP_CHECKLIST.md     # 初始化確認清單
│   └── adr/                       # Architecture Decision Records
├── scripts/
│   └── bootstrap-governance.sh    # 治理骨架初始化腳本
└── template/
    └── docs/
        └── project_rules.md       # 專案規則範本（需填寫）
```

---

## 重要聲明

- 本 repo 可被獨立理解與使用，不依賴任何特定對話或口頭說明
- 所有治理邊界均以本 README 及 `project_rules.md` 為準
- 若有疑問，請查閱 `docs/BOOTSTRAP_CHECKLIST.md` 的完成狀態
