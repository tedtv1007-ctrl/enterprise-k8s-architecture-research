# K8S 永續儲存安全：Longhorn 加密與備份安全性硬化研究報告

## 1. 永續儲存靜態加密 (Encryption at Rest)
針對資料庫與敏感文件的存儲安全，本研究實作了 Longhorn 的磁碟加密方案：
*   **加密實作**：利用 Linux 核心的 `dm-crypt` (LUKS) 模組實作磁碟區層級的加密。
*   **金鑰管理**：透過 K8S Secret 儲存加密密鑰，並配置專屬的 `StorageClass` 自動執行加解密動作。
*   **Vault 整合**：建議搭配 **External Secrets Operator (ESO)** 將 HashiCorp Vault 中的金鑰同步至叢集，確保密鑰生命週期管理的安全性。

## 2. 備份存儲安全硬化 (S3 Security)
為了防範勒索軟體與惡意刪除，設計了三層防禦體系：
*   **不可竄改性 (WORM)**：實施 **S3 Object Lock (Compliance Mode)**，確保備份物件在預設保留期內任何人都無法修改或刪除。
*   **最小權限原則**：採用 **IAM Roles for Service Accounts (IRSA)** 取代靜態金鑰，並在 Bucket Policy 中顯式拒絕非 MFA 的刪除請求。
*   **數據隔離 (Air-gapping)**：建議將備份桶建立在獨立的資安帳號下，並僅限透過 **VPC Endpoint** 進行內部訪問，達成網路層級的物理隔離。

## 3. 勒索軟體防禦清單
*   啟用 S3 版本控制 (Versioning)。
*   實作 **MFA Delete** 強制檢核。
*   配置 **Amazon GuardDuty** 實施 S3 異常存取偵測。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Storage & Database Security Specialist
