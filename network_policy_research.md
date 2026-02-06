# 企業級 K8S 多租戶網路隔離政策研究 (Network Policy)

## 1. 核心安全策略 (Zero Trust)
本研究實作了基於「預設拒絕 (Default Deny)」的白名單流量控制架構。

### 1.1 流量存取規範
*   **資料層隔離 (Data Layer Isolation)**：`enterprise-data` 命名空間僅接受來自 `enterprise-apps` 的特定連接埠（Postgres: 5432, Redis: 6379）請求。
*   **應用層入站 (Ingress Control)**：`enterprise-apps` 僅允許 Ingress Controller 的存取，封鎖所有其他未經授權的跨 Namespace 流量。
*   **監控層防護 (Infra Isolation)**：ELK Stack 被限制為僅接收日誌數據流入，並嚴格管控其對外連線 (Egress)，防止內部數據洩漏。

## 2. 流量監控與合規審核
*   **可視化方案**：建議部署 **Cilium Hubble**，利用 eBPF 技術即時監控被 Network Policy 攔截的異常流量。
*   **策略強制執行**：利用 **OPA/Gatekeeper** 確保所有新建立的 Namespace 必須符合安全隔離標準。

## 3. 實作範本 (YAML)
(詳細 Network Policy YAML 定義已存於 `manifests/base/network-policies.yaml`)

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security Specialist
