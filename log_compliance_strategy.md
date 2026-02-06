# 企業級 ELK 日誌合規與 PII 清洗研究報告

## 1. PII 敏感資料清洗 (Logstash)
針對保險業對個資保護的嚴格要求，本研究實作了 Logstash 的自動過濾規則：
*   **身分證字號**：自動辨識並遮蔽中段字元，僅保留首碼與末三碼。
*   **聯絡資訊**：對 Email 帳號與手機號碼中間段進行 Regex 掩碼處理。
*   **實作位置**：配置於 Logstash Filter 階段，確保進入 Elasticsearch 的資料已完成去識別化。

## 2. 180 天日誌留存策略 (ILM)
實作了 Elasticsearch Index Lifecycle Management (ILM) 分層儲存架構：
*   **Hot Phase (0-7天)**：高效能 SSD 儲存，供即時查詢與寫入。
*   **Warm Phase (8-30天)**：減少分片數量並切換至一般磁碟，維持查詢能力但降低成本。
*   **Cold Phase (31-180天)**：執行 Force Merge 並轉移至冷儲存，180 天後自動刪除。

## 3. 日誌不可變性 (Immutability)
*   採用 **Data Streams** 模式強制執行 Append-only 寫入，禁止修改既有日誌。
*   配合 K8S RBAC 權限，確保僅限稽核帳號具備快照訪問權限。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Log Compliance Specialist
