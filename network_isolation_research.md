# K8S 命名空間層級零信任隔離與進階 NetworkPolicy 研究報告

## 1. 核心安全策略 (Zero Trust)
本研究實作了「預設全封鎖，精準放行」的白名單網路隔離架構：
*   **Default Deny All**：在 `apps` 與 `data` 命名空間強制執行雙向（Ingress/Egress）流量封鎖，確保無授權通訊無法建立。
*   **資料層精準授權**：僅允許來自 `enterprise-apps` 的請求存取資料層的 5432 (PostgreSQL) 與 6379 (Redis) 連接埠。
*   **Ingress 存取限制**：限制 Ingress Controller 僅能訪問標記為 `exposed: "true"` 的指定服務，防止敏感內部介面外洩。

## 2. 服務自癒與可用性保障
*   **DNS 放行規則**：特別配置了對 `kube-system/kube-dns` 的 Egress 授權，確保在極端隔離環境下，服務發現 (Service Discovery) 功能仍能穩定運作。

## 3. 實作範本 (YAML)
(包含 Default Deny、Apps-to-Data 及 Ingress-Control 的完整配置範例，已整合至專案目錄)

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Network Security Specialist
