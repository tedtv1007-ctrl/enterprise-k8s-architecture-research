#!/bin/bash
# -----------------------------------------------------------------------------
# Enterprise K8S Research Lab - One-Click Deployment Script (Linux/WSL)
# -----------------------------------------------------------------------------
# This script automates the setup of a research environment including:
# 1. Kind (Local K8S Cluster)
# 2. Cilium (eBPF Networking & Hubble Observability)
# 3. HashiCorp Vault (Secrets Management)
# 4. External Secrets Operator (ESO Integration)
# 5. MinIO (S3-compatible storage for backups)
# 6. Velero (Disaster Recovery & Backup)
# -----------------------------------------------------------------------------

set -e

# --- Configuration ---
CLUSTER_NAME="enterprise-lab"
KIND_IMAGE="kindest/node:v1.31.0"
VAULT_NAMESPACE="vault"
ESO_NAMESPACE="external-secrets"
MINIO_NAMESPACE="minio"
VELERO_NAMESPACE="velero"

# Colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Starting Enterprise K8S Research Lab deployment...${NC}"

# --- 1. Prerequisites Check ---
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
command -v kind >/dev/null 2>&1 || { echo -e "${RED}Error: kind is not installed.${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}Error: kubectl is not installed.${NC}" >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo -e "${RED}Error: helm is not installed.${NC}" >&2; exit 1; }
command -v cilium >/dev/null 2>&1 || { echo -e "${RED}Error: cilium-cli is not installed.${NC}" >&2; exit 1; }
command -v velero >/dev/null 2>&1 || { echo -e "${RED}Error: velero-cli is not installed.${NC}" >&2; exit 1; }

# --- 2. Create Kind Cluster ---
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${GREEN}✅ Kind cluster '${CLUSTER_NAME}' already exists. Switching context...${NC}"
    kubectl config use-context "kind-${CLUSTER_NAME}"
else
    echo -e "${YELLOW}🏗️ Creating Kind cluster: ${CLUSTER_NAME}...${NC}"
    cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --image "${KIND_IMAGE}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "10.244.0.0/16"
EOF
fi

# --- 3. Install Cilium (Networking & Hubble) ---
echo -e "${YELLOW}🕸️ Installing Cilium with Hubble Observability...${NC}"
cilium install --version 1.16.6 --wait
cilium hubble enable --ui

# --- 4. Install Vault & External Secrets Operator ---
echo -e "${YELLOW}🔐 Installing HashiCorp Vault (Dev Mode) and ESO...${NC}"
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install Vault
helm upgrade --install vault hashicorp/vault \
    --namespace "${VAULT_NAMESPACE}" \
    --create-namespace \
    --set "server.dev.enabled=true" \
    --set "server.dev.rootToken=root" \
    --wait

# Install ESO
helm upgrade --install external-secrets external-secrets/external-secrets \
    --namespace "${ESO_NAMESPACE}" \
    --create-namespace \
    --wait

# --- 5. Install MinIO & Velero (Disaster Recovery) ---
echo -e "${YELLOW}💾 Setting up MinIO (S3) and Velero for backups...${NC}"

# Deploy MinIO
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${MINIO_NAMESPACE}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ${MINIO_NAMESPACE}
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
  namespace: ${MINIO_NAMESPACE}
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
EOF

# Install Velero
echo "minioadmin" > minio_password
echo "[default]
aws_access_key_id=minioadmin
aws_secret_access_key=minioadmin" > credentials-velero

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.9.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.minio.svc.cluster.local:9000 \
    --use-node-agent \
    --wait

rm credentials-velero minio_password

# --- 6. Deploy Sample Workload (Postgres) ---
echo -e "${YELLOW}🐘 Deploying test workload (Postgres)...${NC}"
kubectl create namespace test-db --dry-run=client -o yaml | kubectl apply -f -
cat <<EOF | kubectl apply -f -
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
EOF

echo -e "${GREEN}✅ [Deployment Complete]${NC}"
echo -e "----------------------------------------------------------------"
echo -e "1. ${CYAN}Observability:${NC} Run 'cilium hubble ui' to open dashboard."
echo -e "2. ${CYAN}Backup Test:${NC}   Run 'velero backup create db-backup --include-namespaces test-db'"
echo -e "3. ${CYAN}Restore Test:${NC}  Run 'velero restore create --from-backup db-backup'"
echo -e "4. ${CYAN}Vault Access:${NC}  Vault Token: root (Namespace: vault)"
echo -e "----------------------------------------------------------------"
