# Vault 與 External Secrets Operator (ESO) 本地實驗指南

本指南說明如何透過自動化腳本，在本地 K8S (如 Kind, Docker Desktop) 環境中快速架設 Vault 與 ESO 的整合測試。這解決了研究清單中的「ESO 與私有 Vault 的自動化部署範本」項目。

## 為什麼這很重要？
在企業環境中，我們不能將資料庫連線密碼、API Keys 以明文或單純的 Base64 存在 Git 中。透過 Vault 統一保管，再由 ESO 自動同步進 K8S，我們能達成：
1. **單一來源 (Single Source of Truth)**：所有密碼只存在 Vault 中。
2. **自動輪替**：後端服務依然讀取標準的 K8S Secret，對它們來說是透明的。
3. **安全隔離**：開發者只需操作 `ExternalSecret`，無須知道真實密碼。

## 執行步驟
1. 確保您的環境已連接至本地的 Kubernetes 叢集，並安裝了 `helm` 與 `kubectl`。
2. 執行自動化測試腳本：
   ```powershell
   .\scripts\setup-vault-eso-lab.ps1
   ```
3. **腳本會自動完成以下事項：**
   - 部署 Vault 並設定 Kubernetes 身分驗證機制。
   - 寫入一筆測試資料：`secret/apps/milk-api/db`。
   - 部署 External Secrets Operator (ESO)。
   - 套用 `manifests/vault-eso-demo.yaml`，建立與 Vault 連接的 `ClusterSecretStore` 和抓取密碼的 `ExternalSecret`。
   - 最終，ESO 會在 `default` namespace 中生成一個名為 `milk-db-secret` 的標準 K8S Secret。

## 測試密碼是否成功同步
執行完畢後，您可以解碼 K8S 自動產生的 Secret 來驗證：
```bash
kubectl get secret milk-db-secret -n default -o jsonpath='{.data.password}' | base64 -d
```
如果出現 `SuperSecret123!`，代表同步成功！
