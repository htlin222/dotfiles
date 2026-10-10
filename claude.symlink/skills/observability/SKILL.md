---
name: observability
description: 讓程式在正式機上「看得見」—— 先寫下 on-call 會問的問題，再選對訊號（log / metric / trace），最後對症狀而非成因告警。Use when shipping a feature to production, adding an endpoint, background job, retry, queue, or external integration, when an incident took too long to diagnose, or when setting up alerts. NOT for debugging a failure happening right now.
argument-hint: "[要加上觀測的功能或服務]"
---

# /observability — 看不見的程式就是不能維運的程式

Instrumentation 不是上線後的附加品，它跟測試一樣是**跟功能一起寫**的。
功能沒有 telemetry 就上線，第一個使用者回報的 bug 就會變成考古工作。

---

## 什麼時候用

- 要上正式機的功能、新的 endpoint、背景工作、外部整合
- 出過一次「事後查不出發生什麼事」的意外
- 在 review 一個含 retry / queue / 跨服務呼叫的 PR
- 在設定或檢討告警規則

### 不要用在

| 情境 | 該用什麼 |
| --- | --- |
| **現在**正在爆的問題 | 先除錯（這支是讓下一次除錯變快的投資） |
| 已量測到的效能問題 | 效能分析與最佳化 |
| 上線當天的監看清單 | 發版流程；這支負責的是餵給它的資料 |

---

## Step 1 — 先定義「正常」，再開始埋

沒有問題的 telemetry 就是雜訊。埋之前先寫下 on-call 會問的 2–4 個問題：

```
功能：結帳付款重試
ON-CALL 會問：
1. 第一次就成功 vs 重試後成功的比例是多少？
2. 永久失敗時，原因是什麼？（provider 錯誤？逾時？驗證失敗？）
3. 金流商今天是不是比平常慢？
→ 底下每一個訊號都必須回答其中一題。
```

⚠️ 寫不出這幾個問題，代表還沒準備好埋 —— 你會什麼都 log，然後什麼都不知道。

## Step 2 — 一個問題配一種訊號

| 訊號 | 回答什麼 | 成本 | 例子 |
| --- | --- | --- | --- |
| **結構化 log** | 「這一筆到底發生什麼事？」 | 隨流量線性成長 | `payment_failed` 帶 provider 錯誤碼 |
| **metric** | 「總體上多常、多快？」 | 每個 series 固定，查詢便宜 | provider 呼叫的 p99 延遲 |
| **trace** | 「時間花在跨服務的哪一段？」 | 每請求，通常取樣 | 一筆慢結帳的逐段拆解 |

口訣：**metric 告訴你「出事了」，trace 告訴你「在哪」，log 告訴你「為什麼」。**

## Step 3 — 結構化 log

記**事件**，不要記散文。每一行是一個 JSON 物件，事件名稱要穩定：

```typescript
// ✗ 字串內插 —— 查不了、格式不一致
logger.info(`Payment ${id} failed for user ${userId} after ${n} retries`);

// ✓ 穩定的事件名 + 機器可讀欄位
logger.warn({ event: 'payment_failed', paymentId: id, provider: 'stripe',
              errorCode: err.code, attempt: n }, 'payment failed');
```

| 等級 | 意思 | on-call 該做什麼 |
| --- | --- | --- |
| `error` | 不變量被打破，可能需要有人處理 | 調查 |
| `warn` | 降級但已處理（重試成功、走了 fallback） | 看趨勢 |
| `info` | 有意義的業務事件（訂單成立、工作完成） | 不用做事 |
| `debug` | 診斷細節 | 正式機預設關閉 |

**correlation ID 是必要的，不是加分項。** 在系統邊界產生（或接受）一個 request ID，
掛到每一行 log、每個 span、每個對外呼叫上。沒有它，你無法從交錯的 log 裡還原一筆請求。

```typescript
app.use((req, res, next) => {
  req.id = req.headers['x-request-id'] ?? crypto.randomUUID();
  req.log = logger.child({ requestId: req.id });
  res.setHeader('x-request-id', req.id);
  next();
});
```

⚠️ **絕不記錄 secret、token、密碼、完整 PII。** telemetry pipeline 是典型的資料外洩路徑。
用欄位白名單，不要整包 request body 丟進去。

## Step 4 — Metrics

請求型服務：每個 endpoint、每個外部相依都量 **RED** ——
**R**ate（每秒請求）、**E**rrors（失敗率）、**D**uration（延遲**直方圖**，不是平均）。
資源型（queue、connection pool、機器）用 **USE** —— Utilization、Saturation、Errors。

```typescript
const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  labelNames: ['method', 'route', 'status_class'],   // '2xx'，不是 '200'
  buckets: [0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
});
```

**cardinality 是這裡唯一會炸的東西。** 每一組 label 組合都是一條獨立時間序列。
label 只能來自小而固定的集合。

