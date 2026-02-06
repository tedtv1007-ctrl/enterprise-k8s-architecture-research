# 企業級 K8S 多租戶資源配額與優先級管控研究報告

## 1. 資源配額策略 (ResourceQuota)
為防止單一命名空間耗盡叢集資源，本研究為核心 Namespace 設計了硬性配額限制：
*   **應用層 (`enterprise-apps`)**：側重於 Pod 數量的擴展性，配置 20Gi/40Gi 的 CPU/RAM 資源池。
*   **資料層 (`enterprise-data`)**：側重於記憶體與儲存空間，提供 500Gi 的 PVC 總額限制，確保資料庫有充足增長空間。

## 2. 預設限制與保護 (LimitRange)
實作了 `LimitRange` 規則，確保若開發者未手動設定 `resources`，Pod 將自動獲得合理的預設值（200m CPU / 512Mi RAM），並強制執行最大上限，避免出現惡意資源佔用的容器。

## 3. 關鍵服務優先權 (PriorityClass)
*   建立 **`enterprise-critical-data`** 高優先級標籤（權重 1,000,000）。
*   **生存保障**：將此標籤套用於 PostgreSQL 等核心資料庫。當叢集資源不足觸發 Eviction（驅逐）時，K8S 會確保優先保留具備此標籤的 Pod，而先犧牲低優先級的開發版應用。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Resource Management Specialist
