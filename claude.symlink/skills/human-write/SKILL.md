---
name: human-write
description: Use when polishing or reviewing English text to avoid AI-flavored vocabulary. Scans for LLM-preferred words identified by PubMed research (delve, meticulous, underscore, etc.) and suggests natural alternatives.
---

# Human Write

請 AI 幫忙潤稿嗎？請避開以下詞！

基於 2025 年兩篇研究，分析 2,750 萬篇 PubMed 文獻，找出 AI 偏好的英文詞彙。

## 觸發時機

- 用戶請你潤飾英文文章
- 用戶請你寫英文學術/專業文章
- 用戶想檢查文章裡有沒有 AI 味的英文詞
- 用戶說 "human-write" 或 "scan AI words"

## 快速掃描：Top 10 最嚴重的 AI 詞

寫完或潤完稿，先搜這 10 個。出現任何一個都要三思：

| 排名 | 詞彙          | 為什麼可疑                     | 替換方向             |
| ---- | ------------- | ------------------------------ | -------------------- |
| 1    | **delve**     | 2024 Z-score 最高，AI 最愛用   | explore, examine, look into |
| 2    | **underscore**| AI 用來替代 emphasize          | emphasize, highlight, stress |
| 3    | **meticulous**| AI 最愛的形容詞                | careful, thorough, precise |
| 4    | **intricate** | AI 用來替代 complex            | complex, detailed, elaborate |
| 5    | **tapestry**  | AI 愛用的比喻詞                | mix, combination, array |
| 6    | **commendable** | AI 的誇獎用語                | impressive, notable, solid |
| 7    | **showcase**  | AI 用來替代 show/demonstrate   | show, demonstrate, present |
| 8    | **pivotal**   | AI 用來替代 important/key      | key, important, central |
| 9    | **bolster**   | AI 用來替代 support/strengthen | support, strengthen, back up |
| 10   | **surpass**   | AI 用來替代 exceed/outperform  | exceed, beat, outperform |

## 完整 AI 偏好詞彙表

<details>
<summary>動詞 (Verbs) — 點擊展開</summary>

| AI 偏好              | 更自然的替代                          |
| -------------------- | ------------------------------------- |
| delve (into)         | explore, look into, examine           |
| underscore           | emphasize, highlight, stress          |
| showcase             | show, demonstrate, present            |
| bolster              | support, strengthen, back up          |
| elucidate            | explain, clarify, make clear          |
| garner               | gain, attract, earn, get              |
| leverage             | use, take advantage of, build on      |
| unveil               | reveal, introduce, present            |
| scrutinize           | examine, inspect, review              |
| surpass              | exceed, beat, outperform              |
| boast                | have, feature, offer                  |
| foster               | encourage, promote, support           |
| facilitate           | help, enable, make easier             |
| harness              | use, apply, put to use                |
| navigate             | handle, manage, deal with             |
| streamline           | simplify, improve, speed up           |
| illuminate           | show, reveal, shed light on           |
| spearhead            | lead, drive, champion                 |
| embark (on)          | start, begin, launch                  |
| endeavor             | try, attempt, work toward             |
| encompass            | include, cover, span                  |
| catalyze             | trigger, spark, drive                 |
| augment              | add to, increase, supplement          |
| delineate            | describe, outline, define             |
| juxtapose            | compare, contrast, set side by side   |
| transcend            | go beyond, rise above, exceed         |

</details>

<details>
<summary>形容詞 (Adjectives) — 點擊展開</summary>

| AI 偏好              | 更自然的替代                         |
| -------------------- | ------------------------------------ |
| meticulous           | careful, thorough, precise           |
| intricate            | complex, detailed, elaborate         |
| pivotal              | key, important, central, crucial     |
| commendable          | impressive, notable, solid, good     |
| groundbreaking       | new, innovative, first-of-its-kind   |
| transformative       | significant, game-changing, major    |
| nuanced              | subtle, complex, layered             |
| comprehensive        | full, complete, thorough             |
| robust               | strong, solid, reliable              |
| multifaceted         | complex, varied, diverse             |
| noteworthy           | notable, worth noting, significant   |
| paramount            | most important, top, critical        |
| holistic             | overall, whole, complete             |
| overarching          | main, broad, general                 |
| unprecedented        | never before seen, first, new        |
| salient              | key, main, important                 |
| burgeoning           | growing, rising, expanding           |

</details>

<details>
<summary>副詞 (Adverbs) — 點擊展開</summary>

| AI 偏好              | 更自然的替代                         |
| -------------------- | ------------------------------------ |
| primarily            | mainly, mostly, largely              |
| notably              | especially, in particular            |
| predominantly        | mostly, mainly, largely              |
| compellingly         | convincingly, strongly               |
| profoundly           | deeply, greatly, strongly            |
| moreover             | also, besides, in addition           |
| furthermore          | also, and, in addition               |
| importantly          | (often deletable — just state it)    |
| crucially            | (often deletable — just state it)    |
| remarkably           | surprisingly, strikingly             |
| substantially        | greatly, significantly, a lot        |
| inherently           | by nature, naturally, fundamentally  |

