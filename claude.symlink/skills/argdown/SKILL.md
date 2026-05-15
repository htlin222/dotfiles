---
name: argdown
description: Author and iterate on `.argdown` argument-map files. Use when the user asks to "create an argdown", structure a debate / argument / pro-con map, lint a `.argdown` file, or export an argument map to SVG/DOT/HTML/JSON via the `argdown` CLI. Workflow — draft, then run `argdown` on the file to lint with line/col errors, fix, then `argdown map -f svg` to render.
---

# argdown

Argdown is a Markdown-flavored DSL for argument maps. Source is a `.argdown` text file; the `argdown` CLI parses it, reports syntax errors with location info, and exports to SVG/DOT/HTML/JSON.

## When this skill fires

- User asks to draft, edit, or lint a `.argdown` file
- User wants to structure a debate / pro-con / objection tree / premise-conclusion argument and visualize it
- User explicitly invokes `$argdown` or mentions "argument map", "argdown map", "claim/objection diagram"

## Prerequisite

`argdown` CLI must be on PATH (`/opt/homebrew/bin/argdown` on this machine). Check with `command -v argdown`. If missing: `npm install -g @argdown/cli`. For SVG/PNG export, Graphviz is also needed: `brew install graphviz`.

## Core workflow

1. **Draft** the `.argdown` file. Minimal skeleton:

   ```argdown
   ===
   title: <topic>
   ===

   # <Section>

   [Main claim]: One-sentence thesis.
     + <Supporting Arg>: Why the thesis holds.
     - <Counter Arg>: Why it might not.

   <Supporting Arg>

   (1) Premise.
   (2) Premise.
   -----
   (3) [Main claim]
   ```

2. **Lint** — there is no separate `lint` subcommand. The default invocation parses and logs syntax errors with line/col:

   ```bash
   argdown path/to/file.argdown
   ```

   Or use `scripts/lint.sh <file>` (bundled): adds `--throwExceptions` so exit code is non-zero on parser errors — suitable for an iterate-until-clean loop.

3. **Fix** the reported errors. See "Gotchas" below for common ones.

4. **Render** once clean:

   ```bash
   argdown map path/to/file.argdown ./svg -f svg
   ```

   Or `scripts/render.sh <file> [outdir]` — wraps lint + map and prints the SVG path.

5. **Iterate** if the map looks wrong — adjust statements, relations, or `--rankdir`/label-mode flags.

## Syntax cheat sheet

Full reference in `references/syntax.md` — load it when authoring a construct not covered here.

| Construct | Syntax | Notes |
|---|---|---|
| Statement (titled) | `[Title]: text` | Same title = same equivalence class |
| Argument | `<Title>: description` | Angle brackets, not equivalence-class |
| Premise-conclusion | `(1) premise` then `-----` then `(N) conclusion` | Consecutive numbering, no blank lines inside |
| Support | `+ <Arg>` or `+ [Stmt]` | Indented under parent |
| Attack | `- <Arg>` | |
| Contradiction | `>< <Arg>` | symmetric |
| Undercut | `_ <Arg>` | targets an inference |
| Direction | `<-` outgoing, `+>` incoming | reverse the arrow |
| Reference | `[Title]` or `<Title>` alone | reuse without redefining |
| Mention | `@[Title]` / `@<Title>` | inline reference inside prose |
| Section | `# Heading` | groups in the map |
| Frontmatter | `=== ... ===` block | YAML config; `mode: strict` toggles strict relations |
| Inference detail | `--\nModus Ponens\n{uses: [1,2]}\n--` | optional between premise list and conclusion |
| Comment | `// line`, `/* block */`, `<!-- html -->` | |

## What the linter catches vs tolerates

Argdown's parser is permissive — it recovers from many surface errors and renders something. `lint.sh` (via `--throwExceptions`) fails reliably only on a narrow set of **hard** parse errors. The rest must be caught by visually checking the rendered SVG.

**Hard errors `lint.sh` will fail on:**

- **Malformed PCS**: missing `-----` inference line, broken inference-detail block (`--` / `--`), parser unable to reduce to a valid `pcs` rule.
- **Unclosed inline formatting** that spans into the next block. Most common offender: an underscore in an identifier (`redact_long.go`, `chat_session_id`) opens an italic span, the parser keeps reading expecting a closing `_`, and chokes when it hits a blank line or unexpected token. Error message names `statementContent > italic` in the rule stack.

