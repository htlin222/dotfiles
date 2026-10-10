---
name: dev-docs
description: 為跨 session 的長任務建立並維護一份「下一個 session 讀得懂」的文件系統（plan / context / tasks），並在壓縮前更新它。Use when starting a large multi-session task, before major refactoring, when work will survive context compaction, or when resuming a task started in an earlier session.
argument-hint: "[任務名稱 | resume]"
allowed-tools: Read Write Edit Glob Grep Bash(git status:*) Bash(git log:*) Bash(ls:*)
---

# /dev-docs — 讓下一個 session 不用重新考古

context 會被壓縮，session 會結束，你會忘記為什麼三天前選了那個做法。
這支 skill 把「必須活過壓縮的東西」寫進檔案。

`/context-engineering` 管的是**這個任務該看到什麼**；
這支管的是**跨 session 該留下什麼**。

---

## 什麼時候用

- 任務跨多個 session，或預期會被壓縮至少一次
- 大型重構、需要多階段推進的功能
- 恢復一個之前 session 開的任務（`/dev-docs resume`）

### 不要用在

| 情境 | 理由 |
| --- | --- |
| 單一 session 做得完 | 建三個檔案的成本大於收益，用任務清單就好 |
| 一次性的小修 | 文件比改動還長 |
| 只是想記錄結論 | 那該進 commit message 或 repo 文件 |

⚠️ **文件不是目的。** 每一段的存在理由都是「下一個 session 少讀 20 個檔案」。
寫不出這個理由的段落就刪掉。

---

## Step 1 — 先看有沒有既有的

```bash
ls dev/active/
```

有同名或相近的目錄 → **讀它，接續**，不要另開一份。
兩份半殘的計畫比一份完整的更糟。

## Step 2 — 建立結構

```
dev/active/<task-name>/
├── plan.md      # 為什麼、要做什麼、怎麼算完成
├── context.md   # 事實與決策（這份最值錢）
└── tasks.md     # 進度
```

`<task-name>` 用 kebab-case，跟分支名對齊（`feat/admin-analyze` → `admin-analyze`）。

## Step 3 — 三份檔案，各有嚴格的職責

### plan.md — 意圖

```markdown
# <任務> — 實作計畫

## 目標
一句可驗收的完成條件：「當 ___ 時，___ 應該 ___」

## 策略
高層做法，3–5 句。為什麼是這個做法，不是另一個。

## 架構決策
| 決策 | 理由 | 被否決的選項與原因 |
| --- | --- | --- |

## 風險
| 風險 | 緩解 |
| --- | --- |

## 驗收條件
- [ ] 具體、可檢查的條件
```

⚠️ **「被否決的選項」欄位不能空。** 下一個 session 最容易犯的錯，
就是重新提議一個三天前已經否決過的方案。

### context.md — 事實與決策（最值錢的一份）

```markdown
# <任務> — Context

## 關鍵檔案
| 路徑 | 為什麼相關 |
| --- | --- |

## 既有 pattern
從 codebase 找到、要照抄的寫法（附 `file.ts:45-60`）

## 相依
| 套件@版本 | 為什麼需要 | 來源 |
| --- | --- | --- |

## 決策紀錄
| 日期 | 決策 | 理由 |
| --- | --- | --- |

## 已知地雷
踩過的坑、繞過的問題、不要再試的方向
```

⚠️ 日期寫**絕對日期**（`2026-08-10`），不要寫「昨天」「上週」。

⚠️ 「已知地雷」是這份文件裡回報率最高的一段 ——
它擋掉的是下一個 session 重蹈同一個覆轍的兩小時。

### tasks.md — 進度

```markdown
# <任務> — Tasks

## Phase 1: 名稱
- [x] 已完成的任務 (S) — 2026-08-10, commit abc1234
- [ ] 進行中的任務 (M)
- [ ] 還沒開始 (L)

Legend: (S)mall / (M)edium / (L)arge
```

⚠️ 打勾的項目要附**證據**（commit hash 或測試輸出），不是自我宣告。

同時把當前 phase 的項目建進任務清單工具，讓進度在對話裡也看得見。

## Step 4 — 更新紀律

| 時機 | 更新什麼 |
| --- | --- |
| 每完成一個任務 | `tasks.md` 打勾 + 附 commit hash |
| 每做一個非顯而易見的決定 | `context.md` 決策紀錄 |
| 每踩一個坑 | `context.md` 已知地雷 |
| **壓縮前 / session 結束前** | 三份都掃一遍 |
| 方向改變 | `plan.md` 策略段，**並把舊策略移到「被否決的選項」** |

⚠️ **文件過期比沒有文件更危險** —— 沒有文件你會去讀程式碼，
過期的文件會讓你相信一件已經不成立的事。

## Step 5 — 恢復（`/dev-docs resume`）

```
1. 讀 plan.md → 我們在做什麼、怎麼算完成
2. 讀 context.md → 有哪些既定事實、哪些方向不要再試
3. 讀 tasks.md → 停在哪
4. git log --oneline -10 → 文件說的跟 repo 實際狀態一致嗎？
5. 不一致 → 先修文件，再繼續工作
```

⚠️ 第 4 步不能跳。文件是上一個 session 的**宣稱**，git 是**事實**。

## Step 6 — 收工

任務完成後把目錄移到 `dev/done/<task-name>/`（用 `command mv`），
不要留在 `active/` —— 下次 `ls dev/active/` 時的雜訊就是下次的困惑來源。

---

## 常見的自我開脫

| 你會這樣想 | 事實 |
| --- | --- |
| 「我記得住，不用寫」 | 壓縮之後的你不是現在的你。寫下來的成本是三分鐘。 |
| 「等做完再一次補文件」 | 做完之後決策理由已經蒸發了，補出來的是「改了什麼」不是「為什麼」。 |
| 「文件寫詳細一點比較保險」 | 這份文件的讀者是下一個 session 的你，不是稽核員。長到沒人讀等於沒有。 |
| 「plan 改了，舊的直接覆蓋掉」 | 被否決的方案必須留痕，否則會被重新提議一次。 |
| 「tasks.md 打勾就好」 | 沒有 commit hash 的打勾，下次無法驗證那件事真的做完了。 |

## 紅旗

- `dev/active/` 裡有三個以上的目錄（同時開太多戰場）
- 文件說某任務完成，但 `git log` 裡找不到對應的 commit
- `context.md` 只有檔案清單，沒有決策紀錄與地雷
- 決策紀錄裡寫著「昨天」「上週」這種相對時間
- 任務完成了但目錄還留在 `active/`
- 文件比它描述的改動還長

## 驗收

- [ ] 動手前先確認過 `dev/active/` 沒有既有的同名任務
- [ ] `plan.md` 的完成條件是一句可驗收的敘述，不是願景
- [ ] 「被否決的選項」有內容
- [ ] `context.md` 有決策紀錄與已知地雷，日期是絕對日期
- [ ] `tasks.md` 的每個勾都附了 commit hash 或測試輸出
- [ ] resume 時比對過 `git log`，文件與 repo 狀態一致
- [ ] 任務結束後目錄已移到 `dev/done/`
