# 自動化本地 K8S (Kind) 部署 Cilium + Hubble (eBPF 流量地圖) 實驗環境

Write-Host "🚀 開始建置 Cilium + Hubble 實驗環境..." -ForegroundColor Cyan

# 1. 使用 Kind 建立叢集 (關閉預設 CNI)
Write-Host "🏗️ 正在建立 Kind 叢集 (cilium-lab)..." -ForegroundColor Yellow
$kindConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true # 關鍵：讓 Cilium 接手網路
  podSubnet: "10.244.0.0/16"
"@

# 檢查叢集是否已存在
$clusters = kind get clusters
if ($clusters -contains "cilium-lab") {
    Write-Host "ℹ️ 叢集 cilium-lab 已存在，正在切換 Context..." -ForegroundColor Gray
    kubectl config use-context kind-cilium-lab
} else {
    $configPath = New-TemporaryFile
    $kindConfig | Out-File -FilePath $configPath -Encoding utf8
    kind create cluster --name cilium-lab --config $configPath
    Remove-Item $configPath
}

# 2. 安裝 Cilium
Write-Host "🕸️ 正在安裝 Cilium (eBPF 引擎)..." -ForegroundColor Yellow
cilium install --version 1.16.6

# 3. 啟動 Hubble (觀測功能)
Write-Host "🔭 正在啟動 Hubble 與 UI 介面..." -ForegroundColor Yellow
cilium hubble enable --ui

# 4. 等待狀態就緒
Write-Host "⏳ 等待 Cilium 節點就緒 (這可能需要 1-2 分鐘)..." -ForegroundColor Yellow
cilium status --wait

Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host "💡 您現在可以執行以下指令來查看流量地圖：" -ForegroundColor Cyan
Write-Host "   cilium hubble ui" -ForegroundColor White
Write-Host "   (這會自動在瀏覽器開啟 Hubble 網頁介面)" -ForegroundColor White
