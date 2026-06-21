#!/usr/bin/env bash
# im-select-abc — UserPromptSubmit hook.
# On macOS, switch the active input method to ABC (com.apple.keylayout.ABC)
# so prompt input lands in a Latin layout regardless of prior IME state.
#
# Design: async, robust, fire-and-forget. Never blocks Claude Code and always
# exits 0 — input-method switching must never fail a prompt submission.

# Only on macOS; no-op everywhere else.
[ "$(uname -s)" = "Darwin" ] || exit 0

# Only if im-select is installed (resolve via PATH; also probe Homebrew prefix
# since hooks may run with a minimal PATH).
im_select="$(command -v im-select 2>/dev/null)"
[ -n "$im_select" ] || for p in /opt/homebrew/bin/im-select /usr/local/bin/im-select; do
	[ -x "$p" ] && im_select="$p" && break
done
[ -n "$im_select" ] || exit 0

# Fire-and-forget: detach into the background so the hook returns immediately.
# nohup + redirected streams keep it alive and silent past hook teardown.
( nohup "$im_select" com.apple.keylayout.ABC >/dev/null 2>&1 & ) >/dev/null 2>&1

exit 0
