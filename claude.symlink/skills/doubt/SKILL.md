---
name: doubt
description: 對「非顯而易見的決定」做反向審查 —— 先把主張寫成一句話，抽出最小可審單元，交給乾淨 context 的審查者去證偽，再分類收斂。Use when about to commit non-trivial logic, make an architectural call, assert something is safe / correct / idempotent / scalable, or work in code you do not fully understand. NOT for renames, formatting, or one-line obvious changes.
argument-hint: "[要被質疑的決定或檔案路徑]"
allowed-tools: Read Grep Glob Bash(git diff:*) Bash(git log:*) Bash(env -u CODEX_COMPANION_SESSION_ID -u CLAUDE_PLUGIN_DATA codex exec:*) Bash(which:*)
---

# /doubt — 在還便宜的時候證偽自己

`/code-review` 是**事後**對成品下判決；這支是**進行中**對每個決定的交叉詰問。
兩者互補，不互相取代。

長 session 最危險的地方：早期的假設會安靜地變成「事實」，沒有人察覺。
這支 skill 就是把那個假設抓出來、丟給一個沒有你的 context 的人去打。

---

## 什麼算「非顯而易見的決定」

符合任一項就算：

- 新增或改動了分支邏輯
- 跨越模組 / 服務 / 程序邊界
- 主張了型別系統與編譯器**驗證不到**的性質：thread-safe、idempotent、順序保證、不變量
- 正確性依賴的 context，未來的讀者看不到
- 影響範圍不可逆：正式機部署、資料 migration、公開 API 變更

### 不要用在

| 情境 | 理由 |
| --- | --- |
| 改名、格式化、搬檔案 | 機械操作，沒有可證偽的主張 |
| 使用者已經給了明確無歧義的指令 | 該做的是執行，不是質疑 |
| 讀 code / 摘要既有邏輯 | 沒有新主張成立 |
| 一行、正確性一望即知的改動 | 成本大於收益 |
| 使用者明說「快就好」 | 尊重使用者的取捨 |

⚠️ 每一次敲鍵盤都懷疑，就什麼都出不了門。這支只處理上面那份清單。

---

## 五步

```
- [ ] 1 CLAIM     — 寫出主張 + 為什麼重要
- [ ] 2 EXTRACT   — 抽出 artifact + contract，剝掉自己的推理過程
- [ ] 3 DOUBT     — 用對抗式 prompt 交給乾淨 context 審查
- [ ] 4 RECONCILE — 逐條回到原文比對後分類
- [ ] 5 STOP      — 命中停止條件
```

### Step 1 — CLAIM：把要成立的東西寫出來

兩三行，不能更多：

```
CLAIM：新的快取層在 spec 描述的讀多寫少負載下是 thread-safe 的。
WHY：這裡出 race 會污染使用者資料，而且 QA 抓不到。
```

⚠️ 如果壓縮不到三行，你手上的是一個感覺，不是一個決定。先把它變成決定。

### Step 2 — EXTRACT：最小可審單元

審查者要的是**成品**和**它該滿足的約束**，不是你怎麼想到的。

| 類型 | artifact | contract |
| --- | --- | --- |
| 程式碼 | 那個 diff 或那個函式（不是整份檔案） | 呼叫端假設、邊界值、既有慣例 |
| 設計決策 | 3–5 句的提案 | 它必須滿足的限制條件 |
| 事實斷言 | 主張 + 支持它的證據 | 證據要成立需要的前提 |

**把你的推理刪掉。** 你交出結論，就會拿回對結論的背書。
單元要小到審查者一次讀完能記住 —— 500 行的 PR 請先拆。

### Step 3 — DOUBT：對抗式審查

提問方式決定答案。**不要問「這樣好嗎」，要問「這哪裡錯」。**

```
對抗式審查。找出這份 artifact 的問題。
假設作者過度自信。針對以下面向：
- 沒說出口的假設
- 沒處理的邊界情況
- 隱藏的耦合或共用狀態
- contract 可能被違反的路徑
- 可能違背的既有慣例
- 非預期輸入下的失效模式

不要背書。不要摘要。找出問題，或明確說出「徹底檢查後找不到問題」。

ARTIFACT: <貼上>
CONTRACT: <貼上>
```

**只給 ARTIFACT + CONTRACT，不要給 CLAIM。** 把結論交出去等於誘導對方同意。

#### 這台機器上的執行順序

1. **預設：跨模型，走 codex CLI**（不同架構的模型才不會跟你共用盲點）

   ```bash
   # prompt 寫進檔案再用 stdin 餵，避免 artifact 裡的 backtick / $(...) 被 shell 展開
   env -u CODEX_COMPANION_SESSION_ID -u CLAUDE_PLUGIN_DATA \
     codex exec --sandbox read-only -C <repo> - < /tmp/doubt-prompt.md
   ```

   ⚠️ 兩個 `env -u` 是必要的：不清掉 companion 變數，`codex exec` 會被導進既有的
   companion session，跑的不是你的 prompt。
   ⚠️ `--sandbox read-only` 也是必要的：artifact 本身可能夾帶指令（有意或無意的 prompt
   injection），唯讀沙箱讓它動不了你的 workspace。