**Silent / tolerated (renders despite looking broken):**

- Mismatched brackets like `[Claim>` — lexed as best-effort text.
- Non-consecutive PCS numbering (`(1)`, `(3)`, `(5)`) — argdown re-numbers internally.
- Pure gibberish lines — parsed as statements.
- `@[Title]` mentions to titles that were never defined — warning at most.
- Relation symbols at the wrong indent — silently re-interpreted as top-level.

Implication: after the lint passes, **always render and skim the SVG** before declaring the file correct.

### Inline-formatting footguns

The body of a statement or argument description is parsed for markdown-style inline formatting before the rest of the rules apply. That means:

| Trigger | Effect | Mitigation |
|---|---|---|
| `_word_` | italic span | Avoid bare underscores in identifiers — use `-` or wrap in backticks. |
| `*word*` | italic span | Same as above for asterisks. |
| `**word**` | bold span | Don't paste markdown bold into descriptions unless balanced. |
| `[Anything]` mid-prose | parsed as a statement reference | Rephrase or use a different bracket style. |
| `<word>` mid-prose | parsed as an argument reference | Same. |

When in doubt, write descriptions as plain prose and put code-like tokens in `` `backticks` `` — argdown treats them as inline code and leaves them alone.

## Citing sources with YAML metadata

Any statement definition or reference can carry YAML metadata. Use this to attach a citation to a claim so the rendered map can hyperlink or label by source.

**Recommended schema** for a citation, fields in priority order:

| Field | Required when | Notes |
|---|---|---|
| `source` | always | DOI preferred — bare `10.xxxx/yyyy` or `https://doi.org/...`. Fall back to a stable URL. |
| `author` | recommended | Surname et al. is fine for multi-author. |
| `date` | recommended | `YYYY` or `YYYY-MM` or `YYYY-MM-DD`. |
| `title` | recommended | Short title is enough; full title in the YAML keeps the diagram label clean. |

**Inline form** — use when the metadata fits on one line:

```argdown
[Climate trend]: Global mean surface temperature rose 1.2 °C since 1850. {source: 10.1126/science.abc1234, author: Smith et al., date: 2023, title: HadCRUT5 reanalysis}
```

**Block form** — opening `{` followed by a newline activates YAML block mode; the brackets are ignored and the body between them is parsed as YAML:

```argdown
[Climate trend]: Global mean surface temperature rose 1.2 °C since 1850.
{
  source: 10.1126/science.abc1234
  author: Smith et al.
  date: 2023-04
  title: A reanalysis of HadCRUT5
}
```

For URL sources, quote the value so the colons don't confuse the YAML parser:

```argdown
[IPCC AR6]: Anthropogenic warming is the dominant cause of observed warming since 1850.
{
  source: "https://www.ipcc.ch/report/ar6/wg1/"
  author: IPCC
  date: 2021
  title: AR6 Working Group I Summary
}
```

Same metadata schema works for `<Argument>` definitions — drop the YAML block right after the argument title or description.

## Useful CLI flags

- `argdown -v <file>` — verbose; shows the full AST.
- `argdown map -f svg <in> <outdir>` — SVG via Graphviz.
- `argdown map -f dot <in> <outdir>` — DOT only (no Graphviz needed).
- `argdown map --argument-labels title --statement-labels text` — compact arg labels, full statement text.
- `argdown map --rankdir LR` — left-to-right layout.
- `argdown html <in> <outdir>` — standalone HTML with interactive map web-component.
- `argdown json <in> <outdir>` — full parsed model as JSON for downstream tooling.
- `argdown --watch` — re-run on file change.

## Bundled scripts

- `scripts/lint.sh <file>` — fail-fast lint (exit 1 on parser error). Use this in the iterate loop.
- `scripts/render.sh <file> [outdir]` — lint then render to SVG; prints output path.

Both scripts assume `argdown` is on PATH.

## Reference

- `references/syntax.md` — full Argdown syntax reference from argdown.org. Load when authoring a construct not covered above.
