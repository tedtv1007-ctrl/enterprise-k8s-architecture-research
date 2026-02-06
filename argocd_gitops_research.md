# 企業級 ArgoCD GitOps 自動化部署架構研究

## 1. 架構模式：App-of-Apps
本研究採用 ArgoCD 的「App-of-Apps」設計模式，實現基礎設施與應用程式的層級化管理。

### 1.1 分層同步策略
*   **Infrastructure 層**：負責 Namespaces、StorageClasses (Longhorn) 等基礎環境。
*   **Database 層**：負責 PostgreSQL 與 Redis (隔離配置) 的生命週期。
*   **Application 層**：負責 Mattermost、Wiki.js 及 .NET Core Apps 的持續部署。

## 2. SecDevOps 流水線整合 (GitHub Actions)
實作了從「安全掃描」到「自動上版」的完整自動化流程：
1.  **安全阻斷**：透過 Trivy 掃描映像檔，若發現 `CRITICAL` 或 `HIGH` 漏洞則強制中止 CI 流程。
2.  **GitOps 觸發**：映像檔通過檢核並推送到私有鏡像庫後，自動更新 Git 倉庫中的 Image Tag。
3.  **自動同步**：ArgoCD 偵測到 Git 變更，立即將 K8S 叢集狀態更新至最新版本。

## 3. 實施清單
(詳細 ArgoCD Application YAML 與 GitHub Actions Workflow 定義已整合至專案目錄)

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Automation Specialist
