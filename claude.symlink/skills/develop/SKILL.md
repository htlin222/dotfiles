---
name: develop
description: 依 ticket/issue 產出初版實作 — 解析需求、從最新 develop 切出符合命名規範的分支、寫出實作、跑既有測試與 lint、conventional commit，然後交棒給 /simplify。Use when the user types /develop, or asks to start implementing a ticket, issue, or feature request end-to-end from requirement to first commit.
argument-hint: "[issue 編號 | 需求描述]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(git status:*) Bash(git branch:*) Bash(git log:*) Bash(git diff:*) Bash(gh issue view:*)
---

# /develop — Dev Flow 的第一棒

`Ticket → **分支 → 實作 → commit** → /simplify → /code-review → PR`

這支 skill 只負責粗體那三段。**不 push、不開 PR、不 merge。**

---

## 檢查清單

開工時用 TaskCreate 建下列項目，逐項推進：

1. 解析 ticket，寫出一句可驗收的完成條件
2. 同步基底分支並切出新分支
3. 讀既有程式碼，決定改動範圍
4. 實作 + 跑既有 lint/test
5. Conventional commit（不 push）
6. 交棒給 `/simplify`

---

## Step 1 — 解析 ticket

`$ARGUMENTS` 是純數字 → 當作 issue 編號：

```bash
gh issue view $ARGUMENTS --json number,title,body,labels,url
```

否則當作需求描述文字。

**沒有 ticket 時**：不要停下來，但要提醒一句「這次沒有票，之後追不回改動原因」，並提議
`gh issue create`。使用者說不用就繼續。

**產出物**：一句可驗收的完成條件，格式為「當 ___ 時，___ 應該 ___」。

⚠️ 如果寫不出這句話，代表需求還沒被想清楚 —— 這時候回頭問使用者，
不要靠猜測開始寫程式。

## Step 2 — 同步基底並切分支

```bash
git status --porcelain          # 必須乾淨；有未提交變更先問使用者怎麼處理
git rev-parse --verify origin/develop   # 判斷基底分支
```

基底分支：有 `develop` 就用 `develop`，否則退回 default branch，並告知使用者
「此 repo 無 develop，改以 <branch> 為基底」。

```bash
git pull origin <base>
git checkout -b <type>/<scope>-<action>
```

**命名規範**（見全域 CLAUDE.md）：

| 前綴 | 用途 |
| --- | --- |
| `feat/` | 加新能力 |
| `fix/` | 修既有問題 |

`<scope>-<action>` 用 kebab-case，總長 ≤4 個詞：`feat/admin-analyze`、`fix/connectors-error`。
只用這兩個前綴，讓 git log 能一眼分出「修補 vs 擴張」。

## Step 3 — 決定改動範圍

先讀再寫。用 Grep/Glob 找出：

- 這個需求該落在哪個既有模組
- 有沒有已存在、可直接沿用的函式或元件（優先重用，不要新造）
- 專案的既有慣例：命名、錯誤處理、測試放哪、用什麼框架

**分流**：

- 單檔、邏輯直觀 → 直接做
- 跨多檔、或有多種合理設計 → 先列 3–6 步的計畫給使用者確認再動手

## Step 4 — 實作

- **貼合既有風格**：註解密度、命名、慣用寫法都比照周圍程式碼，不引入個人偏好
- **一次只解一個問題**：不順手改風格、不順手重構無關的東西（那是 `/simplify` 的事）
- **測試**：不強制 TDD。但改動涉及條件分支、邊界值、或修 bug 時要補測試。

  ⚠️ **期望值由規格決定，不是由程式輸出決定。**
  嚴禁先跑一次程式、再把跑出來的結果填成 assert —— 那只是在測「程式做了它做的事」，
  永遠不會失敗。想不出預期值就回 Step 1 釐清規格。

- **跑既有驗證**：找到專案自己的指令（`package.json` scripts、`Makefile`、`pyproject.toml`…）
  並執行 lint + test。有紅燈就修到綠，不要留給下一棒。

## Step 5 — Commit

```bash
git add <明確路徑>        # 不要 git add -A
git commit
```

- Conventional commit：`feat(scope): ...` / `fix(scope): ...`
- 內文寫**為什麼**，不是改了什麼（改了什麼 diff 自己會講）
- 有 issue 就加 `Refs #123`
- 沿用該 repo 既有的 commit trailer 慣例（先看 `git log -3` 確認）
- **只 commit，不 push**

## Step 6 — 交棒

回報使用者：

- 完成條件（Step 1 那句話）
- 分支名 + commit hash
- lint/test 實際結果（貼輸出，不要只說「通過」）
- 刻意沒做的事（例如：未補 E2E、某個邊界暫不處理）
- 下一步：`/simplify` → `/code-review` → 開 PR（base 一律 `develop`）

---

## 不做的事

| 行為 | 為什麼 |
| --- | --- |
| `git push` | 交由使用者決定何時推 |
| 開 PR / merge | `/code-review` 之後才開 PR |
| 直接在 `main`/`develop` 上實作 | 違反全域分支規則 |
| 順手重構無關程式碼 | PR 要單一目的 |
| 宣稱「測試通過」卻沒貼輸出 | 沒證據的完成宣告不算數 |
