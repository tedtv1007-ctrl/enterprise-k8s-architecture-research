# 企業級 K8S 日誌行為分析與 AI 輔助稽核研究報告

## 1. ELK Machine Learning 異常偵測機制
針對 API Server 的稽核日誌 (Audit Logs)，本研究實作了基於行為基準線的監控方案：
*   **深夜異常存取**：利用 ELK 的 `high_count` 偵測器監控 `get secrets` 行為。AI 會自動學習日夜週期，當凌晨 3 點突然出現非典型的 ServiceAccount 存取活動時，系統將自動調高其「異常分數 (Anomaly Score)」並發起告警。
*   **高風險行為識別**：採用 `rare` 偵測器監控罕見的 RBAC 變更或 Pod 刪除行為，主動捕捉潛在的內鬼或駭客入侵跡象。

## 2. AI 模型日誌分類與雜訊過濾
*   **語義分類**：探討利用 LogBERT 或微調後的 Llama 模型進行日誌嚴重等級分類，能自動分辨網路抖動（低嚴重）與資料庫崩潰（高嚴重）的語義差異。
*   **告警降噪**：透過日誌群集化 (Clustering) 技術識別「Noise」標籤（如心跳包、Probe 日誌），在網關或收集端自動過濾雜訊，防止運維人員產生「告警疲勞」。

## 3. 資安主管稽核看板 (Executive Dashboard)
設計了從高層級指標向下鑽取 (Drill-down) 的視覺化方案：
*   **核心 KPI**：包含「高風險 API 呼叫趨勢」、「特權帳號使用分布」及「Secret 存取熱點圖」。
*   **即時風險分數**：看板左上角以信號燈呈現叢集當前安全健康分，由 ML 異常得分與未修補漏洞數量加權計算。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S AIOps & Security Audit Specialist
