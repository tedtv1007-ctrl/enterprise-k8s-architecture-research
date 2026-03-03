# 企業級 K8S 全功能研究實驗室 (Cilium + ESO/Vault + Velero/MinIO)
# 此腳本會在一台乾淨的機器上一鍵建立所有研究組件

Write-Host "🚀 開始建置企業級 K8S 研究實驗室..." -ForegroundColor Cyan

# 0. 環境變數設定
$env:Path += ";$env:USERPROFILE\scoop\shims"
$CLUSTER_NAME = "enterprise-lab"

# 1. 建立 Kind 叢集
Write-Host "🏗️ 建立 Kind 叢集 ($CLUSTER_NAME)..." -ForegroundColor Yellow
$kindConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "10.244.0.0/16"
"@
if (!(kind get clusters | Select-String -Pattern "^$CLUSTER_NAME$")) {
    $configPath = New-TemporaryFile
    $kindConfig | Out-File -FilePath $configPath -Encoding utf8
    kind create cluster --name $CLUSTER_NAME --config $configPath
    Remove-Item $configPath
} else {
    kubectl config use-context kind-$CLUSTER_NAME
}

# 2. 安裝 Cilium (網路與 Hubble 觀測)
Write-Host "🕸️ 安裝 Cilium 與 Hubble..." -ForegroundColor Yellow
cilium install --version 1.16.6
cilium hubble enable --ui

# 3. 安裝 Vault & ESO (密碼管理)
Write-Host "🔐 安裝 Vault 與 External Secrets Operator..." -ForegroundColor Yellow
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install vault hashicorp/vault --set "server.dev.enabled=true" --set "server.dev.rootToken=root" --namespace vault --create-namespace --wait
helm upgrade --install external-secrets external-secrets/external-secrets --namespace external-secrets --create-namespace --wait

# 4. 安裝 MinIO & Velero (備份與復原)
Write-Host "💾 安裝 MinIO (S3 模擬) 與 Velero..." -ForegroundColor Yellow
# 部署 MinIO 容器 (簡單版)
$minioManifest = @"
apiVersion: v1
kind: Namespace
metadata:
  name: minio
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: minio
  name: minio
spec:
  selector:
    matchLabels:
      app: minio
  strategy: {type: Recreate}
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args: [server, /data, --console-address, ":9001"]
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin"
        ports:
        - containerPort: 9000
        - containerPort: 9001
---
apiVersion: v1
kind: Service
metadata:
  namespace: minio
  name: minio
spec:
  type: ClusterIP
  ports:
    - port: 9000
      targetPort: 9000
      name: api
    - port: 9001
      targetPort: 9001
      name: console
  selector:
    app: minio
"@
$minioManifest | kubectl apply -f -

# 安裝 Velero
Write-Host "⏳ 正在初始化 Velero..." -ForegroundColor Yellow
# 建立 MinIO 認證檔
$veleroCreds = "[default]`naws_access_key_id=minioadmin`naws_secret_access_key=minioadmin"
$veleroCreds | Out-File -FilePath "credentials-velero" -Encoding ascii

velero install `
    --provider aws `
    --plugins velero/velero-plugin-for-aws:v1.9.0 `
    --bucket velero `
    --secret-file .\credentials-velero `
    --use-volume-snapshots=false `
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.minio.svc.cluster.local:9000 `
    --use-node-agent `
    --wait

Remove-Item "credentials-velero"

# 5. 部署測試用 Postgres 資料庫
Write-Host "🐘 部署測試資料庫 (Postgres)..." -ForegroundColor Yellow
kubectl create namespace test-db --dry-run=client -o yaml | kubectl apply -f -
$postgresManifest = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: test-db
  name: postgres
spec:
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: "password123"
        ports:
        - containerPort: 5432
"@
$postgresManifest | kubectl apply -f -

Write-Host "✅ [實驗室建置完成]" -ForegroundColor Green
Write-Host "1. 網路觀測: cilium hubble ui" -ForegroundColor White
Write-Host "2. 備份測試: velero backup create db-backup --include-namespaces test-db" -ForegroundColor White
Write-Host "3. 還原測試: velero restore create --from-backup db-backup" -ForegroundColor White
