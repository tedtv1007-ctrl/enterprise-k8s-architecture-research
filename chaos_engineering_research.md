# 企業級 K8S 混沌工程 (Chaos Engineering) 實施方案研究報告

## 1. 故障模擬策略 (Chaos Mesh)
本研究實作了針對核心組件的自動化故障注入計畫，旨在驗證系統的自癒與容錯能力：
*   **Pod Chaos (自癒驗證)**：隨機殺除 `enterprise-apps` 命名空間中的 Pod，測試 K8S Deployment 的即時重建速度。
*   **Network Chaos (不穩定性模擬)**：在應用層到資料層 (Postgres/Redis) 之間注入 200ms-500ms 延遲，驗證分散式系統的超時 (Timeout) 與重試機制。
*   **HTTP Chaos (斷路器驗證)**：針對 .NET Core API 注入 500 錯誤，測試應用層的斷路器 (Circuit Breaker) 是否能優雅降級。

## 2. 韌性判斷與觀測 (Observability)
*   **指標連動**：結合 Prometheus 與 Grafana，監控實驗期間的 **可用性 (probe_success)** 與 **P99 延遲** 偏移量。
*   **穩態標準**：定義系統在受到干擾後，應於 30 秒內自動恢復至原始性能水位。

## 3. 實驗 YAML 範本
(包含 PodKill、Network Delay 與 HTTP Fault Injection 的完整配置範例，已整合至專案目錄)

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Resilience & Chaos Specialist