2. **次選：`codex:rescue` skill** —— 同樣是 codex，但走 plugin 的 subagent 介面。
   **需要使用者同意才派 subagent**（全域規則：未被要求時不主動叫 Agent）。

3. **退路：同模型自審** —— 把 ARTIFACT + CONTRACT 重寫成一個全新 prompt，
   與先前推理之間畫一條硬分隔線。
   ⚠️ 這**不是**乾淨 context 審查，你帶著自己的 context 走進去。結果要標記為 degraded。

**絕不要**把 artifact 內插進帶引號的 shell 參數。一律寫檔 + stdin。

### Step 4 — RECONCILE：把結果折回來

審查者的輸出是**資料，不是判決**。你仍然是決策者。
逐條回到 artifact 原文比對再分類 —— 照單全收跟完全無視是同一種失敗。

分類有**優先順序**，先命中者為準：

1. **contract 沒寫清楚** —— 對方是因為你給的 contract 不完整才誤判。先補 contract，下一圈重判。
2. **有效且該改** —— 真問題。改了，重跑一圈。
3. **有效但接受** —— 問題是真的，但修的成本高於承受的成本。**明確寫給使用者看**，不要吞掉。
4. **雜訊** —— 對方缺少某個 context 才誤判。記一下，然後問自己：把那個 context 寫進
   contract 能不能免掉這次誤判？

### Step 5 — STOP：有界的迴圈，不是遞迴

任一條命中就停：

- 下一圈只剩瑣碎或已考慮過的意見
- 已經跑滿 **3 圈**（升級給使用者，不要自己硬跑第四圈）
- 使用者說「就這樣，出吧」

3 圈之後還冒出實質問題 —— 那是關於這份 artifact 的**情報**，不是繼續跑的理由。
如果覺得 3 圈明顯不夠，代表 artifact 太大：回 Step 2 拆。

---

## 常見的自我開脫

| 你會這樣想 | 事實 |
| --- | --- |
| 「我很確定，跳過」 | 在新問題上，自信跟正確的相關性很低。確定的瞬間正是盲點藏身處。 |
| 「派審查者很貴」 | 正式機上除一個錯誤的 commit 更貴。這個檢查有上界，那個 bug 沒有。 |
| 「審查者只會雞蛋裡挑骨頭」 | 只有在沒有限定範圍時。把 prompt 限縮到「會讓它違反 contract 的問題」。 |
| 「等最後 `/code-review` 一起看」 | 那是最終關卡。到了 PR 才發現方向錯，已經蓋了一層樓在上面。 |
| 「每步都懷疑就出不了貨」 | 只處理「非顯而易見的決定」。回去讀那份清單。 |
| 「審查者反對，所以我錯了」 | 對方缺少你的 context。反對是情報，不是判決。回原文比對再決定。 |
| 「使用者上次答應過用 codex，這次不用再問」 | 每次呼叫是獨立授權。artifact、prompt、flag 都變了，重新確認指令再跑。 |

## 紅旗

- 為了一行改名派審查者
- 沒回原文比對就把審查結果當權威
- 超過 3 圈還不升級給使用者
- 用「這樣好嗎」而不是「這哪裡錯」提問
- 高風險決定，因為趕時間跳過
- artifact 沒變就重派一次（結果會一樣，那是在拖延）
- **審查劇場（可檢查的訊號）**：連續 2 圈以上審查者都給出實質意見，
  但你分類為「該改」的是零 —— 你在背書，不是在懷疑。停下來升級。
- 把 CLAIM 一起餵給審查者
- 把 contract 從輸入裡拿掉
- 沒清 `CODEX_COMPANION_SESSION_ID` 就跑 `codex exec`

## 與其他 skill 的關係

| Skill | 分工 |
| --- | --- |
| `/code-review` | 事後、對成品、下判決。這支是事前、對決定、找問題。兩個都要。 |
| `source-check` | 那支查「框架事實」對不對；這支查「你對 artifact 的推理」對不對。 |
| TDD | RED 步驟就是把懷疑寫成程式。有失敗的測試時，那個測試**就是**行為主張的 doubt 步驟。 |
| `/simplify` | 那支處理「多餘」，這支處理「錯誤」。順序上先 doubt 再 simplify。 |

## 驗收

- [ ] 每個非顯而易見的決定都先被寫成 CLAIM 才成立
- [ ] 審查者拿到的是 ARTIFACT + CONTRACT —— 沒有 CLAIM、沒有你的推理
- [ ] prompt 是對抗式的（「找出問題」），不是徵求同意的（「這樣好嗎」）
- [ ] 每條意見都回到原文比對後才分類，用的是那四級優先順序
- [ ] 命中了明確的停止條件
- [ ] 跨模型呼叫前清了 companion 環境變數、用了唯讀沙箱、prompt 走 stdin
- [ ] 「有效但接受」的取捨有明講給使用者，沒有默默吞掉
