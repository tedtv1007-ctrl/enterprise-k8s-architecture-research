# 企業級 PostgreSQL 與 Redis 在 K8S 上的高可用實作研究報告

## 1. PostgreSQL 高可用方案：CloudNativePG (CNPG)
本研究推薦採用 **CloudNativePG** 作為企業級資料庫運算子：
*   **優勢**：完全雲原生設計，利用 K8S 控制循環管理選主與狀態，不依賴外部複雜組件。
*   **災備能力**：原生整合 Barman 技術，支援將 WAL 日誌即時串流至 S3 儲存桶，實作點對點恢復 (PITR)。
*   **服務切換**：自動產出 `-rw` (讀寫) 與 `-ro` (唯讀) Service，確保故障轉移時應用程式連線不中斷。

## 2. Redis 高可用佈署：Sentinel 模式
針對 Mattermost 與 .NET Apps 的快取需求，採用 **Redis Sentinel** 架構：
*   **架構**：1 主 + 2 從 + 3 哨兵 (Sentinel)，確保在主節點故障時秒級完成切換。
*   **連線優化**：Mattermost 與 .NET StackExchange.Redis 均原生支援 Sentinel 協議，可實現自動服務發現。

## 3. 結合 Longhorn 實作資料庫異地副本
*   **三副本冗餘**：配置 `numberOfReplicas: 3` 並實施跨 AZ 反親和性，確保物理節點損毀時資料不遺失。
*   **DR Volume 機制**：利用 Longhorn 的 **Disaster Recovery Volume** 監測異地 S3 備份，實作跨叢集增量同步，達成 RTO < 5 分鐘、RPO < 15 分鐘的企業級災備指標。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Database HA Specialist
