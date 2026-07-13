---
name: google-flight
description: Search Google Flights for prices via a single deterministic HTTP GET request — no browser, no GUI/CSS rendering, no screenshots. Use this before reaching for browser automation (kimi-webbridge, browser-harness) whenever the task is "what does this route cost", not "show me the page" or "book this seat".
---

# google-flight

A minimalist alternative to browser automation for one job: get a flight price fast.

Where `kimi-webbridge` / `browser-harness` drive a real page (open a tab, wait for
render, click through an autocomplete dropdown, scroll a virtualized calendar,
screenshot to verify), this skill sends one HTTP GET to Google Flights' search
endpoint and parses the JSON payload embedded in the returned HTML. No browser
process, no CSS/layout, no screenshots — just a request and a parse. That makes
it both **faster** (~1-3s vs 10s+ for a single browser `navigate`) and
**lighter on RAM** (no Chromium tab at all).

## When to use this vs. a browser tool

| Situation | Use |
|---|---|
| "What's a TPE→MAD round trip cost around these dates?" | **this skill** |
| Need the exact paired return-flight time, not just a price | this skill for the price, then a browser tool to pin down the return leg (see Limitations) |
| Need to actually book / fill in passenger details / pay | browser tool — this skill is read-only |
| The route keeps raising `IndexError`/`TypeError` (see below) | browser tool as fallback |

## Usage

```bash
uv run scripts/search_flights.py --from TPE --to MAD --depart 2026-10-22 --return 2026-10-31 --currency TWD
```

`uv run` reads the PEP 723 header at the top of the script and installs its
pinned dependencies (`fast-flights`, `typing_extensions`) into an ephemeral
env on first run — nothing to `pip install` by hand, nothing to leave
installed afterward. Battery included.

Key flags:

- `--from` / `--to` — IATA airport codes (e.g. `TPE`, `MAD`), validated as
  3 letters and case-normalized; must differ from each other
