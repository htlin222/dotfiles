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
