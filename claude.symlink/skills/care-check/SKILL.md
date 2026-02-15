---
name: care-check
description: Use when auditing a case report or case series manuscript against the CARE checklist. Triggers on case reports, rare disease presentations, unusual clinical findings, or single-patient studies.
---

# CARE Compliance Checker

Audit case report manuscripts against the CARE (CAse REport) 13-item checklist.

## Workflow

1. Read the full manuscript
2. Confirm the manuscript is a case report or small case series
3. Walk through each item below
4. For each item, assign: **Reported** / **Partial** / **Missing** / **N/A**
5. Quote the relevant manuscript text as evidence
6. Output a compliance summary + actionable fixes

## CARE Checklist (13 Items)

| # | Topic | Section | Requirement |
|---|-------|---------|-------------|
| **1** | Title | Title | The diagnosis or intervention of primary focus followed by the words "case report" |
| **2** | Key words | Title page | 2-5 key words identifying diagnoses or interventions, including "case report" |
| **3a** | Abstract — Introduction | Abstract | What is unique about this case and what does it add to the literature? |
| **3b** | Abstract — Findings | Abstract | Patient's main concerns and important clinical findings |
| **3c** | Abstract — Diagnoses/Interventions | Abstract | Main diagnoses, therapeutic interventions, and outcomes |
| **3d** | Abstract — Conclusion | Abstract | Main "take-away" lessons from this case |
| **4** | Introduction | Introduction | Briefly summarise and cite similar previously published cases; state why this case is unique |
| **5** | Patient information | Case presentation | De-identified demographics, main concerns/symptoms, medical/family/psychosocial history (diet, lifestyle, genetics when possible), relevant past interventions with outcomes |
| **6** | Clinical findings | Case presentation | Relevant physical examination findings and significant clinical findings |
| **7** | Timeline | Case presentation | Important dates and times as a figure, table, or narrative (historical and current episode) |
| **8a** | Diagnostic assessment — Methods | Case presentation | Diagnostic methods (PE, lab, imaging, questionnaires) |
| **8b** | Diagnostic assessment — Challenges | Case presentation | Diagnostic challenges (financial, language/cultural, etc.) |
| **8c** | Diagnostic assessment — Reasoning | Case presentation | Diagnostic reasoning including other diagnoses considered (differential diagnosis) |
| **8d** | Diagnostic assessment — Prognosis | Case presentation | Prognostic characteristics (e.g., staging) where applicable |
| **9a** | Therapeutic intervention — Types | Case presentation | Types of intervention (pharmacologic, surgical, preventive, self-care) |
| **9b** | Therapeutic intervention — Administration | Case presentation | Administration details (dosage, strength, duration) |
| **9c** | Therapeutic intervention — Changes | Case presentation | Changes in interventions with rationale |
| **10a** | Follow-up and outcomes — Assessment | Results | Clinician-assessed and patient-assessed outcomes |
| **10b** | Follow-up and outcomes — Tests | Results | Important follow-up test results (positive or negative) |
| **10c** | Follow-up and outcomes — Adherence | Results | Intervention adherence and tolerability (how assessed) |
| **10d** | Follow-up and outcomes — Adverse events | Results | Adverse and unanticipated events |
| **11a** | Discussion — Strengths/limitations | Discussion | Strengths and limitations in the management of this case |
| **11b** | Discussion — Literature | Discussion | Relevant medical literature with references |
| **11c** | Discussion — Rationale | Discussion | Rationale for conclusions (assessment of possible causes) |
| **11d** | Discussion — Take-away | Discussion | Primary "take-away" lessons (without overgeneralizing), in a single paragraph |
| **12** | Patient perspective | Discussion | Patient shares their perspective or experience (when possible) |
| **13** | Informed consent | Other | Patient provided informed consent |

## Common CARE Gaps

| Frequently Missing | Fix |
|--------------------|-----|
| Item 1 ("case report" in title) | Append ": a case report" to the title |
| Item 7 (Timeline) | Add a timeline figure or table showing key dates |
| Item 8c (Differential diagnosis) | List diagnoses considered and reasoning for final diagnosis |
| Item 10d (Adverse events) | State adverse events explicitly, even if none occurred |
| Item 12 (Patient perspective) | Add a brief patient quote or note that consent for perspective was not obtained |
| Item 13 (Informed consent) | Add a statement about informed consent for publication |

## Tips for Case Reports

- **Timeline figure**: A visual timeline dramatically improves readability and is specifically requested by CARE
- **"Case report" in title**: Reviewers check this first; it's the easiest item to comply with
- **Patient perspective**: Even one sentence from the patient adds value; if not possible, explain why
- **Differential diagnosis**: Don't just state the final diagnosis; show your reasoning process
- **Avoid overgeneralization**: The Discussion should teach lessons from this case without claiming broad applicability

## Output Format

```
CARE Compliance Report
Manuscript: [filename]

Summary: X/13 Reported | Y Partial | Z Missing | W N/A

MISSING ITEMS:
  [Item #] [Topic] — [What's needed]

PARTIAL ITEMS:
  [Item #] [Topic] — [What's present] → [What's missing]

FULLY REPORTED:
  [Item #] [Topic] ✓
```

## Related Skills

- `/manuscript` — Overall manuscript writing and anti-pattern scanning
