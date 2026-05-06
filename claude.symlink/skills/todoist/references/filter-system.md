# Personal Filter & Label System

The user's deliberate filter design, decided 2026-05-05. Replaces Todoist's
default `Priority 1/2/3/4` filters which are pure abstraction (no time, no
context, no energy lens) and don't drive action.

When the user asks anything about filters, labels, daily review, or "what
should I do now," consult this file first. It is the source of truth for the
intent behind the system.

## Design principles

1. **Anchor + lanes (Hybrid C, A-leaning weekdays).** One command-center
   filter (`🔥 Now`) is the daily glance. A small set of standing
   favorites (`🎤 Talks`, `📨 Inbox`, `📅 Next 14 days`) cover predictable
   batch work. Everything else is review-only.
2. **Reality over abstraction.** Pure priority is dead — a P1 in 8 weeks is
   less urgent than a P3 due tomorrow. Filters combine **time + context +
   energy**, not just priority.
3. **GTD context lanes** for batchable work (`@mail`, `@speak`,
   `@kfsyscc`/`@irb`).
4. **Atomic Habits**: make it obvious — `🔥 Now` surfaces only what reality
   demands today. No wall, no decision tax.
5. **Cal Newport deep/shallow split**: `@deep` ≥45 min focus vs everything
   else.
6. **Un-stick decisions**: `@decide` lane prevents "考慮申請 X" /
   "評估 Y" from rotting for weeks.

## The 8 designed filters (5 live + 3 label-click fallbacks)

Filters are managed via the Sync API at `POST /api/v1/sync` with
`commands=[{"type":"filter_add",...}]` (NOT the deprecated `/sync/v9/sync`,
which now returns 410). The user is on **Todoist Free, cap = 5 filters**,
so the 5 highest-priority designs are saved as filters; the remaining 3
are accessed by clicking the label in the sidebar (free Todoist behavior).

### Live as saved filters (5)

| # | Name | Query | Favorite | Purpose |
|---|---|---|---|---|
| 1 | `🔥 Now` | `(overdue & !@reminder) \| today` | ✓ | Anchor. Strict: overdue (excluding reminders) OR anything due today. Reminders auto-fire on their day via the `today` half. |
| 2 | `🎤 Talks pipeline` | `@speak` | ✓ | Single biggest calendar driver. |
| 3 | `📨 Inbox actions` | `@mail` | ✓ | Daily 30-min email-batch session. |
| 4 | `📅 Next 14 days` | `14 days` | ✓ | Sunday planning horizon. |
| 5 | `🏥 KFSYSCC / IRB` | `@kfsyscc \| @irb` | | On-site / IRB paperwork batch. |

### Label-click fallback (3, no saved filter on Free)

These three views are reached by clicking the label in the Todoist sidebar
under the Labels section — same UX, no filter slot used:

| # | Name | Sidebar click | Purpose |
|---|---|---|---|
| 6 | `🧠 Deep work` | `@deep` | ≥45-min focus blocks (slides, papers, IRB report). |
| 7 | `🤔 Decide / RSVP` | `@decide` | Yes/no items. Un-stick decision rot. |
| 8 | `🪞 Weekly review` | (no equivalent on Free) | Untriaged sweep — needs Pro plan, or do as manual review by paging through tasks with empty label list. |

### Upgrading to Pro
Pro plan raises the filter cap to 150. If the user upgrades, run the
Sync-API `filter_add` for the 3 missing filters (queries: `@deep`,
`@decide`, `no labels`).

### Sort order convention
- `🔥 Now`: by priority desc, then due time asc.
- `🎤 Talks`, `📅 Next 14 days`: by due date asc.
- `📨 Inbox actions`: by due date asc.
- `🤔 Decide`: by added date asc (oldest first — they should be killed off,
  not accumulated).

## Labels

### In active use (decided 2026-05-05)
- **mail** — needs an email action (compose / reply / send attachment)
- **speak** — speaking engagement / talk prep / talk follow-up
- **reminder** — a self-reminder task (T-3 / T-7 prep cue). Should auto-disappear when actioned. Excluded from `🔥 Now` unless its fire date is today.
- **kfsyscc** — Koo Foundation Sun Yat-Sen Cancer Center work
- **irb** — IRB paperwork
- **conf** — conference / 研討會 RSVP
- **hema** — hematology society work (兩會)
- **github** — GitHub repo work
- **infra** — infrastructure / hosting / DNS
- **calendar** — needs to be on the calendar
- **ash** — ASH-related (the conference, not the framework)
- **reply** — explicit reply expected; subset of `mail`
- **deep** *(new)* — ≥45-min uninterrupted focus block. Tag at task entry when the work is real cognitive lift (writing, slides, figures, code).
- **decide** *(new)* — needs a yes/no decision, not execution. Anything starting with "考慮", "評估", "決定是否".

### Considered and rejected
- **`@quick`** — rejected. Most of the user's tasks are already in clear lanes (mail, speak, admin); the friction of judging "is this <2 min?" at entry doesn't pay off.
- **`@waiting`** — rejected. The user doesn't currently track blocked-on-others items. Add later only if the workflow demands it.

## Behavioral notes

- **`@reminder` exclusion in `🔥 Now`.** The query
  `!(@reminder & !today)` means: hide reminders unless their fire date is
  today. T-3 reminders thus sleep until they fire, then surface exactly
  once.
- **`🤔 Decide` is a daily 5-min sweep.** Open it on commute / coffee;
  either pull the trigger (RSVP yes/no) or downgrade the task. Decisions
  rot when they're invisible.
- **`📅 Next 14 days` is the Sunday-review view.** `📅 This week` was
  considered but rejected as too narrow — most of the user's hard
  deadlines fall 1–4 weeks out.

## When the system breaks

- **`🔥 Now` is empty for >2 days running** — either you're caught up
  (rare), or tasks aren't being entered with due dates. Check the Inbox.
- **`🪞 Weekly review` has >3 items** — labeling discipline is slipping at
  task-entry time. Add the right label or downgrade to "someday/maybe".
- **`🤔 Decide` has the same item for >2 weeks** — it's not a decision,
  it's a fear. Either commit (RSVP yes), kill (RSVP no), or move to a
  separate "考慮中" project.
- **`📨 Inbox actions` exceeds ~10** — schedule a 30-min email-batch
  block; don't drip-feed.

## How to apply when the user asks for help

1. **"What should I do now?"** → Read `🔥 Now` filter content via `tasks list --filter "(overdue | today) & !(@reminder & !today)"`. Surface the top 3.
2. **"Help me plan the week"** → Read `📅 Next 14 days`, group by week, flag `@deep` tasks for calendar blocking.
3. **"What am I forgetting?"** → Read `🪞 Weekly review` (`no labels`) to find untriaged tasks.
4. **"Help me decide"** → Read `🤔 Decide / RSVP`. For each, ask: "What's the cost of YES? What's the cost of NO? What information would change your mind?"
5. **When adding a new task** — apply labels at entry:
   - Email-driven? → `mail` (+ `reply` if explicit reply expected)
   - Talk-related? → `speak`
   - Yes/no decision? → `decide`
   - ≥45-min focus work? → `deep`
   - Self-reminder for a future task? → `reminder` + a real due date
