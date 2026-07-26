---
name: post-to-fb
description: Publishes a text post to the user's Facebook profile via ego-browser, handling the composer dialog, Markdown-to-plaintext conversion, the two-step "繼續 → 發佈" publish flow, and post-publish verification. Use when the user asks to post/publish something to Facebook, share to FB, or "發一篇到 FB".
---

# Post to Facebook (via ego-browser)

Drive the user's already-logged-in Facebook (`林協霆` / profile `https://www.facebook.com/htlin.lizard`) to publish a text post. This skill encodes the exact flow so it runs in **2 heredoc rounds** instead of trial-and-error.

Built on the `ego-browser` skill — all browser calls go through `ego-browser nodejs <<'EOF' ... EOF`. Read that skill's contract if unfamiliar.

## Hard-won lessons (why this skill exists)

1. **FB renders NO Markdown.** Convert before posting: tables → `【標籤】左 / 右` lines, `**bold**` → drop or 「」, bullets → `・`. Keep blank lines between paragraphs (they survive).
2. **The editor is a rich contenteditable**, not a textarea. `fillInput`/`typeText` are unreliable for multi-line. Use CDP `Input.insertText` after focusing — it preserves newlines in one shot.
3. **Publish is TWO steps for the 訂閱者 (followers) audience.** The primary button first reads **「繼續」** (not 發佈) → opens a **「貼文設定」** screen that loads a skeleton for ~2–3 s → then a **「發佈」** button. For other audiences the first button may already be 「發佈」. Handle both.
4. **After 發佈 you briefly see a「發佈中」toast** before the dialog closes. Don't assume failure while it's publishing.
5. **Verify on the profile page**, not the modal — reload the profile URL and check the body text contains the post's opening line.
6. **Publishing is public + irreversible.** Draft into the composer, screenshot, and confirm with the user before clicking publish — unless they explicitly said "post it / don't ask".

## Inputs

- `POST_TEXT` — the final post body. If the user handed messy/Markdown content, first rewrite it to FB-plain-text per lesson #1.
- `PROFILE_URL` — default `https://www.facebook.com/htlin.lizard` (used only for verification).

## Round 1 — open, compose, draft, screenshot

```bash
ego-browser nodejs <<'EOF'
const task = await useOrCreateTaskSpace('facebook post')
cliLog('task id: ' + task.id)

await openOrReuseTab('https://www.facebook.com/', { wait: true, timeout: 40 })
await waitForLoad(); await wait(2)

// Login guard: if not logged in, hand off instead of guessing.
const loggedIn = await js(String.raw`/在想些什麼|What's on your mind/.test(document.body.innerText||'')`)
if (!loggedIn) { cliLog('NOT LOGGED IN — hand off to user'); return }

// Open the composer dialog (button whose text contains 在想些什麼).
await click('xpath=//*[@role="button"][contains(normalize-space(.),"在想些什麼")]', { label: 'open composer' })
await wait(2)

const hasEditable = await js(String.raw`!!document.querySelector('[role="dialog"] [contenteditable="true"]')`)
cliLog('composer open: ' + hasEditable)

const POST_TEXT = `<<<PUT FB-PLAINTEXT POST BODY HERE>>>`

await js(String.raw`(() => {
  const ed = document.querySelector('[role="dialog"] [contenteditable="true"]'); ed.focus(); return true
})()`)
await wait(0.3)
await cdp('Input.insertText', { text: POST_TEXT })   // preserves newlines
await wait(1)

const preview = await js(String.raw`document.querySelector('[role="dialog"] [contenteditable="true"]').innerText.slice(0,200)`)
cliLog('draft starts: ' + preview)

const shot = await captureScreenshot()
cliLog('screenshot: ' + (shot?.path || JSON.stringify(shot)))
EOF
```

Then `Read` the screenshot, show the user the draft, and confirm (skip the ask only if they already said "just post it").

## Round 2 — publish and verify

Handles both the one-step (直接「發佈」) and two-step (「繼續」→「貼文設定」→「發佈」) flows.

```bash
ego-browser nodejs <<'EOF'
const task = await useOrCreateTaskSpace('facebook post')  // resume by name, or pass the numeric id

const clickPrimary = async (labels) => {
  for (const t of labels) {
    const ok = await js(String.raw`(() => {
      const d = document.querySelector('[role="dialog"]'); if (!d) return false
      const b = [...d.querySelectorAll('[role="button"],button')].find(x => x.innerText.trim() === ${JSON.stringify(t)})
      return !!b
    })()`)
    if (ok) {
      await click('xpath=//div[@role="dialog"]//*[@role="button"][normalize-space(.)=' + JSON.stringify(t) + ']', { label: 'click ' + t })
      return t
    }
  }
  return null
}

// Step A: first primary button — may be 繼續 (→ settings) or 發佈 (direct).
const first = await clickPrimary(['發佈', '繼續'])
cliLog('clicked: ' + first)
await wait(3)

// Step B: if a 貼文設定 screen appeared, click 發佈 there.
const second = await clickPrimary(['發佈'])
if (second) cliLog('clicked publish on settings screen')
await wait(4)

// Verify on profile.
await gotoAndWait('https://www.facebook.com/htlin.lizard', { timeout: 40, settle: 3 })
await wait(3)
const firstLine = `<<<FIRST ~10 CHARS OF POST_TEXT>>>`
const ok = await js('document.body.innerText.includes(' + JSON.stringify(firstLine) + ')')
cliLog('post visible on profile: ' + ok)
EOF
```

If `post visible` is true, report success (mention the auto-generated link preview card if the post contained a URL). Then close in a dedicated final heredoc:

```bash
ego-browser nodejs <<'EOF'
const r = await completeTaskSpace('facebook post', { keep: false })
cliLog(JSON.stringify(r))
EOF
```

## Notes & fallbacks

- **Reusing the task space across rounds**: prefer the numeric `task.id` printed in Round 1 to avoid name collisions.
- **Composer button not found**: `snapshotText()` and locate the `建立貼文` region; the entry button holds text `林協霆，在想些什麼？`.
- **insertText landed in the wrong field**: re-focus `[role="dialog"] [contenteditable="true"]` specifically (the sidebar has other editables) and retry.
- **Editing after publish**: FB posts are editable in-place — the user can tweak wording without a repost.
- **Images/links**: a bare URL in the text auto-expands into a preview card; no upload step needed. For photos use the `相片／影片` button + `uploadFile` on the file input.
