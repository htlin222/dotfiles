# Vale Academic Style Guide

A comprehensive Vale style guide for academic writing based on patterns from the Academic Phrasebank.

## Overview

This style guide helps ensure your academic writing follows established conventions and maintains the formal tone expected in scholarly work.

## Rules Included

### 1. **FormalPreciseLanguage.yml**

- Comprehensive language improvement combining formal and precise vocabulary
- Replaces informal expressions: "can't" → "cannot", "really" → "significantly"
- Improves vague terms: "big" → "substantial", "thing" → "aspect"
- Strengthens weak verbs: "says" → "argues", "looks at" → "examines" (based on Brandeis University guidelines)

### 2. **PassiveVoice.yml**

- Encourages passive voice for objectivity in academic writing
- Flags personal pronouns with action verbs (e.g., "I found" → "It was found")

### 3. **HedgingLanguage.yml**

- Recognizes appropriate hedging language (may, might, possibly)
- Essential for avoiding absolute claims in academic writing

### 4. **TransitionPhrases.yml**

- Identifies proper academic transitions
- Categories: Addition, Contrast, Cause/Effect, Examples, Sequence

### 5. **ResearchPhrases.yml**

- Validates standard research terminology
- Covers: Introduction, Methods, Results, Discussion, Limitations

### 6. **ObjectiveLanguage.yml**

- Flags subjective and emotional language
- Warns against personal opinions and overly strong claims

### 7. **Citations.yml**

- Recognizes citation patterns
- Identifies citation-related phrases

### 8. **WordChoice.yml**

- Improves phrasal verbs to single-word alternatives
- Example: "look at" → "examine"

### 10. **TechnicalTerms.yml**

- Ensures consistent use of technical terminology
- Covers statistical and methodology terms

### 11. **Abbreviations.yml**

- Warns about undefined abbreviations
- Suggests defining abbreviations on first use

### Extended Rules Based on Manchester Academic Phrasebank (11 additional)

### 12. **CautionaryLanguage.yml**

- Recognizes appropriate cautionary and hedging language
- Includes tentative verbs, limitation acknowledgments, and distance phrases
- Essential for maintaining academic objectivity

### 13. **CriticalLanguage.yml**

- Identifies constructive critical analysis language
- Covers limitation identification, methodology questioning, and evaluative language
- Helps maintain scholarly discourse standards

### 14. **CompareContrast.yml**

- Recognizes comparison and contrast phrases
- Includes similarity/difference expressions, comparative degrees, and analytical comparisons
- Essential for academic argumentation

### 15. **DefiningTerms.yml**

- Identifies proper definition and clarification phrases
- Covers definition introductions, categorizations, and operational definitions
- Important for establishing clear terminology

### 16. **TrendDescription.yml**

- Recognizes trend and pattern description language
- Includes upward/downward trends, stability indicators, and rate descriptors
- Useful for results and data analysis sections

### 17. **Causality.yml**

- Identifies cause-and-effect relationship language
- Covers direct/indirect causation, causal relationships, and conditional causality
- Essential for explaining research findings

### 18. **IntroducingWork.yml**

- Recognizes appropriate introduction phrases
- Covers importance establishment, research gaps, and objective statements
- Critical for strong academic introductions

### 19. **MethodDescription.yml**

- Identifies proper methodology description language
- Covers study designs, data collection, sampling methods, and analysis procedures
- Essential for methods sections

### 20. **ResultsReporting.yml**

- Recognizes appropriate results presentation language
- Covers statistical reporting, trend presentation, and quantification
- Important for clear results communication

### 21. **DiscussionPhrases.yml**

- Identifies proper discussion section language
- Covers result interpretation, literature comparison, and implications
- Critical for strong discussion sections

### 22. **ConclusionPhrases.yml**

- Recognizes appropriate conclusion language
- Covers summarizing, significance statements, and future directions
- Essential for effective conclusions

### Enhanced Rules Based on Brandeis University Writing Guidelines (7 additional)

### 23. **UnnecessaryWords.yml**

- Removes redundant phrases: "in order to" → "to", "due to the fact that" → "because"
- Eliminates redundant expressions: "basic fundamentals" → "fundamentals", "end result" → "result"
- Removes category descriptors: "large in size" → "large", "period in time" → "period"
- Promotes concise academic writing based on Brandeis University guidelines

### 24. **DummySubjects.yml**

- Flags weak dummy subjects: "There are", "It is important that"
- Encourages more direct, active sentence construction
- Improves sentence strength and clarity

### 25. **WeakQualifiers.yml**

- Identifies overused qualifiers: "very", "really", "quite"
- Suggests removing or replacing with precise language
- Helps eliminate hedge words that weaken arguments

### 26. **CommonMisusedWords.yml**

- Corrects common word confusions: "its'" → "its", "loose" → "lose"
- Addresses frequent academic writing errors
- Ensures proper word usage

### 27. **ParallelStructure.yml**

- Detects parallelism issues in lists and correlative conjunctions
- Flags inconsistent grammatical forms
- Improves sentence structure and readability

### 28. **StitchingWords.yml**

- Recognizes good transition words: "Furthermore", "However", "Therefore"
- Validates proper academic connectives
- Promotes coherent flow between ideas

### 29. **Enhanced PassiveVoice.yml**

- Updated based on Brandeis guidelines for academic voice
- Suggests passive voice for methods/results sections where appropriate
- Balances objectivity with clarity in scholarly writing

## Usage

Add to your `.vale.ini` file:

```ini
StylesPath = styles

[*.{md,txt,tex}]
BasedOnStyles = Academic
```

## Customization

Each rule can be individually configured or disabled in your `.vale.ini` file:

```ini
# Disable specific rules
Academic.PassiveVoice = NO

# Change severity levels
Academic.FormalLanguage = error
```

## Based On

This style guide is inspired by the Academic Phrasebank (https://www.ref-n-write.com/academic-phrasebank/), which contains over 20,000 phrases extracted from high-quality scientific journals.
