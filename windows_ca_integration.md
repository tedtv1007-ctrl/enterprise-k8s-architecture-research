# 企業 Windows CA (ADCS) 整合 K8S 證書自動化管理研究報告

## 1. 研究方案概述
針對企業內部 Windows Active Directory Certificate Services (ADCS) 的環境，本方案實作了基於 `cert-manager` 的自動化憑證生命週期管理。

### 1.1 核心組件
*   **adcs-issuer**：作為外部簽發器，負責處理 K8S 與 ADCS 之間的 Web Enrollment (支援 NTLM 驗證)。
*   **trust-manager**：負責將 Windows Root CA 憑證自動派發（Replicate）至全叢集所有命名空間的 Pod 中，確保內部 TLS 信任鏈完整。

## 2. 實作細節與配置範例
### 2.1 憑證簽發控制 (Issuer)
*   定義 `ClusterAdcsIssuer` 指向企業 CA 的 `/certsrv/` 路徑。
*   透過 K8S Secret 安全存取 AD 簽發帳號。

### 2.2 全叢集信任分發 (Trust Distribution)
*   利用 `Bundle` 資源定義 Windows Root CA 的來源與散佈目標。
*   Pod 僅需掛載自動產出的 ConfigMap 即可實現全叢集對內部憑證的信任。

## 3. Ingress 整合實務
*   **自動申請**：在 Ingress (APISIX/Nginx) 中加入 `cert-manager.io/cluster-issuer` 標記。
*   **模板對接**：支援透過 Annotation 指定 Windows CA 上的特定模板 (如 `EnterpriseWeb`)。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security & Identity Specialist
