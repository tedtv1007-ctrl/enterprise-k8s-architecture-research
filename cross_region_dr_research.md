# 企業級 K8S 異地容災 (Cross-Region DR) 研究報告

## 1. 跨叢集同步方案：Velero + S3 (MinIO)
本研究設計了基於物件儲存同步的備份架構：
*   **數據流轉**：利用 Velero 將 K8S 資源與 PV 資料備份至 MinIO，並透過 MinIO 的 **Bucket Replication** 實現跨區域 (Region) 的數據實時同步。
*   **備份深度**：針對有狀態服務提供 Restic (檔案級) 與 CSI Snapshot (快照級) 雙重備份建議，確保數據一致性。

## 2. 「兩地三中心」災難復原 SOP
定義了標準的叢集切換流程，縮短 RTO (復原時間目標)：
1.  **偵測與決策**：由第三方仲裁點 (Site C) 確認生產中心故障。
2.  **存儲掛載**：將災備中心 (Site B) 的儲存桶切換為可讀寫。
3.  **資源還原**：執行 Velero Restore 命令重建所有應用環境。
4.  **入口切換**：更新 Ingress DNS 並進行冒煙測試。

## 3. GSLB 自動流量切換機制
*   **推薦工具**：建議使用 **K8gb** (雲原生 GSLB) 或 Cloudflare Load Balancer。
*   **自動化邏輯**：透過 L7 健康檢查自動感測叢集狀態，當生產中心失效時，自動將全域 DNS 解析指向災備中心 VIP。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S DR Specialist
