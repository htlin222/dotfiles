import { describe, expect, test } from 'claude-code/testing'

import { ago, imgSuggestions, isImgToken, isLastToken, lastSuggestion, snapshotPath } from './suggest'

const MIN = 60_000
const NOW = 1_000 * MIN

describe('tokens', () => {
  test('img prefixes match, others do not', async () => {
    for (const t of ['@i', '@im', '@img', '@IMG', '@img2']) expect(isImgToken(t)).toBe(true)
    for (const t of ['@imgur', '@l', 'img', '@x']) expect(isImgToken(t)).toBe(false)
  })
  test('last prefixes match', async () => {
    for (const t of ['@l', '@la', '@las', '@last', '@LAST']) expect(isLastToken(t)).toBe(true)
    for (const t of ['@lastly', '@i']) expect(isLastToken(t)).toBe(false)
  })
})

describe('imgSuggestions', () => {
  test('no screenshots → one hint row', async () => {
    expect(imgSuggestions([], NOW)).toEqual([{ text: '@img', description: 'no screenshots found' }])
  })
  test('newest first, numbered, with batch rows', async () => {
    const rows = imgSuggestions(
      [
        { name: 'old.png', mtimeMs: NOW - 90 * MIN },
        { name: 'new.png', mtimeMs: NOW - 2 * MIN },
      ],
      NOW,
    )
    expect(rows).toEqual([
      { text: '@img', description: 'new.png · 2m ago' },
      { text: '@img2', description: 'old.png · 2h ago' },
      { text: '@img x2', description: 'latest 2 screenshots' },
      { text: '@img 10m', description: 'screenshots from the last 10 minutes' },
    ])
  })
  test('caps at five numbered rows', async () => {
    const shots = Array.from({ length: 8 }, (_, i) => ({ name: `s${i}.png`, mtimeMs: NOW - i * MIN }))
    expect(imgSuggestions(shots, NOW).filter(r => /^@img\d*$/.test(r.text)).length).toBe(5)
  })
})

describe('lastSuggestion', () => {
  test('fresh snapshot shows its age', async () => {
    expect(lastSuggestion(NOW - 30 * MIN, NOW).description).toBe('previous session snapshot · 30m ago')
  })
  test('missing or stale snapshot says so', async () => {
    expect(lastSuggestion(null, NOW).description).toBe('no snapshot for this directory')
    expect(lastSuggestion(NOW - 25 * 60 * MIN, NOW).description).toBe('no snapshot for this directory')
  })
})

test('ago formats minutes, hours, days', async () => {
  expect(ago(5 * MIN)).toBe('5m ago')
  expect(ago(3 * 60 * MIN)).toBe('3h ago')
  expect(ago(72 * 60 * MIN)).toBe('3d ago')
})

test('snapshotPath matches the Go hash (sha256 hex, first 4 bytes)', async () => {
  // sha256("/Users/htlin/.dotfiles") — expected value computed independently with shasum.
  expect(await snapshotPath('/Users/htlin/.dotfiles')).toBe(`/tmp/claude_last_context_2654e947.md`)
})
