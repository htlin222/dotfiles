import type { PromptAutocompleteSuggestion } from 'claude-code'

// Must match the claude-hooks user-prompt hook (go-tools/internal/hooks/userprompt)
// and snapshot package (claude_last_context_<sha256(cwd)[:8]>.md in /tmp, 24h).
export const DEFAULT_SCREENSHOT_DIR = '/tmp/screenshot'
export const SNAPSHOT_MAX_AGE_MS = 24 * 60 * 60 * 1000

export type Shot = { name: string; mtimeMs: number }

export const ago = (ms: number): string => {
  const m = Math.max(0, Math.round(ms / 60000))
  if (m < 60) return `${m}m ago`
  const h = Math.round(m / 60)
  return h < 48 ? `${h}h ago` : `${Math.round(h / 24)}d ago`
}

export const isImgToken = (token: string) => /^@i(m(g\d*)?)?$/i.test(token)
export const isLastToken = (token: string) => /^@l(a(st?)?)?$/i.test(token)

// Newest first, at most five numbered rows plus the batch forms the hook understands.
export const imgSuggestions = (shots: readonly Shot[], now: number): PromptAutocompleteSuggestion[] => {
  const sorted = [...shots].sort((a, b) => b.mtimeMs - a.mtimeMs).slice(0, 5)
  if (sorted.length === 0) {
    return [{ text: '@img', description: 'no screenshots found' }]
  }
  const rows: PromptAutocompleteSuggestion[] = sorted.map((s, i) => ({
    text: i === 0 ? '@img' : `@img${i + 1}`,
    description: `${s.name} · ${ago(now - s.mtimeMs)}`,
  }))
  if (sorted.length > 1) {
    rows.push({ text: `@img x${sorted.length}`, description: `latest ${sorted.length} screenshots` })
  }
  rows.push({ text: '@img 10m', description: 'screenshots from the last 10 minutes' })
  return rows
}

export const lastSuggestion = (snapshotMtimeMs: number | null, now: number): PromptAutocompleteSuggestion =>
  snapshotMtimeMs !== null && now - snapshotMtimeMs < SNAPSHOT_MAX_AGE_MS
    ? { text: '@LAST', description: `previous session snapshot · ${ago(now - snapshotMtimeMs)}` }
    : { text: '@LAST', description: 'no snapshot for this directory' }

export const snapshotPath = async (cwd: string): Promise<string> => {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(cwd))
  const hex = Array.from(new Uint8Array(digest).slice(0, 4), b => b.toString(16).padStart(2, '0')).join('')
  return `/tmp/claude_last_context_${hex}.md`
}
