# 自動化本地 K8S (Kind/Minikube) 部署 HashiCorp Vault + External Secrets Operator 的實驗環境

Write-Host "🚀 開始建置 Vault + ESO 實驗環境..." -ForegroundColor Cyan

# 1. 確保 Helm Repo 已加入
Write-Host "📦 加入 Helm 儲存庫..." -ForegroundColor Yellow
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# 2. 部署 Vault (開發模式)
Write-Host "🔐 部署 HashiCorp Vault (Dev Mode)..." -ForegroundColor Yellow
helm upgrade --install vault hashicorp/vault `
  --set "server.dev.enabled=true" `
  --set "server.dev.rootToken=root" `
  --namespace vault --create-namespace --wait

# 3. 設定 Vault 的 Kubernetes 驗證與 Policy
Write-Host "⚙️ 設定 Vault 驗證機制與存取策略 (Policy)..." -ForegroundColor Yellow
$vaultPod = kubectl get pods -n vault -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}'

# 建立 Vault 策略 (允許讀取 secret/data/*)
$policy = 'path \"secret/data/*\" { capabilities = [\"read\"] }'
kubectl exec -n vault $vaultPod -- /bin/sh -c "echo '$policy' > /tmp/policy.hcl && vault policy write eso-policy /tmp/policy.hcl"

# 啟用 Kubernetes 驗證
kubectl exec -n vault $vaultPod -- vault auth enable kubernetes
kubectl exec -n vault $vaultPod -- vault write auth/kubernetes/config `
    kubernetes_host="https://kubernetes.default.svc.cluster.local:443"

# 建立 Vault Role，綁定 ESO 的 ServiceAccount
kubectl exec -n vault $vaultPod -- vault write auth/kubernetes/role/eso-role `
    bound_service_account_names=external-secrets `
    bound_service_account_namespaces=external-secrets `
    policies=eso-policy `
    ttl=1h

# 4. 在 Vault 中寫入一筆測試資料庫密碼
Write-Host "📝 寫入測試密碼至 Vault..." -ForegroundColor Yellow
kubectl exec -n vault $vaultPod -- vault kv put secret/apps/milk-api/db user="milk_admin" pass="SuperSecret123!"

# 5. 部署 External Secrets Operator (ESO)
Write-Host "⚙️ 部署 External Secrets Operator..." -ForegroundColor Yellow
helm upgrade --install external-secrets external-secrets/external-secrets `
  --namespace external-secrets --create-namespace --wait

# 確保 CRDs 已載入
Write-Host "⏳ 等待 CRDs 生效並重試部署..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# 6. 部署 ClusterSecretStore 與 ExternalSecret
Write-Host "🔌 部署 ClusterSecretStore 與 ExternalSecret..." -ForegroundColor Yellow
$manifestPath = Join-Path $PSScriptRoot "..\manifests\vault-eso-demo.yaml"
for ($i=1; $i -le 5; $i++) {
    kubectl apply -f $manifestPath
    if ($?) { break }
    Write-Host "🔄 正在重試 ($i/5)..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

Write-Host "✅ 部署指令已執行！等待 ESO 同步密碼..." -ForegroundColor Green
Start-Sleep -Seconds 15
Write-Host "🔍 檢查建立的 K8S Secret:" -ForegroundColor Cyan
kubectl get secret milk-db-secret -n default -o yaml
