# Novelty search and claim scoping

## Why this file exists

Novelty claimed from training data rots - literature moves faster than model weights. Verify every "first to do X" against actual published prior art before committing to a framing.

## The three-ladder keyword search

Always run a three-tier search before drafting the introduction. Spend at most 5 tool calls on this.

1. **Method + domain**: `"<method name>" <disease or data type> <year>`. Example: `"topological data analysis" acute myeloid leukemia 2025`.
2. **Method + outcome**: `"<method name>" <primary outcome metric> prediction`. Example: `"topological data analysis" drug sensitivity prediction`.
3. **Competing methods + same outcome**: `<domain> <outcome> deep learning OR graph OR transformer <year>`. Catches papers that solve the same problem with a different tool.

Use WebSearch for English literature. If bioRxiv or PubMed MCP is available, run an additional pass on each.

## What counts as a real gap

- **Combination gap**: method M exists, outcome O is studied, but no one has applied M to O. Usually defensible. Example: TDA + AML drug response.
- **Scale gap**: prior work used N=30; we use N=500 with external validation. Good when the smaller N prevents firm conclusions.
- **Rigor gap**: prior work did X but without leakage control / stability analysis / clinical baseline. Honest negative of prior-work overclaim counts as novelty at methods journals.
- **Not a gap**: "we used UMAP instead of PCA". Tool substitution without principled justification is reviewer bait.

## Claim-scope statement

Before writing a single section, produce one sentence:

> "No prior work has done **<method>** on **<data>** to predict **<outcome>**; this paper shows that **<concrete finding with effect size>**, and also honestly reports **<scope limitation>**."

If any slot is vague the claim is not ready.

## Common failure modes

- Claiming novelty in method when prior work already exists but used a different name - search method synonyms (e.g. Mapper algorithm, nerve complex, simplicial neighbourhood).
- Confusing "first in dataset X" with "first overall" - be specific about what is first.
- Relying on Google Scholar citation counts, which lag by 6-18 months - always read the 2024-2026 section of a recent review.

## When to pivot the claim

If the literature search surfaces a paper that scoops the primary finding, do not fight it. Options:

1. Reframe as an independent replication at higher N with an open-source pipeline (valid at mid-IF venues).
2. Pivot the primary finding to a different outcome variable that the scoop does not address (the TDA + AML example pivoted from overall-survival prediction, which collapsed under a proper ELN 2022 baseline, to ex-vivo drug response, which ELN does not address).
3. Drop the study only if neither of the above is feasible.
