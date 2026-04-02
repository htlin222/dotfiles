# Game Theory Optimal (GTO) Basics

## GTO vs Exploitative Play

**GTO**: A balanced strategy that cannot be exploited. You mix value bets and bluffs at theoretically correct ratios so opponents cannot gain an edge regardless of their strategy.

**Exploitative**: Deviate from GTO to target specific opponent weaknesses. More profitable against bad players but vulnerable if opponents adjust.

**Practical approach for this game**:
- Start with approximately GTO strategy
- As you gather reads (from memory file), shift toward exploitative
- Against unknowns: play GTO. Against known tendencies: exploit them.

## Bet Sizing Theory

### Standard Sizes (as fraction of pot)

| Situation                  | Size       | Why                                      |
|----------------------------|------------|------------------------------------------|
| C-bet dry board            | 25-33%     | Little to protect against, cheap info    |
| C-bet wet board            | 50-75%     | Charge draws, protect equity             |
| Value bet (strong hand)    | 50-75%     | Extract max while getting called         |
| Thin value bet             | 33-50%     | Get called by worse, minimize loss if behind |
| Bluff                      | 33-50%     | Risk less to win the pot                 |
| Overbet (polarized)        | 100-150%   | Nut hands or pure bluffs, put max pressure |
| All-in shove               | Varies     | Push/fold spots, big draws, nut hands    |

### Sizing Principle
Bigger bets = opponent needs to defend less often = more fold equity for bluffs, but called only by stronger hands. Smaller bets = opponent must defend wider = less fold equity, but get called by weaker hands.

## Minimum Defense Frequency (MDF)

How often you must call (or raise) to prevent opponent's bluffs from being automatically profitable:

```
MDF = Pot Size / (Pot Size + Bet Size)
```

| Bet Size (% of pot) | MDF (must defend) | Can fold |
|----------------------|-------------------|----------|
| 25%                  | 80%               | 20%      |
| 33%                  | 75%               | 25%      |
| 50%                  | 67%               | 33%      |
| 66%                  | 60%               | 40%      |
| 75%                  | 57%               | 43%      |
| 100%                 | 50%               | 50%      |
| 150%                 | 40%               | 60%      |
| 200%                 | 33%               | 67%      |

**Usage**: If opponent bets 75% pot, you should defend ~57% of your range. Folding more lets their bluffs print money.

## Bluff-to-Value Ratio

At equilibrium, your betting range should include bluffs proportional to the odds you give your opponent.

```
Bluff Frequency = Bet Size / (Pot + 2 x Bet Size)
```

| Bet Size   | Bluff:Value Ratio | Bluffs in Range |
|------------|-------------------|-----------------|
| 33% pot    | 1:4               | 20%             |
| 50% pot    | 1:3               | 25%             |
| 66% pot    | 1:2.5             | 28%             |
| 75% pot    | 2:5               | 29%             |
| 100% pot   | 1:2               | 33%             |
| 150% pot   | 3:5               | 38%             |

**Practical rule**: For a pot-sized bet, about 1/3 of your bets should be bluffs and 2/3 value.

## Polarized vs Merged Ranges

**Polarized range**: You bet with very strong hands (value) and very weak hands (bluffs), checking medium hands. Used when:
- Bet sizing is large (75%+ pot)
- On the river (no more cards to come)
- Against opponents who check-raise a lot

**Merged (linear) range**: You bet with strong and medium hands, not with the weakest. Used when:
- Bet sizing is small (25-50% pot)
- On the flop with many turns/rivers to play
- Against passive opponents who rarely raise

## Position-Based Strategy

### In Position (IP) - Acting last
- Bet more often (information advantage)
- Can thin value bet more aggressively
- Can float (call with weak hands to bluff later)
- Control pot size by checking back

### Out of Position (OOP) - Acting first
- Check more often (let IP bet, then decide)
- Check-raise as primary aggression tool
- Use donk bets sparingly (leading into pre-flop raiser)
- Play tighter ranges to compensate for positional disadvantage

### C-Betting (Continuation Bet) Frequencies
- **IP, heads-up**: C-bet 55-70% of flops
- **OOP, heads-up**: C-bet 30-45% of flops
- **Multiway**: C-bet only 25-35% (more opponents = someone likely hit)

## Push/Fold Strategy (Short Stacks)

When your stack is 10 big blinds or less, poker simplifies to push (all-in) or fold.

### Nash Equilibrium Push Ranges (approximate)

| Position | Stack (BB) | Push Range                                     |
|----------|-----------|------------------------------------------------|
| BTN      | 10        | Any pair, any ace, K2s+, K7o+, Q5s+, Q9o+, J7s+, JTo, T8s+, 97s+, 87s |
| BTN      | 5         | Almost any two cards (~70% of hands)           |
| SB       | 10        | Any pair, any ace, K2s+, K5o+, Q7s+, QTo+, J8s+, JTo, T8s+ |
| SB       | 5         | ~80% of hands                                  |
| CO       | 10        | Pairs 22+, A2s+, A7o+, K9s+, KTo+, QTs+, JTs |

### Nash Equilibrium Call Ranges (vs push)
Generally much tighter than push ranges:
- **BB vs BTN push (10BB)**: 77+, A8s+, ATo+, KJs+
- **BB vs SB push (10BB)**: 55+, A5s+, A8o+, KTs+, KJo+, QJs
- **BB vs BTN push (5BB)**: 22+, A2s+, A5o+, K8s+, KTo+, Q9s+, QTo+, JTs

## ICM Considerations (Tournament/Sit-and-Go)

**ICM** (Independent Chip Model) adjusts strategy based on payout structure:

- **Chips have diminishing value**: Winning 1000 chips is worth less than losing 1000 chips in tournament equity
- **Bubble factor**: Near the money, survival is paramount. Tighten significantly.
- **Big stack advantage**: Big stacks can pressure shorter stacks who must avoid busting
- **Short stack strategy**: Look for spots to double up early before blinds eat you

**Key ICM adjustments**:
- Avoid marginal all-ins against players who cover you near the bubble
- Attack short stacks more aggressively
- Tighten calling ranges (the risk of busting outweighs the chip gain)

## Practical GTO Shortcuts

1. **When unsure, bet 50-66% pot** - versatile size that works in most situations
2. **On dry boards, bet small or check** - less equity to deny, save money
3. **On wet boards, bet bigger** - charge draws, protect your hand
4. **River: polarize** - bet big with nuts or air, check medium hands
5. **Facing aggression with a medium hand: call once, then reassess** - avoid escalating with marginal holdings
6. **Respect check-raises** - they are heavily weighted toward strong hands at most levels
7. **Bluff with equity** - semi-bluff with draws rather than pure air when possible
