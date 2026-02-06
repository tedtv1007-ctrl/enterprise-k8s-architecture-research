# 企業級 K8S 安全硬化與 OPA Gatekeeper 策略管理研究報告

## 1. Pod Security Standards (PSS) 准入控制
本研究實作了 K8S 原生的安全防禦機制：
*   **Baseline 級別**：預設套用於所有應用命名空間，防止常見的特權提升攻擊。
*   **Restricted 級別**：針對高敏感服務（如資料庫），實施最嚴格的安全策略，包含強制非 Root 執行及限制 Capabilities。

## 2. OPA Gatekeeper 企業鐵律強制執行
透過 **Rego 語言** 定義了自動化檢核規範，確保維運合規：
*   **Image 來源鎖定**：強制所有容器映像檔必須來自 `harbor.enterprise.com` 私有庫，封鎖外部不明來源。
*   **資源限制強制化**：自動攔截未設定 `Resources Limit` 的佈署請求，防止開發者程式造成叢集崩潰。

## 3. 核心層級防護 (Kernel Security)
*   **Seccomp**：全叢集啟用 `RuntimeDefault` 設定，過濾危險的系統調用 (syscall)。
*   **AppArmor**：為關鍵服務加載自定義 Profile，實施檔案系統與網路存取的核心級過濾。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security & Admission Specialist
