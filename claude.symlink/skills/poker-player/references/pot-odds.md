# Pot Odds and Equity Reference

## Pot Odds Formula

```
Pot Odds % = Cost to Call / (Current Pot + Cost to Call)
```

**Example**: Pot is 100, opponent bets 50, you must call 50.
```
Pot Odds = 50 / (100 + 50 + 50) = 50 / 200 = 25%
```
You need at least 25% equity to call profitably.

## Outs-to-Equity Conversion Table

| Outs | Turn Only | River Only | Turn + River |
|------|-----------|------------|--------------|
| 1    | 2.1%      | 2.2%       | 4.3%         |
| 2    | 4.3%      | 4.3%       | 8.4%         |
| 3    | 6.4%      | 6.5%       | 12.5%        |
| 4    | 8.5%      | 8.7%       | 16.5%        |
| 5    | 10.6%     | 10.9%      | 20.3%        |
| 6    | 12.8%     | 13.0%      | 24.1%        |
| 7    | 14.9%     | 15.2%      | 27.8%        |
| 8    | 17.0%     | 17.4%      | 31.5%        |
| 9    | 19.1%     | 19.6%      | 35.0%        |
| 10   | 21.3%     | 21.7%      | 38.4%        |
| 11   | 23.4%     | 23.9%      | 41.7%        |
| 12   | 25.5%     | 26.1%      | 45.0%        |
| 13   | 27.7%     | 28.3%      | 48.1%        |
| 14   | 29.8%     | 30.4%      | 51.2%        |
| 15   | 31.9%     | 32.6%      | 54.1%        |
| 16   | 34.0%     | 34.8%      | 57.0%        |
| 17   | 36.2%     | 37.0%      | 59.8%        |
| 18   | 38.3%     | 39.1%      | 62.4%        |
| 19   | 40.4%     | 41.3%      | 65.0%        |
| 20   | 42.6%     | 43.5%      | 67.5%        |

**Quick mental math**: Outs x 2 for one card, Outs x 4 for two cards (from flop).

## Common Draw Scenarios

| Draw                        | Outs | ~Turn% | ~River% | Example                    |
|-----------------------------|------|--------|---------|----------------------------|
| Gutshot straight draw       | 4    | 8.5%   | 16.5%   | 5-7 on 6-9-K board (need 8)|
| Two overcards               | 6    | 12.8%  | 24.1%   | AK on 7-8-2 board          |
| Open-ended straight draw    | 8    | 17.0%  | 31.5%   | 8-9 on 6-7-K board         |
| Flush draw                  | 9    | 19.1%  | 35.0%   | Two hearts, two on board   |
| Flush draw + gutshot        | 12   | 25.5%  | 45.0%   | Combo draw                 |
| Flush draw + open-ender     | 15   | 31.9%  | 54.1%   | Monster combo draw         |
| Flush draw + pair           | 14   | 29.8%  | 51.2%   | Pair + flush draw          |

## Break-Even Equity by Bet Size

The equity you need to call profitably at common bet sizes:

| Bet (% of pot) | Pot Odds % | You Need   |
|----------------|------------|------------|
| 25%            | 16.7%     | >16.7% equity |
| 33%            | 20.0%     | >20.0% equity |
| 50%            | 25.0%     | >25.0% equity |
| 66%            | 28.4%     | >28.4% equity |
| 75%            | 30.0%     | >30.0% equity |
| 100% (pot)     | 33.3%     | >33.3% equity |
| 150%           | 37.5%     | >37.5% equity |
| 200% (2x pot)  | 40.0%     | >40.0% equity |

## Implied Odds

Pot odds only account for what is in the pot now. **Implied odds** account for future bets you expect to win if you hit your draw.

```
Implied Odds = Cost to Call / (Current Pot + Cost to Call + Expected Future Winnings)
```

**When implied odds matter**:
- Deep stacks (lots of chips behind to win)
- Drawing to well-disguised hands (sets, backdoor flushes)
- Opponent likely to pay off (calling stations)

**When implied odds are weak**:
- Short stacks (not much left to win)
- Obvious draws (4-flush on board, everyone sees it)
- Opponent likely to check/fold if draw hits

**Example**: Pot is 100, opponent bets 50. You have a gutshot (4 outs, ~8.5% on turn). Direct pot odds need 25% but you only have 8.5%. However, if you expect to win an additional 300 when you hit:
```
Implied Odds = 50 / (100 + 50 + 50 + 300) = 50 / 500 = 10%
```
Still not enough (8.5% < 10%). You would need to expect winning ~440 more to justify the call.

## Reverse Implied Odds

Sometimes you hit your hand but still lose (e.g., you make a flush but opponent has a higher flush). Discount your outs when:
- Your flush draw is not to the nut flush (discount 1-2 outs)
- Your straight draw could complete to a higher straight for opponent
- Board pairs and you might be drawing dead to a full house
