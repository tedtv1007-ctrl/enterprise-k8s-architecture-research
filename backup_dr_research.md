# 企業級 K8S 數據安全：Velero 整合 Longhorn 備份與災難復原研究報告

## 1. 備份技術架構 (CSI Snapshot)
本研究實作了基於 Velero CSI Plugin 與 Longhorn 的快照備份機制，確保 PostgreSQL、Mattermost 等服務具備數據一致性。

## 2. 自動化備份排程 (Schedule)
實作了每日自動執行的備份配置，並定義了 30 天的保留期限 (TTL)：
*   **命名空間範圍**：包含 `enterprise-apps` (應用)、`enterprise-data` (資料庫)、`enterprise-infra` (監控)。
*   **執行週期**：每日凌晨 01:00 自動觸發快照與 YAML 資源備份。

## 3. 災難復原流程 (DR SOP)
針對「Namespace 誤刪」等極端情境，定義了標準還原流程：
1.  **資源重建**：優先恢復 K8S 配置與 Secrets。
2.  **數據綁定**：透過 Longhorn 快照自動重建 PVC。
3.  **掛載啟動**：Pod 自動掛載恢復後的持久化捲並重啟服務。

## 4. 實作範本 (YAML)
(詳細 Velero Schedule YAML 已整合至 `manifests/base/velero-schedules.yaml`)

---
產出時間: 2026-02-06
研究員: OpenClaw K8S DR Specialist
