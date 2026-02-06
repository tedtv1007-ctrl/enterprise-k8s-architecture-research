# 企業級 K8S 敏感資訊管理 (Secrets Management) 加固研究報告

## 1. HashiCorp Vault 整合方案
本研究實作了基於 **Vault Agent Sidecar** 的金鑰注入機制，大幅提升金鑰安全性：
*   **注入原理**：利用 Mutating Admission Webhook 在 Pod 啟動時自動掛載 Sidecar。
*   **動態存取**：金鑰將以檔案形式 (tmpfs) 映射至 Pod 的 `/vault/secrets/`，應用程式無需改動程式碼即可讀取。
*   **權限管控**：結合 K8S Service Account 與 Vault Role，實作更細粒度的存取權限控制。

## 2. K8S 原生加密硬化 (Encryption at Rest)
*   **KMS 整合**：研究配置 `EncryptionConfiguration` 對接雲端 KMS (AWS/Azure)，確保 etcd 內的 Secret 數據在物理磁碟上是非明文存儲。
*   **靜態保護**：即使 etcd 備份外洩，攻擊者也無法在沒有 KMS 授權的情況下解密敏感資料。

## 3. 解決方案對比與建議
| 維度 | K8S 原生 Secret (加密) | HashiCorp Vault 整合 |
| :--- | :--- | :--- |
| **安全性** | 較低 (Base64 + KMS) | 極高 (動態金鑰 + 稽核) |
| **複雜度** | 低 | 高 |
| **適用場景** | 一般環境設定 | 金融級、動態資料庫憑證 |

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Security Hardening Specialist
