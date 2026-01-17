# 計畫：為因果推論簡報新增 R 視覺化

## 目標

為初學者新增更多 R chunk 視覺化，幫助理解因果推論的概念和流程。

## 目前已有的視覺化

1. PS overlap density plot (Line 371-404)
2. Love plot / SMD balance (Line 908-946)
3. E-value sensitivity plot (Line 1086-1126)
4. gtsummary baseline table (Line 673-710)
5. Mermaid flowcharts (多處)

## 建議新增的視覺化（按簡報順序）

### 第一部分：為什麼需要因果推論

#### 1. 混淆效應視覺化 (新增於 ~Line 75 後)

- **目的**：用圖表顯示 Simpson's Paradox 風格的混淆
- **內容**：兩組病人的結果比較，分層前 vs 分層後
- **方式**：ggplot2 bar chart + facet

#### 2. 反事實概念圖 (新增於 ~Line 97 後)

- **目的**：讓「counterfactual」變得直觀
- **內容**：一個病人的「觀察到的結果」vs「假如另一個選擇」
- **方式**：ggplot2 with path diagram style

### 第二部分：研究設計思維

#### 3. DAG 視覺化 (新增/強化 ~Line 269-283)

- **目的**：用 R 動態畫出 DAG，而非只用 mermaid
- **內容**：Confounder / Mediator / Collider 三種結構
- **方式**：`ggdag` 套件
- **套件需求**：ggdag, dagitty

#### 4. 調整變數的效果 (新增於 ~Line 315 後)

- **目的**：展示「調整對 vs 調整錯」的差異
- **內容**：模擬資料顯示調整 confounder vs mediator 的估計差異
- **方式**：ggplot2 point estimates with CI

### 第三部分：方法概念

#### 5. PS 計算過程視覺化 (新增於 ~Line 369 前)

- **目的**：顯示 PS 是怎麼算出來的
- **內容**：從共變量 → logistic model → PS 值的流程
- **方式**：ggplot2 scatter + fitted curve

#### 6. IPW 權重視覺化 (新增於 ~Line 446 後)

- **目的**：顯示為什麼極端權重危險
- **內容**：權重分布 histogram + 極端值標註
- **方式**：ggplot2 histogram with annotations

#### 7. 雙重穩健概念圖 (新增於 ~Line 465 後)

- **目的**：視覺化「兩個模型、錯一個也 OK」
- **內容**：2x2 情境：PS對/錯 × Outcome對/錯
- **方式**：ggplot2 tile plot or custom diagram

### 第五部分：資料準備

#### 8. 重疊檢查：好 vs 壞 對比 (強化 ~Line 755-768)

- **目的**：讓學員一眼看出什麼是「好的重疊」
- **內容**：並排顯示兩種情境
- **方式**：ggplot2 density + facet_wrap

### 第六部分：R 實作

#### 9. 完整分析流程圖 (新增於 ~Line 820 後)

- **目的**：用一個模擬資料走完整個流程
- **內容**：
  - Step 1: 原始資料（不平衡）
  - Step 2: 計算 PS
  - Step 3: 檢查重疊
  - Step 4: 加權後平衡
  - Step 5: 估計效果
- **方式**：多個 ggplot2 plots，用 incremental fragments 顯示

---

## 技術規格

### 一致的風格設定

```r
# 每個 chunk 開頭
library(ggplot2)
library(showtext)
font_add("openhuninn", "jf-openhuninn-2.1.ttf")
showtext_auto()

# 色盤
colors <- list(
  treatment = "#E69F00",
  control = "#56B4E9",
  robust = "#2E86AB",
  fragile = "#E94F37",
  accent = "#3d6869"
)

# 統一 theme
theme_causal <- function() {
  theme_minimal(base_size = 16, base_family = "openhuninn") +
  theme(legend.position = "top")
}
```

### 需要新增的套件

- `ggdag` - DAG 視覺化
- `dagitty` - DAG 結構定義
- `patchwork` - 多圖並排（可選）

---

## 實作順序（全部 9 個）

### 第一批：概念理解

1. 混淆效應視覺化（Simpson's Paradox 風格）
2. 反事實概念圖
3. DAG 視覺化（使用 ggdag 套件）

### 第二批：設計與方法

4. 調整變數的效果比較
5. PS 計算過程視覺化
6. IPW 權重危險性視覺化
7. 雙重穩健概念圖

### 第三批：實作流程

8. 重疊檢查：好 vs 壞 對比
9. 完整分析流程圖（5 步驟）

---

## 修改的檔案

- `/Users/htlin/causal-tut/index.qmd` - 主要修改

## 驗證方式

1. `quarto preview index.qmd` 確認所有圖都能 render
2. 檢查中文字體是否正確顯示
3. 確認圖表大小在投影片上適當
