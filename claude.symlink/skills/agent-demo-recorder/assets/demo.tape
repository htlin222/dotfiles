# VHS tape template: record a Claude Code session demo.
# Render with: vhs demo.tape
# Requires the Stop hook from assets/settings.json in the demo dir's .claude/
Output claude-demo.gif

# Layout is 16:9. For extra-crisp (2x DPI) output, double all three values
# together (FontSize 54, Width 3200, Height 1800) — same text layout.
Set FontSize 27
Set Width 1600
Set Height 900
# Theme: dark default; swap the comment for light mode
Set Theme "Catppuccin Mocha"
# Set Theme "Catppuccin Latte"
# Word-by-word reveal: small per-char TypingSpeed (NOT 0 — Codex reads a 0ms
# burst as a paste and Enter stops submitting) + one `Type` per word with a
# `Sleep` between words. Then `Sleep 3s` before `Enter` to read the prompt.
Set TypingSpeed 20ms  # nonzero: Codex treats a 0ms burst as paste (Enter won't submit)

# Gate for the Stop hook — only VHS-recorded sessions print the sentinel
Env VHS_DEMO "1"

# Let the shell prompt initialize before typing
Sleep 2s
Type "claude"
Enter

# Wait for the Claude Code UI to render
Wait+Screen@60s /shift\+tab|for shortcuts/

# --- Turn 1 (word-by-word: one Type per word, leading space joins them) ---
Type "explain"
Sleep 220ms
Type " what"
Sleep 220ms
Type " a"
Sleep 220ms
Type " .tape"
Sleep 220ms
Type " file"
Sleep 220ms
Type " is"
Sleep 220ms
Type " in"
Sleep 220ms
Type " one"
Sleep 220ms
Type " sentence"
Sleep 3s
Enter
Wait+Screen@120s /VHS_TURN_DONE_1/

# --- Add more turns by copying the block above and bumping the sentinel:
# Type "next"
# Sleep 220ms
# Type " prompt"
# Sleep 3s
# Enter
# Wait+Screen@120s /VHS_TURN_DONE_2/

# Hold on the finished response before exiting
Sleep 5s

# Quit Claude Code cleanly (Ctrl+C twice)
Ctrl+C
Sleep 500ms
Ctrl+C
Sleep 1s
