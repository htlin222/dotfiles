# SuperClaude

## Env

- **pkg**: node=pnpm, python=uv+venv
- **rm**: use `rip` not `rm`
- **alias**: use `command <tool>` for cp, mv, ln to bypass shell aliases

## Essential Files

@CORE.md
@FLAGS.md
@PERSONAS.md

## Delegation Rule

Small edits (Edit, ≤5 MultiEdits, ≤500-line Write) are allowed directly.
Large edits (big Write, many MultiEdits, multi-file refactors) → delegate to Task subagents.
Config/docs (.md, CLAUDE.md, plans/\*, settings.json, Makefile, .gitignore, go-tools/\*\*) always allowed.

## Git Workflow — `develop` 為唯一整合點

**預設假設**：repo 的 default branch 是 `develop`；`main` 只代表已上線的正式狀態。
除非使用者明說，否則 agent 一律遵守以下規則。

### 硬規則

| 情境 | 做法 |
| --- | --- |
| 開新分支 | 先 `git pull origin develop`，再從最新 `develop` 切出 |
| 開 PR | base **一律** `develop`；絕不直接對 `main` 開 PR（hotfix 除外） |
| 合進 `develop` | **squash merge**（1 ticket = 1 commit） |
| `develop` → `main` | **merge commit**（保留批次邊界），不 squash |
| 直接 push `develop`/`main` | ❌ 禁止，一律走 PR |
| 送審前 | 先 rebase 到最新 `develop` 或按 GitHub "Update branch"，避免用舊基底過 CI |
| 合併條件 | CI 全綠 + ≥1 approve |
| 分支壽命 | >2–3 天就該拆小；合併後刪除 head branch |

### 發版批次

`develop` 穩定後開 release PR：`develop` → `main`，PR 描述列出本批 ticket；
合併後在 `main` 打 tag（`v1.x`）。出事就退回上一個 tag。
固定節奏發版（每週或每兩週），避免 `develop`/`main` 差距擴大成一次大爆炸。

### 唯一例外：hotfix

正式機著火時不繞 `develop`：
`main` → 切 `hotfix/xxx` → 修 → PR 回 `main` → 上線 → **立刻把 `main` 合回 `develop`**。
⚠️ 最後一步最常被忘記，漏掉的話下次發版會把修補蓋掉 — agent 必須主動提醒或執行。

### 環境對應

`develop` → 自動部署測試機；`main` → 自動部署正式機。分支狀態即環境狀態，不靠人工同步。

### 停止條件

`develop` 紅燈（CI fail）時：全員停止合併，先修 `develop`。

### 一次性 GitHub 設定（新 repo 或流程尚未落地時提醒使用者）

1. Default branch 改 `develop`（PR base 預設不會誤選 `main`）
2. `develop` / `main` 都加 branch protection：禁止直接 push、必經 PR
3. `develop`：CI 全綠 + ≥1 approve
4. `main`：只接受來自 `develop` 的 PR
5. 開啟 auto-delete head branches

## Dev Flow — Issue → 上線

`Ticket → 分支 → 實作 → PR → Review → CI → CD → tag`
每一關都在回答「憑什麼相信這段程式碼可以上線」。

- **起點是 ticket，不是程式碼**。沒票就先幫使用者把需求寫成一句可驗收的敘述。
- **分支命名** `類型/範圍-動作`：`fix/connectors-error`、`feat/admin-analyze`。只用 `fix`/`feat` 兩個前綴。
- **AI 開發循環**：`/develop` → `/simplify`（砍多餘抽象）→ `/code-review`（自審）→ 開 PR。
  ⚠️ 中間兩步不可略過：跳過等於把 AI 的噪音丟給隊友 review。
- **PR 要小、單一目的、寫「為什麼」**（「改了什麼」diff 自己會講）。不順手改風格、不順手重構。
- **Review 兩層有序**：先 lint/AI 清機械問題，人再看設計方向與可讀性。
- **CI** 在乾淨環境重建全部依賴再跑測試——證明的是「從零開始也會動」。
  **10 分鐘紅線**：超過就沒人等，等於沒測試。
