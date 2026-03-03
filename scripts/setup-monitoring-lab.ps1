# Automation Script: Deploy Prometheus + Grafana + Hubble Metrics

Write-Host "🚀 Starting Hubble Monitoring Lab Setup..." -ForegroundColor Cyan

# 0. Environment Setup
$env:Path += ";$env:USERPROFILE\scoop\shims"
$CLUSTER_NAME = "enterprise-lab"
kubectl config use-context kind-$CLUSTER_NAME

# 1. Prepare Helm Repos
Write-Host "📦 Preparing Helm repositories..." -ForegroundColor Yellow
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. Install Kube-Stack-Prometheus
Write-Host "📊 Installing Prometheus & Grafana (This may take 5-10 mins)..." -ForegroundColor Yellow
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
  --namespace monitoring --create-namespace --wait

# 3. Configure Cilium to export Prometheus Metrics
Write-Host "🕸️ Configuring Cilium to export metrics..." -ForegroundColor Yellow
# Update Cilium configuration to enable prometheus & hubble metrics
cilium upgrade --version 1.16.6 `
  --set prometheus.enabled=true `
  --set operator.prometheus.enabled=true `
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip`,source_pod`,destination_ip`,destination_pod`,destination_service}" `
  --set hubble.metrics.serviceMonitor.enabled=true `
  --set prometheus.serviceMonitor.enabled=true `
  --set operator.prometheus.serviceMonitor.enabled=true

# 4. Final Verification
Write-Host "✅ Monitoring Lab Deployed!" -ForegroundColor Green
Write-Host "💡 Access Instructions:" -ForegroundColor Cyan
Write-Host "   1. Access Grafana: kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80" -ForegroundColor White
Write-Host "   2. Credentials: admin / prom-operator" -ForegroundColor White
Write-Host "   3. Recommended Dashboard ID: 14730 (Cilium Hubble Metrics)" -ForegroundColor White
