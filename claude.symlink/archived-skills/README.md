# archived-skills

歸檔的 Claude Code skill。**這個目錄不在 `~/.claude/skills/` 底下，所以不會被
Claude Code 掃描、不會出現在 skill 清單、不佔用每個 session 的系統提示。**

## 為什麼歸檔

2026-07-26 對 `~/.claude/projects` 的 5088 個 session 檔（涵蓋 2026-06-25 ~ 07-26
整整一個月）做交叉統計，比對三種調用訊號：`Skill` 工具、`/slash` 指令、
`SKILL.md` 路徑載入。以下 skill 在該期間 **零調用**。

### SuperClaude 罐頭批次（25 個）

`ai-engineer` `architect` `checkpoint` `code-review` `context-report` `debug`
`dx-optimizer` `env-dx` `funnel-config` `hook` `human-write` `mail` `map`
`perf` `prime` `prompt-engineer` `refactor` `research-plan-implement` `retro`
`sc` `security` `test-auto` `update-dev-docs` `vale` `vm-docker`

除 `code-review`（2026-04-03）外全部在 2026-04-06 同一天寫入，之後從未編輯。
description 是 `Build LLM apps...`、`Design system architecture...` 這類泛泛描述，
與 Claude 內建行為重疊，沒有專屬腳本或私人設定 —— 不會被觸發是必然的。

部分項目仍附帶可用腳本，歸檔而非刪除即為此：

| skill | 附帶資產 |
| --- | --- |
| `mail` | `scripts/` 下 5 個 AppleScript + 編譯好的 `reminders-cli` (Swift) |
| `human-write` | `ai-words.yml`、`chinese-patterns.md`、`scan-ai-words.py` |
| `map` | `scripts/symbol_map.py` |
| `retro` | `extract_conversation.py` |
| `env-dx` | `scripts/scan.sh` |

### 第三方 plugin（1 個）

`claude-seo` — 4.1 MB，20+ 個 sub-skill 與 sub-agent 全部掛在 skill 清單上，
零使用。它**不在** `~/.claude/plugins/installed_plugins.json` 裡，是靠
`~/.claude/skills/claude-seo/` 自身被發現的，所以搬離該目錄即失效，
不需要 `/plugin uninstall`。因體積過大列在 `.gitignore`，僅存於本機。

## 還原

```bash
command mv ~/.claude/archived-skills/<name> ~/.claude/skills/<name>
```

或從 git 歷史取回（`claude-seo` 除外，它未進 repo）：

```bash
git -C ~/.dotfiles log --follow -- claude.symlink/archived-skills/<name>
```

## 未歸檔的低使用 skill

以下同樣一個月零調用，但**保留在 `skills/`**：它們有真實腳本與個人憑證，
屬於「暫時沒需求」而非「本來就沒用」，重建成本高。

`anki` `argdown` `codex-imagegen` `deepseek-webgui` `defer` `end-to-end-study`
`img-hosting`
