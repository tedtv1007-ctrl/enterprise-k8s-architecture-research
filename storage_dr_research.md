# 企業級 K8S 存儲級容災 (Storage-level DR) 研究報告

## 1. Longhorn Remote Backup 技術原理
本研究深入分析了 Longhorn 的 Block-level 增量同步機制：
*   **分塊機制**：磁碟數據被劃分為 2 MB 的 Chunk，備份時僅比對並上傳有變動的 Chunk 至 S3 儲存桶。
*   **數據去重**：透過 Checksum 識別重複數據塊，優化跨版本備份的儲存空間佔用。

## 2. 冷備份 (Cold Standby) 與 5 分鐘激活 (Activation)
實作了 Longhorn Disaster Recovery (DR) Volume 的容災設計：
*   **增量還原**：第二叢集 (DR Cluster) 持續從 S3 遠端備份庫拉取數據並於背景執行還原。
*   **極速切換**：發生災難時，透過一鍵「Activate」指令，可在 5 分鐘內將唯讀卷轉為可讀寫狀態並供應用程式掛載。

## 3. Recurring Job 自動化排程
提供了一套標準的排程範本：
*   **每小時快照**：保留最近 24 份本地快照供快速回滾。
*   **每六小時遠端備份**：自動將數據同步至異地 S3 桶，確保地理級數據安全。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Storage & DR Specialist
