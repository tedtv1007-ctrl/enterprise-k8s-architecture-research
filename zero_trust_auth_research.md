# K8S 命名空間層級零信任隔離與 API 分級授權研究報告

## 1. L7 精細化授權實作 (AuthorizationPolicy)
本研究利用 Istio 的應用層控制能力，實作了「最小權限原則」的存取控制：
*   **動作級別鎖定**：區分「公開讀取 (GET)」與「管理寫入 (POST/DELETE)」，僅允許具備特定 Service Account 的請求執行敏感操作。
*   **路徑過濾**：精確定義可存取的 API 端點，防止未經授權的路徑暴露。

## 2. 服務發現隔離 (Sidecar Egress Control)
*   **防止內部偵察**：利用 Istio `Sidecar` 資源實作 Egress 隔離，限制各命名空間的服務發現範圍。
*   **安全邊界**：確保 `enterprise-apps` 中的 Pod 僅能「看見」其依賴的資料庫（Postgres/Redis），無法探測 `enterprise-infra` 中的管理工具，有效遏止攻擊者在攻破單一節點後的橫向移動。

## 3. JWT 身份驗證整合 (RequestAuthentication)
*   **強制身份檢核**：實作 `RequestAuthentication` 對接 Keycloak OIDC，自動驗證所有進入叢集請求的 JWT Token 合法性（簽章、有效期）。
*   **無 Token 阻斷**：結合 AuthorizationPolicy 實施「No JWT, No Entry」鐵律，確保應用程式層級的安全性。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Zero-Trust Specialist
