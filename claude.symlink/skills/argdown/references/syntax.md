# Argdown Syntax Reference

Source: https://argdown.org/syntax/. Compact form for authoring `.argdown` files.

## Document structure

- Top-level block elements separated by blank lines.
- Elements nest via increased indentation and relation symbols.

## Statements

```argdown
This is a simple statement.

[Title]: A titled statement.
Statements can span multiple
lines without blank lines between them.

[Title]: Another member of the same equivalence class.

[Title]              // reference (reuses title, no new content)
@[Title]             // mention inside other prose
```

- Statements are non-repeatable string occurrences.
- Titles assign statements to an equivalence class — every `[Title]: …` block contributes to the same logical proposition.
- Inline formatting: `_italic_`, `**bold**`, `[link](url)`, `#tag-name`, `#(tag with spaces)`.
- YAML metadata: `[Title]: text {key: value}` or a multi-line block `[Title] {\n key: value\n}`.

## Arguments

```argdown
<Argument Title>: short description.

<Argument Title>     // reference
@<Argument Title>    // mention
```

- Use angle brackets `<>`.
- Multiple descriptions can share the same argument title; descriptions are NOT an equivalence class.
- Same inline formatting + YAML support as statements.

## Premise-conclusion structures (PCS)

```argdown
<Teleological Proof>

(1) The world appears designed.
(2) Best explanation is intelligent design.
-----
(3) An intelligent designer exists.
(4) Only God could design the world.
-----
(5) God exists.
```

Rules:

- Round-bracketed consecutive numbers starting at `(1)`.
- No blank lines inside a PCS block.
- `-----` separates premises from conclusion. The last statement is the main conclusion; statements before earlier `-----` lines are intermediary conclusions.
- A PCS statement can be a title reference: `(1) [Title]`.

Inference details (optional):

```argdown
(1) Premise one.
(2) Premise two.
--
Modus Ponens, Universal Instantiation
{uses: [1,2], logic: ["deductive"]}
--
(3) Conclusion.
```

PCS statements can carry relations to other elements via indentation underneath:

```argdown
<Argument A>

(1) [Premise 1]
    <- [Contrary statement]
(2) Premise 2.
-----
(3) [Conclusion]
    +> <Other Argument>
```

## Relations

| Symbol | Meaning | Direction |
|---|---|---|
| `+` | support / entailment | asymmetric |
| `-` | attack / contrary | contrary symmetric |
| `><` | contradiction | symmetric |
| `_` | undercut | asymmetric |

Direction prefix: `<` outgoing (default for `-`, `_`), `>` incoming.

```argdown
[Central claim]
    + <Supporting Arg>
    - <Attacking Arg>
    <- [Contradictory statement]
    +> <Forward-pointing support>

<Argument>
    - <Counter-Arg>
        + <Supporting counter>
    _ <Undercutting arg>
```

Nested hierarchies use indentation:

```argdown
s1
    + <a>
        - <b>
            + <c>
        + <d>
    - <e>
```

## Strict vs. loose mode

- **Loose (default):** `+`/`-` between statements = support/attack.
- **Strict:** `+` = entailment, `-` = contrary, `><` = contradiction.
- Toggle via frontmatter (`mode: strict`) or config file.

## Frontmatter & config

```argdown
===
title: Document Title
author: Name
map:
  statementLabelMode: text
  argumentLabelMode: title
===

[First statement after frontmatter]
```

- Delimited by `===` lines (not `---` — that's reserved for PCS inference lines).
- YAML overrides any config file values.

## Headings & sections

```argdown
# Level 1 Heading

<Argument>

## Level 2 Heading #tag {isGroup: true}

[Statement in section]
```

Markdown-style headings become argument-map groups.

## Lists

```argdown
* [Title]: unordered item
* [Title2]: another item

1. [Title]: ordered item
2. [Title2]: next item
```

Distinct from PCS — list markers `*` / `1.`, not `(1)`.

## Comments

```argdown
// single-line
/* multi
   line */
<!-- html-style -->
```

Ignored by the parser; useful for stashing draft text.

## Automatic relation derivation

The parser derives dialectical relations between arguments from PCS logical relations:

- **Support** when a conclusion entails / is equivalent to a premise of another argument, or when explicitly declared.
- **Attack** when a conclusion is contrary / contradictory to a premise, or when explicitly declared.
- **Undercut** when a conclusion undercuts an inference step, or when explicitly declared.

## Complete example

```argdown
===
title: God's Existence
mode: strict
===

# Theistic Arguments

[God]: God exists.

<Ontological Proof>: By definition, God is the most perfect being. Existence is a perfection. Therefore, God must exist.

(1) God is the most perfect being.
(2) Existence is a perfection.
-----
(3) [God]

<Teleological Proof>

(1) The universe exhibits design.
(2) Design requires a designer.
-----
(3) [God]
    <- <Problem of Evil>: Unnecessary suffering exists.

<Problem of Evil>

(1) Omnipotent beings prevent unnecessary suffering.
(2) Omniscient beings know of suffering.
(3) Suffering exists that serves no purpose.
-----
(4) No omnipotent, omniscient being exists.
    -> [God]
```
