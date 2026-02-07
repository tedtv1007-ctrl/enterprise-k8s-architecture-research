# K8S 智慧維運與事件自動化響應 (AIOps) 研究報告

## 1. 叢集事件智慧路由 (Robusta.dev)
針對 `OOMKilled` 或 `NodeNotReady` 等叢集異常，本研究採用 Robusta.dev 實作自動化響應機制：
*   **富化分析**：告警推送至 Mattermost 時，自動附帶發生故障 Pod 的最後 20 行日誌與資源使用圖表，減少手動排查時間。
*   **自動化 Playbooks**：支援偵測到特定錯誤時自動執行診斷指令，並將結果打包回傳。

## 2. 互動式維運整合 (Botkube)
*   **通訊即終端**：實作 **Botkube** 整合，讓運維人員可以直接在 Mattermost 頻道中透過 Slash Commands（如 `/botkube describe pod`）執行 kubectl 操作。
*   **協作效率**：團隊成員可即時在討論串中共同查閱排查結果，實現無縫的 ChatOps 協作。

## 3. AI 錯誤診斷與修復建議 (K8sgpt)
*   **白話診斷**：整合 **K8sgpt** 搭配大型語言模型 (LLM)，將艱澀的 K8S 錯誤代碼轉化為白話的故障成因分析。
*   **修復建議**：AI 會針對偵測到的配置偏移或行為異常，自動提供具體的修復指令，大幅降低初級運維人員的排錯門檻。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S AIOps Specialist
