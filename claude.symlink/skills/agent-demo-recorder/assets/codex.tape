# Scripted VHS demo of a Codex CLI session.
# Codex + VHS quirk: Wait+Screen on the sentinel is reliable only for the
# FIRST turn; on later turns the polling disturbs Codex's rendering
# (verified 3/3 failures). Use generous Sleeps for turns >= 2, or prefer
# live tmux mode for multi-turn Codex demos.
Output codex-vhs.gif

# Layout is 16:9. For extra-crisp (2x DPI) output, double all three values
# together (FontSize 54, Width 3200, Height 1800) — same text layout.
Set FontSize 27
Set Width 1600
Set Height 900
# Theme: dark default; swap the comment for light mode
Set Theme "Catppuccin Mocha"
# Set Theme "Catppuccin Latte"
# Word-by-word reveal: small per-char TypingSpeed (NOT 0 — Codex reads a 0ms
# burst as a paste) + one Type per word with a Sleep between words.
Set TypingSpeed 20ms  # nonzero: Codex treats a 0ms burst as paste (Enter won't submit)

Env VHS_DEMO "1"

# Let the shell prompt initialize before typing
Sleep 2s
Type "codex"
Enter
Wait+Screen@60s /model to change/
Sleep 2s

# --- Turn 1: sentinel Wait is safe here (word-by-word prompt) ---
Type "in"
Sleep 220ms
Type " one"
Sleep 220ms
Type " short"
Sleep 220ms
Type " sentence,"
Sleep 220ms
Type " what"
Sleep 220ms
Type " is"
Sleep 220ms
Type " the"
Sleep 220ms
Type " VHS"
Sleep 220ms
Type " terminal"
Sleep 220ms
Type " recorder?"
Sleep 3s
Enter
Wait+Screen@120s /VHS_TURN_DONE_1/

# --- Turn 2: Sleep-based (no Wait — see header note) ---
Sleep 3s
Type "and"
Sleep 220ms
Type " what"
Sleep 220ms
Type " file"
Sleep 220ms
Type " extension"
Sleep 220ms
Type " do"
Sleep 220ms
Type " its"
Sleep 220ms
Type " scripts"
Sleep 220ms
Type " use?"
Sleep 3s
Enter
Sleep 1s
Enter
Sleep 25s

# Hold on the finished response before exiting
Sleep 5s

# Quit Codex (Ctrl+C twice)
Ctrl+C
Sleep 500ms
Ctrl+C
Sleep 1s
