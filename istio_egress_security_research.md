# Istio Egress Gateway 精細化管控與可視化研究報告

## 1. L7 流量精細化過濾 (L7 Traffic Control)
針對金融業對 API 存取的嚴格限制，本研究實作了基於路徑的過濾機制：
*   **白名單機制**：透過 `ServiceEntry` 與 `VirtualService` 定義外部服務。
*   **路徑限制**：實作僅允許特定 API 路徑（例如：`google.com/api/v1/*`）的連線，並自動阻斷其餘所有未授權的 HTTP 請求。

## 2. Egress 可視化與 ELK 整合
*   **結構化日誌**：配置 Envoy 產生 JSON 格式的訪問日誌 (Access Logs)，包含 Trace ID、目標網域、HTTP 狀態碼及路徑資訊。
*   **監控看板**：設計了對接到 ELK Stack 的資料流，讓運維人員能在 Kibana 上即時監控所有出站流量的合規性與效能。

## 3. Sidecar 注入安全性控制
*   **防止注入攻擊**：建議結合 **OPA Gatekeeper** 實施 Namespace 標籤白名單，確保僅有授權的區域可以自動注入 Istio Sidecar 代理。
*   **攻擊面縮減**：利用 `Sidecar` 資源限制各 Pod 的服務發現範圍，防止內部橫向掃描。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Service Mesh Specialist
