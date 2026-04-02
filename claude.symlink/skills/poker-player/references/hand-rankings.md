# Hand Rankings Reference

## Made Hand Rankings (Best to Worst)

| Rank | Hand            | Example             | Description                    |
|------|-----------------|---------------------|--------------------------------|
| 1    | Royal Flush     | A K Q J T (all same suit) | Top 5 cards of one suit  |
| 2    | Straight Flush  | 9 8 7 6 5 (all hearts)   | 5 consecutive, one suit  |
| 3    | Four of a Kind  | K K K K 7            | Four same rank                |
| 4    | Full House      | Q Q Q 8 8            | Three + pair                  |
| 5    | Flush           | A J 8 5 3 (all clubs)| 5 same suit, any order        |
| 6    | Straight        | T 9 8 7 6 (mixed)   | 5 consecutive, mixed suits    |
| 7    | Three of a Kind | 7 7 7 K 3            | Three same rank               |
| 8    | Two Pair        | J J 4 4 A            | Two different pairs           |
| 9    | One Pair        | A A 9 6 3            | Two same rank                 |
| 10   | High Card       | A K 8 5 2 (no combo)| Nothing connects              |

**Kicker rule**: When hands tie in rank, highest remaining card(s) break the tie.

## Pre-Flop Starting Hand Tiers

### Tier 1 - Premium (Always raise/3-bet)
AA, KK, QQ, JJ, AKs

### Tier 2 - Strong (Raise, call 3-bets selectively)
TT, 99, AQs, AJs, KQs, AKo, AQo

### Tier 3 - Playable (Raise or call a single raise)
88, 77, 66, ATs, A9s-A2s, KJs, KTs, QJs, QTs, JTs, T9s, 98s, 87s, KQo, AJo, ATo

### Tier 4 - Speculative (Play in position, multiway pots, cheap)
55, 44, 33, 22, K9s, Q9s, J9s, T8s, 97s, 86s, 76s, 65s, 54s, KJo, QJo, JTo

### Tier 5 - Trash (Fold unless stealing blinds from button)
Everything else. K5o, Q7o, J3o, etc.

## Position-Based Opening Ranges

**s** = suited, **o** = offsuit. "+" means that hand and all better versions.

### Early Position (UTG, UTG+1) - ~15% of hands
- Pairs: 77+
- Suited: ATs+, KQs
- Offsuit: AQo+

### Middle Position (MP, LJ) - ~20% of hands
- Pairs: 55+
- Suited: A8s+, KJs+, QJs, JTs, T9s
- Offsuit: AJo+, KQo

### Late Position (HJ, CO) - ~28% of hands
- Pairs: 22+
- Suited: A2s+, K9s+, Q9s+, J9s+, T8s+, 97s+, 87s, 76s, 65s
- Offsuit: ATo+, KJo+, QJo, JTo

### Button (BTN) - ~40% of hands
- Pairs: 22+
- Suited: A2s+, K5s+, Q7s+, J8s+, T7s+, 96s+, 85s+, 75s+, 64s+, 54s
- Offsuit: A7o+, K9o+, QTo+, JTo, T9o

### Small Blind (SB) - ~35% vs fold-to, tighter vs raises
- Similar to Button but slightly tighter (out of position post-flop)

### Big Blind (BB) - Defend wider due to discount
- Call with ~40-50% of hands getting 3.5:1 or better
- 3-bet with Tier 1-2 hands

## Quick Pre-Flop Decision Guide

1. **Look at your cards** - which tier?
2. **Look at your position** - early = tight, late = wide
3. **Look at action before you**:
   - No raise yet: Open-raise with your position range
   - Single raise: Call with Tier 1-3 in position, 3-bet Tier 1-2
   - 3-bet already: Only continue with Tier 1 (maybe Tier 2 in position)
   - Multiple callers: Speculative hands (small pairs, suited connectors) go up in value

## Post-Flop Hand Strength Categories

**Monster** (bet/raise for max value):
- Sets (three of a kind with pocket pair), straights, flushes, full houses

**Strong** (bet for value, protect against draws):
- Top pair top kicker, overpair, two pair

**Medium** (bet small or check-call):
- Top pair weak kicker, middle pair, bottom two pair on wet board

**Draw** (semi-bluff or call if odds are right):
- Flush draw (9 outs), open-ended straight draw (8 outs), combo draws (12-15 outs)

**Weak/Nothing** (check-fold or bluff):
- No pair, no draw, missed completely. Bluff only if position and story support it.
