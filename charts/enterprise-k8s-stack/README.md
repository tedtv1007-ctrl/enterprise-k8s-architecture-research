# Enterprise K8S Architecture Stack (Helm Chart)

## Overview
This Helm Chart bundles the essential components for a secure and resilient Kubernetes cluster:
-   **Cilium**: Network security, observability (Hubble), and transparent encryption (WireGuard).
-   **External Secrets Operator (ESO)**: Securely syncing secrets from external providers (e.g., Vault).
-   **Velero**: Automated backup and disaster recovery.

## Prerequisites
-   Helm 3+ installed.
-   Kubernetes 1.26+ cluster.

## Deployment
1.  **Add Repositories**:
    ```bash
    helm repo add cilium https://helm.cilium.io/
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
    helm repo update
    ```

2.  **Install Chart**:
    ```bash
    # From the charts directory
    helm dependency build ./enterprise-k8s-stack
    helm install k8s-security-stack ./enterprise-k8s-stack \
      --namespace security-ops \
      --create-namespace \
      --values values.yaml
    ```

3.  **Verify**:
    ```bash
    kubectl get pods -n security-ops
    cilium status
    ```
