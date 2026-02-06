# 企業級 K8S 安全稽核與自動化合規掃描研究報告

## 1. K8S 稽核日誌 (Audit Logs) 與 ELK 整合
針對金融業對行為追蹤的嚴格要求，本研究實作了精細化的稽核策略：
*   **策略定義**：設計了專門監控敏感資源（如 Secret、ConfigMap）讀寫行為的 `Audit Policy`。
*   **行為分析**：透過 Filebeat 將 API Server 的稽核日誌即時送往 ELK Stack，在 Kibana 上建立「特權行為監控看板」，可偵測非預期的資源存取。

## 2. CIS Benchmark 自動化檢核 (kube-bench)
*   **持續合規**：實作將 `kube-bench` 封裝為 K8S CronJob，定期針對控制平面與工作節點進行安全掃描。
*   **修復指引**：自動產出對標 CIS 標準的修復建議 (Remediations)，確保叢集配置不隨時間而產生安全偏移 (Configuration Drift)。

## 3. 即時入侵偵測 (Falco)
*   **執行期防護**：部署基於 eBPF 技術的 **Falco**，監控容器內部的異常系統調用。
*   **告警規則**：預設配置偵測「敏感目錄讀取」、「異常外連連線」及「容器內執行 Shell」等可疑行為，並透過 Falcosidekick 整合至 Mattermost 告警。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security Audit Specialist
