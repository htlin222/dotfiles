# The architecture page — taught through *Head First Software Architecture*

The `Head-First-Software-Architecture.md` page explains the repo's architecture using the
framework from *Head First Software Architecture* (Raju Gandhi, Mark Richards, Neal Ford;
O'Reilly, 2024). Goal: **teaching-first** — a reader who has never opened the book should
finish the page understanding both the ideas AND why this repo is shaped the way it is.

Contents:
- [The rule that makes this page good](#the-rule)
- [The framework: 4 dimensions + 2 laws](#the-framework)
- [The page template](#the-page-template)
- [How to find the answers in a real repo](#finding-the-answers)

## The rule

For **every** concept: first explain it in plain language (2-4 sentences, assume the reader
never read the book), THEN map it to a concrete detail of *this* repo — a real component,
file path, or decision. Never a generic book summary. Every concept must land on something
specific. If it doesn't, cut it.

## The framework

Memorable skeleton: **four dimensions + two laws.**

**Architecture vs Design** (frame first): architecture decisions are hard to change and
global; design decisions are easy to change and local. The test: *"how much does it hurt
to change this?"* — the more it hurts, the more it's architecture. Give one example of each
from the repo, then say this page is about the first kind.

**The four dimensions** (the book splits "architecture" into four separable things):
1. **Architectural characteristics** — the `-ilities` (availability, maintainability,
   security, scalability, ...). Key move: you cannot maximize all of them; name the
   **2-3 that truly drive this system**, and name the ones you **deliberately do NOT
   pursue** (that's where you allow yourself to be ordinary). Present as a table:
   characteristic -> plain meaning -> concrete manifestation in this repo.
2. **Logical components** — how responsibility is carved up. Judge with **cohesion** (does
   a component's insides truly belong together?) and **coupling** (how tightly are
   components bound?). Map the repo's real components and argue why the boundaries sit
   where they do. High cohesion = a component you could lift out and reuse.
3. **Architectural style** — the overall shape. Briefly give the taxonomy: **monolithic**
   (layered, modular monolith, microkernel/plugin, pipeline) vs **distributed**
   (event-driven, microservices, service-based, space-based). Name this repo's style, and
   argue it was **forced by the driving characteristics**, not chosen for taste.
4. **Architectural decisions** — record important ones as **ADRs**: *Context -> Decision ->
   Consequences* (list a **+** and a **-** for each). Give 2-3 real ADRs from the repo.

**The two laws:**
- **First law: "Everything in software architecture is a trade-off."** If you can't see the
  cost of a decision, you haven't found it yet. Present a **"what we bought / what we paid"**
  table for the repo's core decisions.
- **Second law: "Why is more important than how."** In six months the code shows the *how*;
  what's lost is the *why*. Point to where the why lives in this repo (ADRs, this page,
  the Tech-Debt entries).

## The page template

Adapt headings to the wiki's language (zh-TW example headings in parentheses):

```
# Reading <repo> through Head First Software Architecture
   (# 用《Head First Software Architecture》看 <repo>)

<1-paragraph intro: what the book is; the promise "even without reading it you'll see why
this repo looks the way it does"; the skeleton = 4 dimensions + 2 laws>

## Architecture vs Design   (## 架構 vs 設計)
<the "how much does it hurt to change?" test + one architecture-level + one design-level
example from this repo>

## The Four Dimensions   (## 四個維度)
### 1. Architectural characteristics   (### 架構特性)
<explain; TABLE of 2-3 driving -ilities; note the deliberately-not-pursued ones>
### 2. Logical components   (### 邏輯元件)
<explain cohesion/coupling; map real components + boundary rationale>
### 3. Architectural style   (### 架構風格)
<explain taxonomy; name the style; argue it was forced by the driving characteristics>
   <a mermaid diagram of the style belongs here — see mermaid.md>
### 4. Architectural decisions   (### 架構決策)
<explain ADR = Context/Decision/Consequences; 2-3 real ADRs each with a + and a ->

## The Two Laws   (## 兩條定律)
### First law: everything is a trade-off   (### 第一定律：一切都是取捨)
<explain; "what we bought / what we paid" TABLE>
### Second law: why > how   (### 第二定律：Why 比 How 重要)
<explain; point to where the why lives in this repo>

## The one lesson to take away   (## 帶得走的一課)
<one sentence tying "find the driving characteristics; everything else follows" back to
this repo's shape>

## Further reading   (## 延伸閱讀)
<link the repo's own wiki pages (matching link convention) + the book>
```

Target ~120-180 lines. Use tables the way the rest of the wiki does. Never pad with filler;
density from real specifics beats length.

## Finding the answers

- **Driving characteristics**: look at the README's "why", the constraints (free-tier?
  offline? single-user? bot-detection?), and what the repo spends effort on (tests, retries,
  determinism, auth). The thing it protects hardest is usually characteristic #1.
- **Components & style**: the top-level directory layout and the data-flow diagram are the
  logical components. If it's one deploy unit -> monolithic; multiple processes/services ->
  distributed. A plugin/menu/convention registry -> microkernel. A linear stage flow ->
  pipeline. GitHub issues/releases as the bus -> event-driven.
- **ADRs**: the "design decisions" from Introduction, plus anything in CHANGELOG / commit
  history / a `docs/` folder framed as "we chose X because Y".
- **Trade-offs**: every "we deliberately do NOT..." and every Tech-Debt entry is half of a
  trade-off; write its other half.