```
可以當 label：route="/api/tasks/:id"  status_class="5xx"  provider="stripe"
絕不能當 label：user_id、email、request_id、完整 URL、錯誤訊息原文
```

高基數的東西屬於 log 和 trace，不屬於 metric。
**永遠不看平均，永遠看分位數** —— 平均會藏住那 1% 過得很慘的使用者。

## Step 5 — Tracing

用 OpenTelemetry（廠商中立，auto-instrumentation 幾乎零程式碼就涵蓋 HTTP / gRPC / 常見 DB client）。
手動 span 只加在有意義的內部工作單元上（`applyDiscounts`、`chargeProvider`），
並掛上 on-call 會拿來篩選的屬性。

⚠️ **每個非同步邊界都要傳遞 context** —— HTTP header、queue message metadata。
漏一個，trace 就在那裡斷掉。預設用低比例 head-based 取樣；後端支援的話錯誤留 100%。

## Step 6 — 告警：對症狀，不對成因

```
症狀（值得叫醒人）              成因（放 dashboard，不要叫人）
錯誤率 > 1% 持續 5 分鐘          CPU 85%
p99 延遲 > 2s                    某個 pod 重啟過
queue 積壓 > 10 分鐘             磁碟 70%
```

成因型告警會在沒事的時候響，然後在你沒預料到的失效模式上完全沉默。

每一條告警的規矩：

1. **必須可行動。** 如果反應是「不用理它，會自己好」，就刪掉這條告警。
2. **必須連到 runbook** —— 三行也行：這代表什麼、第一個要跑的查詢、往上找誰。
3. **閾值與持續時間要有依據** —— 來自 SLO 或歷史資料，不是拍腦袋。
4. **只用兩級**：page（使用者正在痛，現在處理）、ticket（降級，這週處理）。
   第三級一定會變成雜訊，然後訓練所有人忽略全部。

## Step 7 — 驗證 telemetry 本身

instrumentation 也是程式碼，也會寫錯。收工前實際觸發一次：

- 在測試機刻意觸發錯誤 → 用 `requestId` 撈得到，欄位是結構化的（不是 `[object Object]`）
- 打一些測試流量 → metric series 出現、label 正確、數值合理
- 在 tracing UI 裡追一筆請求走完全程 → 沒有斷掉的 span
- 每條新告警實際觸發一次（暫時調低閾值）→ 通知有進到正確的頻道，runbook 連結打得開

---

## 常見的自我開脫

| 你會這樣想 | 事實 |
| --- | --- |
| 「先做好功能，log 之後補」 | 「之後」會變成「第一次出事之後」，那是最貴的時間點。 |
| 「log 越多觀測性越好」 | 沒結構的雜訊只會讓事故變慢。三個查得到的事件贏過三百行散文。 |
| 「先用 console.log 就好」 | 沒結構就篩不了、關聯不了、告警不了。換成結構化 logger 只花五分鐘，一次。 |
| 「出事再看 dashboard 就好」 | 沒有先定義問題就做的 dashboard，什麼都有，就是沒有答案。 |
| 「重要的都先告警，之後再調」 | 會吵的 pager 會訓練人忽略它。調整永遠不會發生，漏掉的那次真的會。 |
| 「user_id 當 label 比較好 debug」 | 也會讓 metric 後端倒掉。高基數查詢屬於 log 和 trace。 |
| 「才兩個服務，tracing 太over」 | 兩個服務就已經有 log 回答不了的跨服務延遲問題了。auto-instrumentation 成本趨近於零。 |

## 紅旗

- 一個含 retry / queue / 外部呼叫的 PR，零新增 telemetry
- log 用字串內插組出來，不是結構化欄位
- 沒有 correlation ID，每行 log 都是孤兒
- metric 的 label 是 user ID、完整 URL 或錯誤訊息原文（cardinality 炸彈）
- 延遲只有平均值，沒有分位數
- 每天都響、每次都是「已讀」然後沒有任何動作的告警
- 對 CPU / 記憶體告警叫醒人，但使用者面的錯誤率沒人監控
- log 裡出現 secret、token 或完整 request body
- 一個正式機功能唯一的健康證據是「我機器上是好的」

## 驗收

- [ ] on-call 會問的問題有寫下來，每個訊號都對應到其中一題
- [ ] 所有 log 都是結構化的，事件名穩定，每行都有 correlation ID
- [ ] 實際抽查過輸出，沒有 secret / token / 未遮蔽 PII
- [ ] 每個新 endpoint 與外部相依都有 RED metric，label 集合有界
- [ ] 延遲是直方圖，p95/p99 查得到
- [ ] 一筆請求可以在 tracing UI 裡端到端追完，沒有斷 span
- [ ] 每條新告警都是症狀型、有 runbook 連結、實際觸發過一次
- [ ] 在測試機刻意製造的失敗，**只靠 telemetry** 就定位得到，不用讀原始碼