</details>

<details>
<summary>名詞 (Nouns) — 點擊展開</summary>

| AI 偏好              | 更自然的替代                         |
| -------------------- | ------------------------------------ |
| tapestry             | mix, combination, range              |
| realm                | area, field, domain                  |
| landscape            | field, area, scene, picture          |
| synergy              | teamwork, cooperation, combined effect |
| paradigm             | model, approach, framework           |
| nexus                | link, connection, center             |
| interplay            | interaction, relationship            |
| cornerstone          | foundation, basis, key part          |
| underpinning         | basis, foundation, support           |
| discourse            | discussion, debate, conversation     |
| trajectory           | path, direction, trend               |
| myriad               | many, numerous, a wide range of      |
| plethora             | many, plenty, a lot of               |

</details>

## 使用方式

### 模式一：潤稿時自動避開

幫用戶潤飾英文時，**主動**避開以上所有詞彙。如果原文沒有這些詞，潤稿後也不該出現。

規則：
1. **不加入原文沒有的 AI 詞** — 潤稿是改善，不是加料
2. **替換原文已有的 AI 詞** — 用更自然的替代詞，但先問用戶
3. **保留用戶的聲音** — 如果用戶本來就愛用某個詞，別幫他換掉

### 模式二：掃描檢測

用內建腳本掃描文章，產生 AI 詞彙密度報告：

```bash
python3 ~/.claude/skills/human-write/scan-ai-words.py <file>
# 或從 stdin
cat essay.txt | python3 ~/.claude/skills/human-write/scan-ai-words.py
```

#### 輸出格式

```
═══ AI Word Scan Report ═══

Score: 3.2 / 10  (moderate AI flavor)

Found 8 AI-flavored words in 1,200 words (0.67% density)

  TIER 1 (top flagged):
    delve ×2  (lines 5, 23)
    meticulous ×1  (line 14)

  TIER 2 (commonly flagged):
    comprehensive ×3  (lines 8, 31, 45)
    furthermore ×2  (lines 12, 38)

Suggestions:
  Line 5:  "delve into the mechanisms" → try "explore the mechanisms"
  Line 14: "meticulous analysis" → try "careful analysis"
  ...
```

#### 評分標準

| 分數  | 密度        | 解讀                 |
| ----- | ----------- | -------------------- |
| 0-2   | < 0.2%      | 自然，幾乎無 AI 痕跡 |
| 3-4   | 0.2%-0.5%   | 輕微，稍作替換即可   |
| 5-6   | 0.5%-1.0%   | 中度，建議逐一檢查   |
| 7-8   | 1.0%-2.0%   | 明顯，需要大量改寫   |
| 9-10  | > 2.0%      | 強烈 AI 味，重寫吧   |

## 研究背景

<details>
<summary>為什麼這些詞？研究怎麼說 — 點擊展開</summary>

### 兩篇關鍵論文

1. **Matsui K. (2025)**. Delving Into PubMed Records: How AI-Influenced Vocabulary has Transformed Medical Writing since ChatGPT. *Perspectives on Medical Education*, 14(1), 882-890.
2. **Kobak, D., et al. (2025)**. Delving into LLM-assisted writing in biomedical publications through excess vocabulary. *Science Advances*, 11(27), eadt3813.

### 核心發現

- 分析 2,750 萬篇 PubMed 紀錄 (2000-2024)
- 135 個 AI 偏好詞彙中，103 個在 2024 年出現統計上顯著暴增
- 趨勢從 **2020 年**就開始（ChatGPT 發布前兩年）
- 對照組 84 個標準學術用語大多穩定

### 雙相模式

- **第一階段 (2020-2022)**：DeepL、Grammarly 等早期 AI 工具開始影響詞彙選擇
- **第二階段 (2023-至今)**：ChatGPT 爆發，AI 詞彙被大規模放大 (β = 0.655, p < 0.001)

### 非英語母語研究者

- 來自中國、韓國、台灣等地的論文，AI 詞彙使用比例約 20%
- 英語國家約 5%
- 這不代表「不當使用」，但代表需要更注意審稿後編輯

### 重要提醒

- 詞彙「出現」不代表一定是 AI 寫的
- 關鍵是**密度**：人類偶爾用 delve 很正常，每段都用就不正常
- AI 沒有「創造」這些用法，但大大「放大」了它們
- 同時，一些傳統學術用語反而減少了：purpose of, hypothesis, results suggest

</details>

## 注意事項

- 這個清單基於**醫學文獻**研究，但 AI 偏好詞彙在各領域通用
- 不是說這些詞「不能用」，而是用之前要確認是自己的選擇
- 非英語母語者用 AI 潤稿完全合理，只要最後自己編輯一遍
- **AI 是草稿機，不是代筆人**
