# 企業級 K8S 多區域流量管理與 Cloudflare 整合研究報告

## 1. 跨區域流量調度 (Cloudflare GSLB)
本研究實作了地理級別的負載平衡與故障轉移機制：
*   **健康監控**：透過 Cloudflare Monitors 即時探測「新加坡」與「東京」兩地叢集的存活狀態。
*   **智能路由**：利用 Steering Policies 實現延遲最低的存取路徑，並配置主備優先級 (Failover)，確保主區域失效時流量能自動導向備援中心。

## 2. 邊緣安全接入 (Cloudflare Tunnel)
*   **隱藏來源 IP**：實作 `cloudflared` Outbound-only 連線模式，K8S 叢集無需開啟外部 Inbound 埠位即可提供服務，有效防止直接 DDoS 攻擊。
*   **邊緣防護**：將流量收攏至 Cloudflare 邊緣節點，原生整合 WAF 與 DDoS 清洗能力。

## 3. K8S 部署實務
*   提供了高可用架構的 **Cloudflare Tunnel Deployment YAML** 範本，包含雙副本冗餘與 Liveness Probe 配置，現已整合至專案 `manifests/scripts/` 中。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S GTM & Edge Security Specialist