- **CD** = `pull → migrate → restart`，必須是腳本不是人；每次部署打 tag，可回滾。
- **測試金字塔**：大量 unit、適量 integration、少量關鍵路徑 E2E。
  ⚠️ **禁止先跑程式再把輸出填成期望值** — 期望值由規格決定。想不出預期值代表需求沒想清楚，回頭釐清規格。

**導入順序**（既有專案缺什麼就從上往下補）：
分支命名+PR → lint 自動化 → unit test+CI → 部署腳本化 → integration/E2E → AI 輔助。
紀律未成立就先上 AI，放大的會是錯誤流入正式環境的速度。

## On-Demand (use --verbose or when needed)

- COMMANDS.md - Full command reference
- MCP.md - MCP server details
- MODES.md - Mode details
- PRINCIPLES.md - Design principles

@RTK.md

## MCQ 批量筆記構建 (enrich-note 項目)

### 目標

將 OpenEvidence 的詳細回答（含高頻考點整理）作為 URL 連結存入 MCQ 筆記系統。

### 工具和文件

- **主腳本**：`/Users/htlin/enrich-note/run_batch.py`
  - 支持題號範圍：114-110 年各 001-100 題（共 500 題）
  - 並行度：5 線程
  - 流程：Round-1 (OE ask) → Round-2 (追問高頻考點) → Write Note

- **配置**：`/Users/htlin/enrich-note/.env`
  - MCQ_API_BASE、MCQ_API_KEY、MCQ_USER_EMAIL

- **說明文檔**：`/Users/htlin/enrich-note/BUILD_NOTES.md`

### 執行方式

**只能在交互式 Claude Code 會話中運行**（OpenEvidence MCP 需要 OAuth 授權）

```bash
cd /Users/htlin/enrich-note
python3 run_batch.py
```

首次運行會彈出權限提示 → 允許 OpenEvidence MCP 授權 → 自動開始批量構建

### 流程原理

#### Round-1：向 OpenEvidence 提問題目

```
for qid in QID_LIST:
  問題 = get_mcq.py 取題目
  article_id = oe_ask(問題)  # wait_for_completion=true
  保存 article_id
```

#### Round-2：在同一對話中追問高頻考點

```
for qid in QID_LIST:
  追問內容 = "以疾病、機轉/治療為出發點，高頻考點分類..."
  oe_ask(追問內容, original_article_id=article_id)  # 關鍵：同一對話
  # 回答會直接嵌入同一 OE 對話中
```

#### Write Note：存入連結

```
for qid in QID_LIST:
  URL = https://www.openevidence.com/ask/{article_id}
  筆記內容 = "## OpenEvidence 對話\n{URL}\n\n此對話包含..."
  get_mcq.py QID --note "筆記內容"  # 寫入 MCQ 系統
```

### 為什麼需要交互式授權？

**OpenEvidence MCP OAuth 機制**：

1. **非交互式腳本無法授權**
   - OAuth 需要用戶在瀏覽器中登錄並點擊「允許」
   - 後台腳本沒有用戶交互界面
   - MCP 工具會返回「需要授權」錯誤並卡住

2. **交互式 Claude Code 可以授權**
   - Claude Code 界面可以彈出權限提示
   - 用戶可以實時點擊「允許」
   - 授權完成後，後續調用不再需要授權

3. **安全設計**
   - 防止惡意腳本偷偷訪問用戶帳戶
   - 授權必須由用戶親自確認

### 調試技巧

- 修改 QID_LIST 前 N 項：`QID_LIST = QID_LIST[:5]`
- 監控進度：實時輸出每題的 Round-1/2/Note 狀態
- 失敗統計：最後輸出成功/失敗計數

### 預計時間

- 5 題：5-10 分鐘
- 50 題：30-45 分鐘
- 500 題：3-5 小時（取決於 OpenEvidence API 速度）
