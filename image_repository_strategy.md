# 企業級映像檔 Repository (Harbor) 管理與安全性策略研究

## 1. Harbor 專案劃分與晉級 (Promotion) 規範
為了確保生產環境的穩定與安全，採用分層式的映像檔存放架構。

### 1.1 專案層級定義
*   **`library`**：存放經資安加固的基礎映像檔（如 .NET Runtime, Alpine），僅限架構師推送。
*   **`dev`**：開發測試區，允許不穩定版本，頻繁更新。
*   **`staging`**：預發佈區，存放已通過 Trivy 漏洞掃描與單元測試的映像檔。
*   **`release` (Prod)**：生產區，僅存放具備 **Cosign 數位簽章**且通過 QA 驗證的最終版本。

### 1.2 晉級規則
*   映像檔從 `dev` 晉級至 `release` 必須經過自動化 Pipeline 的重新標記 (Re-tag) 與資安檢核，嚴禁直接將 `dev` 映像檔推向生產環境。

## 2. 映像檔命名與標籤策略 (Tagging)
*   **格式**：`{環境}-{語意化版本}-{Git_SHA}` (例如：`rc-1.2.0-a1b2c3d`)。
*   **不可變性**：生產環境嚴禁使用 `latest` 標籤，確保佈署版本的唯一性與可溯源性。

## 3. Image Pull Secret 自動派發機制
*   **推薦方案**：使用 **Kyverno ClusterPolicy**。
*   **實作方式**：當新的 Namespace 建立時，Kyverno 會自動將全域的 Harbor 認證金鑰同步至該命名空間，省去手動配置負擔並降低洩漏風險。

## 4. 保留政策 (Retention Policy)
*   **開發區 (`dev`)**：僅保留最近 10 個標籤或 7 天內有被抓取的映像檔。
*   **生產區 (`release`)**：永久保留符合 `v*` 規範的正式版本。
*   **垃圾回收**：建議每週執行一次 Harbor GC 以物理清理磁碟空間。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Supply Chain Security Specialist
