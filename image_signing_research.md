# 企業級 K8S 映像檔簽章與完整性驗證研究報告

## 1. 映像檔簽章機制 (Cosign)
針對容器安全供應鏈，本研究採用 Sigstore 社群的 **Cosign** 實作數位簽章流程：
*   **簽署原理**：在 CI 流水線末端利用 Cosign 為映像檔產生加密簽章，並連同映像檔一併推送至私有 Harbor 庫。
*   **金鑰加固**：推薦結合 **HashiCorp Vault (Transit Engine)** 或雲端 KMS 存放簽署私鑰，確保簽署過程中私鑰不落地，徹底防止身份冒用。

## 2. 強制准入驗證 (Kyverno)
*   **安全鐵律**：部署 **Kyverno** 並配置 `ClusterPolicy` 實施驗證策略。
*   **自動攔截**：當 K8S 偵測到任何部署請求中包含「未經有效簽章」的映像檔時，API Server 將直接拒絕該請求，防止惡意或未經測試的程式碼進入生產環境。

## 3. 合規性監控 (Policy Reporter)
*   **視覺化檢核**：整合 Policy Reporter 展示全叢集的政策執行報告，即時識別哪些應用程式正嘗試違反安全規範。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Supply Chain Security Specialist
