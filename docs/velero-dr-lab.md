# Velero 災難復原 (Disaster Recovery) 本地實驗指南

本指南說明如何透過自動化腳本，在本地使用 Kind 建立一個包含 Velero 與 MinIO (S3 模擬) 的備份環境，並進行資料庫的備份與還原演練。這解決了研究清單中的「Velero 備份一致性驗證」與「災難復原實作」項目。

## 為什麼這很重要？
在 K8S 中，刪除一個 Namespace 往往只需要幾秒鐘，但資料的損失可能是毀滅性的。Velero 提供了：
1. **資源備份**：備份所有 YAML 定義（Deployment, Service, ConfigMap）。
2. **災難復原**：當叢集誤刪或損毀時，可以將整套服務與資料救回。
3. **離線存儲**：將備份檔存放在與叢集隔離的 S3 (本實驗室使用 MinIO 模擬)。

## 執行步驟
1. 確保您的環境已啟動 Docker Desktop。
2. 執行 **全功能實驗室腳本**（此腳本會建立 `enterprise-lab` 叢集並安裝所有組件）：
   ```powershell
   .\scripts\setup-full-lab.ps1
   ```
3. **進行備份演練**：
   ```powershell
   # 備份測試資料庫命名空間
   velero backup create db-backup --include-namespaces test-db --wait
   ```
4. **模擬災難發生**：
   ```powershell
   # 手動刪除資料庫，模擬資料遺失
   kubectl delete namespace test-db
   ```
5. **執行一鍵還原**：
   ```powershell
   # 從備份中救回資料庫
   velero restore create --from-backup db-backup --wait
   ```

## 如何驗證還原結果？
1. 檢查 Namespace 是否恢復：`kubectl get namespaces`
2. 檢查資料庫 Pod 是否重新啟動：`kubectl get pods -n test-db`
3. 檢查 Velero 狀態：`velero backup get` 與 `velero restore get`

## 清理環境
實驗結束後，若要刪除此測試叢集以節省資源：
```powershell
kind delete cluster --name enterprise-lab
```
