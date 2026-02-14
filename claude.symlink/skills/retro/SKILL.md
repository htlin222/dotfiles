---
name: retro
description: Review the current Claude Code session conversation. Extracts only human-readable content (user prompts and agent prose responses, skipping tool calls and tool results), then produces a structured retrospective report covering accomplishments, efficiency improvements, English corrections, learning recommendations, and CLAUDE.md suggestions. Use when the user asks to review, retrospect, or summarize the session — especially at the end of a work session.
---

# Session Review Skill

Generate a structured retrospective report for the current Claude Code session.

## Core Principle

**Extract only human-readable content.** This means:

- ✅ User messages (the human's prompts/questions/instructions)
- ✅ Agent prose responses (explanations, reasoning, summaries, answers)
- ❌ Tool calls (bash commands, file reads/writes, search queries)
- ❌ Tool results (command output, file contents, API responses)
- ❌ System messages and internal metadata

## Extraction Script

A companion Python script handles robust extraction from session JSONL files:

```bash
# Extract transcript from the current project's latest session
python3 ~/.dotfiles/claude.symlink/skills/retro/extract_conversation.py --timestamps --stats

# Or target a specific project
python3 ~/.dotfiles/claude.symlink/skills/retro/extract_conversation.py --project-dir /path/to/project --timestamps --stats

# Output as structured JSON (for programmatic use)
python3 ~/.dotfiles/claude.symlink/skills/retro/extract_conversation.py --format json

# List all sessions for a project
python3 ~/.dotfiles/claude.symlink/skills/retro/extract_conversation.py --list-sessions
```

The script (`extract_conversation.py` in this skill's directory) parses Claude Code JSONL logs and:
- Keeps only user prompts and assistant prose (`type: "text"` blocks)
- Strips `tool_use`, `tool_result`, `thinking` blocks, `<system-reminder>` tags, progress events, and file-history snapshots
- Supports `markdown`, `json`, and `plain` output formats
- Auto-detects the latest session for the current or specified project
- Zero external dependencies (stdlib only)

## Output Format: Bullet Points + IMRaD Structure

Use the following structure for the report. Write in **Markdown** with bullet points. The format adapts IMRaD (Introduction, Methods, Results, and Discussion) for session retrospectives.

---

### Template

```markdown
# Session Review — [Date] — [Brief Topic/Goal]

## Introduction (What & Why)
- **Goal**: What was the user trying to accomplish this session?
- **Context**: Any relevant background (project name, stage of work, blockers)

## Methods (How We Worked)
- **Approach**: High-level steps taken to reach the goal
- **Tools/Technologies**: Key tools, libraries, languages involved
- **Workflow Pattern**: How the conversation flowed (linear, iterative, exploratory, debugging loop, etc.)

## Results (What We Accomplished)
- **Completed**:
  - [item 1]
  - [item 2]
  - ...
- **Partially Completed**:
  - [item — what remains]
- **Not Started / Deferred**:
  - [item — reason]

## Discussion

### Efficiency Review
Where the user could have been more efficient with prompts or workflow:
- **[Issue]**: [What happened] → **Suggestion**: [Better approach]
- ...

### English Corrections
Grammar, word choice, or phrasing improvements from the user's messages:
- ❌ `[original text]` → ✅ `[corrected text]` — [brief explanation]
- ...
(If no corrections needed, write: "No corrections — messages were clear and well-written.")

### Concepts to Study Deeper
Topics that came up where deeper understanding would help:
- **[Concept]**: [Why it matters / what to explore]
- ...

### CLAUDE.md Improvement Suggestions
Suggested additions or changes to the project's CLAUDE.md based on friction points observed in this session:
- **Add**: `[suggested line or section]` — [reason: what friction it would prevent]
- **Modify**: `[existing section]` → `[suggested change]` — [reason]
- ...
```

---

## Instructions for the Agent

1. **Run the extraction script.** Execute the companion script to get a clean transcript:
   ```bash
   python3 ~/.dotfiles/claude.symlink/skills/retro/extract_conversation.py --timestamps --stats
   ```
   This produces a markdown transcript with only user prompts and assistant prose — no tool noise.
   If the script fails or no session file is found, fall back to manually scanning the conversation history and mentally filtering out tool calls/results.

2. **Review the extracted transcript.** Read through the clean output from start to finish. Focus on:
   - What the user asked or instructed
   - What the agent explained, suggested, or decided

3. **Identify the session goal.** Infer from the first few user messages what the overarching objective was.

4. **Catalog accomplishments.** List concrete outputs: files created, bugs fixed, features implemented, decisions made.

5. **Analyze efficiency.** Look for patterns like:
   - Vague prompts that required multiple clarification rounds
   - Tasks that could have been batched into a single prompt
   - Missing context that caused the agent to go in the wrong direction
   - Repeated back-and-forth that a better initial prompt would have avoided
   - Manual steps that could be automated or added to CLAUDE.md

6. **Correct English.** Review every user message for:
   - Grammar errors (subject-verb agreement, tense, articles)
   - Word choice improvements (more precise or natural phrasing)
   - Typos or spelling
   - Be respectful — these are learning opportunities, not criticisms

7. **Identify learning opportunities.** Note concepts where the user:
   - Asked basic questions suggesting a knowledge gap
   - Made assumptions that turned out wrong
   - Could benefit from reading documentation or tutorials

8. **Suggest CLAUDE.md improvements.** Look for:
   - Repeated instructions the user gave that should be codified
   - Preferences or conventions that had to be restated
   - Project-specific knowledge that was missing and caused friction
   - Workflow patterns that should be documented

9. **Write the report** using the template above. Keep bullet points concise but informative. Use code formatting for file names, commands, and code references.

## Tone

- Constructive and supportive — this is a learning tool, not a critique
- Specific and actionable — vague feedback is useless
- Honest — don't skip real issues to be polite

## Notes

- If the session was very short or trivial, scale the report accordingly — no need to force content into every section.
- If the user's English was flawless, say so. Don't invent corrections.
- The CLAUDE.md suggestions should be practical and specific, not generic advice like "add more documentation."
