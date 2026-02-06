# 企業級 K8S 叢集擴展性與高可用研究報告

## 1. Cluster Autoscaler (CA) 自動縮放機制
本研究釐清了 CA 的觸發核心：
*   **觸發條件**：CA 並非監控 CPU 使用率，而是監控處於 `Pending` 狀態的 Pod。
*   **關鍵配置**：企業應用必須精確設定 `resources.requests`，當資源請求總和超過節點負載導致 Pod 無法排程時，CA 才會觸發雲端平台增減節點。

## 2. .NET Core 自定義指標 HPA (Horizontal Pod Autoscaler)
針對保險業常見的高頻 API 請求，設計了基於 QPS 的自動擴展方案：
*   **指標來源**：整合 `prometheus-net` 並透過 Prometheus Adapter 轉換為 K8S 自定義指標。
*   **擴展策略**：提供 YAML 範本，可設定當單一 Pod 達 500 QPS 時自動擴增副本，比傳統 CPU 負載更精準。

## 3. 跨可用區 (Multi-AZ) 地理級高可用
*   **拓撲分佈**：推薦使用 **`Topology Spread Constraints`** 取代傳統的 Anti-Affinity。
*   **容災能力**：確保 Pod 均勻分佈於不同 Availability Zones，即使單一數據中心故障，服務仍能維持運作。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Automation & HA Specialist
