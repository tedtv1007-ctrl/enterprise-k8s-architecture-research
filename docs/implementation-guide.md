# K8S Enterprise Architecture Implementation Guide

## Prerequisites
- A Kubernetes cluster (v1.26+)
- `helm` v3+ installed
- `kubectl` configured

## 1. Network & Security (Cilium)

**Install Cilium with Hubble & WireGuard:**
```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

# Deploy with production values
helm install cilium cilium/cilium \
  --namespace kube-system \
  --version 1.15.0 \
  --values ../manifests/cilium-values-production.yaml
```

**Verify Installation:**
```bash
cilium status --wait
hubble status
```

**Apply L7 Security Policies:**
```bash
kubectl apply -f ../policies/l7-security-rules.yaml
```

## 2. Secrets Management (External Secrets Operator)

**Install ESO:**
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
```

**Connect to Vault:**
1. Ensure Vault is reachable.
2. Apply the ClusterSecretStore:
```bash
kubectl apply -f ../manifests/cluster-secret-store-vault.yaml
```

## 3. Backup & DR (Velero)

**Install Velero CLI:**
```bash
wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.0/velero-v1.13.0-linux-amd64.tar.gz
tar -xvf velero-v1.13.0-linux-amd64.tar.gz
sudo mv velero-v1.13.0-linux-amd64/velero /usr/local/bin/
```

**Install Velero to Cluster (MinIO Example):**
```bash
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.9.0 \
    --bucket velero-backups \
    --secret-file ./credentials-velero \
    --use-node-agent \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.default.svc:9000
```