- `--depart YYYY-MM-DD` — required, strictly validated (see Lessons #6)
- `--return YYYY-MM-DD` — omit for one-way; must not be before `--depart`
- `--adults` — 1-9 (Google Flights' own UI cap), default 1
- `--currency` — e.g. `TWD`, `USD` (blank lets Google pick); validated
  against the ~70 codes fast-flights actually supports
- `--max-stops N` — filters client-side (the library's own server-side stop
  filter crashes the parser on some routes, see below — don't pass it
  upstream); must be >= 0
- `--depart-window "HH:MM-HH:MM"` / `--arrive-window "HH:MM-HH:MM"` — filter
  the outbound leg's clock-time departure/arrival, e.g. `--arrive-window
  "12:00-18:00"` for "must land in the afternoon". Supports windows that
  cross midnight, e.g. `"22:00-04:00"` for red-eyes.
- `--format json|table` — `json` for another agent/script to consume,
  `table` for a human to read
- `--limit N` — cap results (sorted by price ascending), must be >= 1

On success it exits 0 and prints results. On failure (bad input, no results,
or the upstream parser choking) it prints a JSON `{"error": ...}` to
stdout/stderr and exits non-zero — check the exit code, don't just check
stdout is non-empty.

## Lessons this distills (from manually driving Google Flights in a real browser first)

1. **Long-haul date math is a trap.** A 19-hour TPE→MAD flight departing
   Taipei at 00:30 can land in Madrid the *same calendar day* — Taipei is far
   enough ahead of Madrid that the timezone gain outpaces the flight time. If
   you want "arrives afternoon on date X", don't assume you need to search
   `--depart` one day earlier; search `--depart` on X itself first and check
   the actual `arrive` field the script prints. Verify, don't guess.
2. **Round-trip here means "outbound options + total price", not two paired
   legs.** Google Flights' own UI is two-step: pick an outbound flight, *then*
   it shows you return options for that specific fare. This script's
   `--return` flag reproduces step one only — you get a real round-trip total
   price, but the itinerary printed is the outbound leg; the specific return
   flight isn't resolved. If you need the actual return time pinned down,
   treat this script's price as a first-pass estimate and confirm the return
   leg with a browser tool.
3. **The reverse-engineered parser is fragile, in two different ways —
   and one of them was fixable.** It decodes an undocumented, unstable `tfs`
   protobuf param and parses embedded JSON that Google can reshape at any
   time.
   - *Whole-query failure, root-caused and patched*: a sweep of ~20 routes
     found `fast_flights.parser.parse_js` does `price = k[1][0][1]` for
     every raw itinerary entry with no bounds check — one entry missing
     price data (common on TPE→LHR, TPE→BNE, TPE→JNB, and intermittently
     others) crashed the parse for the *entire* result set, discarding every
     other good entry along with it. That was a fixable bug in a 15-line
     loop, not an inherent fragility, so this script monkey-patches
     `parse_js` at import time (see `patch_resilient_parser()`) to skip only
     the bad entry and keep the rest. Pass rate on the swept routes went
     from 33/40 to 40/40 after the patch. If a future `fast-flights` release
     changes the parser's internal shape, the patch fails closed (falls back
     to stock behavior with a stderr note) rather than breaking the script.
   - *Per-result failure*: even with the patch, one specific result can
     still have its leg date/time left as `None` by Google's payload — seen
     on TPE→SYD. This isn't a parse crash, it blows up later while
     formatting that one result. The script catches this per-row
     (`IncompleteLegData`), drops just that malformed result, and reports
     how many were dropped — a route returning 5 good results and skipping
     1 bad one is normal, not a sign something's broken.
   A caught error now means "this specific route/date is still unresolvable
   after the patch," not "the library is generally unreliable" — treat it as
   fall back to a browser tool for that one query.
4. **Don't trust server-side `max_stops`.** Passing it into the upstream
   query crashes the parser outright on some routes (empirical finding, not
   documented upstream). This script filters stops client-side instead —
   always fetch unfiltered, then narrow down in Python.
5. **Results aren't identical to what you'd see logged into Chrome.**
   Google Flights personalizes by session/cookies/locale/IP. A price and
   itinerary set fetched this way is a fast, real, but *independent* sample —
   don't be surprised if a browser session run seconds later shows a
   different cheapest option. For anything price-sensitive, sample both and
   take the lower bound as your target, not either single number as gospel.
6. **A malformed `--depart`/`--return` fails silently, not loudly — validate
   it yourself.** Passing `15-09-2026` (an unambiguous non-ISO string) to
   `fast_flights.FlightQuery` didn't raise; it silently resolved to
   `2026-09-09` and returned real, plausible-looking results for the *wrong
   date*, with nothing in the output signaling anything was off. This is far
   more dangerous than a crash — a crash gets noticed. This script now
   validates `--depart`/`--return` as strict `YYYY-MM-DD` and `--from`/`--to`
   as 3-letter codes *before* calling into the library, specifically because
   the library won't catch this class of error for you.
7. **A wide fuzz/stress pass caught more of the same pattern — silent
   nonsense accepted, or a clean crash for a case that should be a one-line
   input error.** Swept ~90 more combinations: 24 non-TPE routes spanning
   every continent (round-trip, `avg ~1.6s`), plus deliberately bad input.
   Findings, now all fixed with upfront validation instead of relying on the
   library:
   - `--adults 0` silently returned real results for a booking with nobody
     on it; `--adults -1` and `--adults 50` both raised an uncaught
     exception deep inside the library instead of a clean error. Now
     rejected upfront: must be 1-9 (Google's own UI cap).
   - `--depart-window`/`--arrive-window` with no `-`, an out-of-range hour
     (`25:00-26:00`), or plain garbage all raised an unhandled
     `ValueError`/traceback from inside `parse_window`. Now caught and
     reported as a clean input error.
   - A window that crosses midnight (`22:00-04:00`, for red-eyes) used to
     silently match nothing, because `in_window` only checked
     `start <= t <= end` — impossible when `start > end`. Fixed: `in_window`
     now special-cases `start > end` as a wraparound window.
   - `--return` dated before `--depart` was silently accepted and searched
     anyway. Now rejected with a clear ordering error.
   - A `--currency` value fast-flights doesn't recognize (e.g. a typo like
     `XXX`) was silently echoed back as the result's currency label even
     though Google may have priced in something else entirely — a
     mislabeled-price risk, not just a cosmetic one. Now validated against
     the ~70 currency codes the library actually supports.
   - Negative/zero `--limit` and negative `--max-stops` produced confusing
     but "successful" output (e.g. `--limit -1` silently returned all-but-
     the-last row via Python slice semantics) instead of telling you the
     input didn't make sense. Now rejected upfront.
   - Three determinism runs of the identical query back-to-back returned
     identical prices — the "deterministic" claim holds for same-session,
     back-to-back calls; it's cross-session/day drift (point 5) that varies.

## Files

- `scripts/search_flights.py` — the whole skill. Self-contained (PEP 723
  inline deps), runs via `uv run`.
