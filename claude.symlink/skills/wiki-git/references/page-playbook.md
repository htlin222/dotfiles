# Page playbook

The curated wiki is a small, fixed set of pages. Each has a job. Do not invent extra
pages unless the repo genuinely needs one. Contents table:

- [The standard page set](#the-standard-page-set)
- [Home](#home)
- [Introduction (project + features + key decisions)](#introduction)
- [Roadmap](#roadmap)
- [Gotchas / Lessons](#gotchas--lessons)
- [Tech Debt](#tech-debt)
- [The sidebar](#the-sidebar)

## The standard page set

| Page (file)                         | Job                                                              |
| ----------------------------------- | --------------------------------------------------------------- |
| `Home.md`                           | One-screen answer to "what is this and where do I go?"          |
| `Introduction.md`                   | Purpose, the features, the key design decisions                 |
| `Roadmap.md`                        | Where it's going: short / mid / long term, and preserved paths  |
| `Gotchas.md` (or `Lessons.md`)      | Hard-won bugs and traps, so the next person doesn't re-hit them  |
| `Tech-Debt.md`                      | Known debt, each as background -> impact -> repayment            |
| `Head-First-Software-Architecture.md` | The architecture, taught through the book (see architecture-hfsa.md) |
| `_Sidebar.md`                       | Navigation, matching the repo's language                        |

Small repos may fold Introduction into Home, or Gotchas into Tech-Debt. Rich repos may
split topical deep-dives out (one page per subsystem). Judge from the material.

## Home

The landing page. A reader should, within one screen, know what the project is, who it's
for, and which page to open next.

Include, in this order:
1. One-sentence definition (what it is, for whom).
2. A page-navigation table (link every other page with a one-line "what's inside").
3. A tiny quick-start or quick-command block if the repo has an obvious entry point.
4. An at-a-glance architecture diagram (mermaid — see mermaid.md) when a data/component
   flow exists; a picture here earns its place.

## Introduction

The "why and what" page. Sections:
- **Background / motivation** — the problem this solves (2-4 sentences).
- **Core features** — a table (feature -> what it does), grounded in real capabilities.
- **Key design decisions** — the 3-5 choices that shaped the repo, each with its reason.
  This is the seed of the architecture page; keep it short here, go deep there.

## Roadmap

Honest direction, not a wishlist. Group as **短期 / 中期 / 長期** (or Short / Mid / Long).
Also record **preserved upgrade paths** — decisions made now that keep a future door open.
Mark shipped items as done rather than deleting them, so the trajectory stays legible.

## Gotchas / Lessons

The highest-value page for future-you. Each entry: the symptom, the cause, the fix.
Order by how much time it cost. Only real, encountered traps — no generic advice. If the
repo already documents lessons in code comments, commit messages, or a CHANGELOG, mine
those. Cross-link the relevant Tech-Debt entries.

## Tech Debt

Each item in a consistent shape:

> **<name>**
> - 背景 / Background: how it got here
> - 影響 / Impact: what it costs today (and the risk if left)
> - 償還 / Repayment: the concrete step to clear it

Rank by risk x cost. Be candid; this page is where the architecture page's ADR "minuses"
come home to roost — link them to each other.

## The sidebar

`_Sidebar.md` drives navigation. Two rules:
1. **Match the existing convention exactly** when the wiki already has one — bracket style
   (`[[Page]]` vs `[Text](Page)` vs `[[Page|alias]]`), dashes, descriptions, emoji-or-not.
   Read the current `_Sidebar.md` before adding a line.
2. If none exists, create a simple one: a title, then one bullet per page, plus an external
   links block (Repo / site / releases) at the bottom.

Wiki link resolution: `[[Head First Software Architecture]]` resolves to the file
`Head-First-Software-Architecture.md` (spaces <-> hyphens). Markdown links must use the
hyphenated page name: `[text](Head-First-Software-Architecture)`.
