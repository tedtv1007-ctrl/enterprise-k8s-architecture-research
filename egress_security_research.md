# 企業級 K8S Egress 安全連線控管研究報告 (金融級 DLP)

## 1. 技術方案對比：Cilium vs. Istio
本研究針對金融業對外連線的嚴格管控需求，分析了兩大主流方案：
*   **Cilium FQDN (推薦)**：基於 eBPF 技術，效能極高且對應用程式透明。能直接在 CNI 層級實施網域白名單過濾。
*   **Istio Egress Gateway**：適合需要集中化出口 IP（對接實體防火牆）與進階 L7 (mTLS) 檢測的場景。

## 2. FQDN 白名單實作範例
實作了基於 **CiliumNetworkPolicy** 的過濾規則：
*   **Default Deny**：封鎖所有未授權的對外訪問。
*   **精準開放**：僅允許存取 `api.notion.com` 與 `graph.microsoft.com`。
*   **DNS 安全**：同時配置了對內部 DNS 服務的授權，確保網域解析功能正常且受控。

## 3. 稽核日誌與 ELK Stack 整合
針對 DLP 稽核需求，設計了完整的自動化監控鏈：
1.  **攔截捕捉**：利用 **Hubble** 監控 `dropped` 封包事件。
2.  **數據流轉**：透過 Fluent-bit 收集並標註來源 Pod 與目標網域。
3.  **ELK 視覺化**：在 Kibana 上建立「非法連線攔截排行榜」，並設定即時告警機制。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security & DLP Specialist
