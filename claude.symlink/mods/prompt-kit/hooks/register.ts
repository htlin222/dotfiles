import type { Register } from 'claude-code'

import {
  DEFAULT_SCREENSHOT_DIR,
  imgSuggestions,
  isImgToken,
  isLastToken,
  lastSuggestion,
  snapshotPath,
} from './suggest'

// Typeahead only: expansion of @img / @LAST stays in the claude-hooks
// user-prompt hook, which Codex-independent Go code already owns.
export const register: Register = on => {
  on('prompt.autocomplete', { token: /^@[il]/i }, async ($, e, next) => {
    const base = await next(e)
    const now = await $.clock.now()

    if (isImgToken(e.token)) {
      const dir = (await $.env.get('SCREENSHOT_DIR')) || DEFAULT_SCREENSHOT_DIR
      const entries = (await $.fs.exists(dir)) ? await $.fs.list(dir) : []
      const shots = entries.filter(f => f.kind === 'file' && !f.name.startsWith('.'))
      return { suggestions: [...base.suggestions, ...imgSuggestions(shots, now)] }
    }

    if (isLastToken(e.token)) {
      const path = await snapshotPath(await $.session.cwd())
      const mtime = (await $.fs.exists(path)) ? (await $.fs.stat(path)).mtimeMs : null
      return { suggestions: [...base.suggestions, lastSuggestion(mtime, now)] }
    }

    return base
  })
}
