# Lab Implementation Guide (Hyper-V / Rocky Linux)

This guide provides the step-by-step setup for the Enterprise K8S Research Lab as defined in Issue #54.

## 1. Environment Overview
- **Host**: Windows PC with Hyper-V enabled.
- **OS**: Rocky Linux 10.1 (latest stable).
- **Network**: Private Virtual Switch with fixed internal IPs and AD-integrated DNS.

## 2. VM1: Control Plane (GitLab + Harbor)
This VM handles the core DevOps infrastructure.

### Installation Steps
1. **GitLab Omnibus**:
   - Follow the official Rocky Linux installation guide for GitLab EE/CE.
   - Configure `external_url 'https://gitlab.it205.ski.ad'`.
2. **Harbor**:
   - Install Docker & Docker Compose.
   - Download Harbor helm chart or online installer.
   - Configure `harbor.yml` with `hostname: harbor.it205.ski.ad` and TLS certificates from AD CS.
3. **Certificates**:
   - Import the AD CS Root CA into `/etc/pki/ca-trust/source/anchors/`.
   - Run `update-ca-trust`.

## 3. VM2: K8S Workload Cluster
A single-node cluster using `kubeadm` for research and testing.

### Bootstrap K8S
1. **Prepare OS**:
   - Disable Swap.
   - Configure modules (`overlay`, `br_netfilter`).
   - Set sysctl parameters for K8S networking.
2. **Install Runtimes**:
   - Install `containerd`.
   - Install `kubeadm`, `kubelet`, `kubectl`.
3. **Initialize**:
   ```bash
   kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint="k8s-cluster.it205.ski.ad"
   ```
4. **Post-Install**:
   - Trust AD CS Root CA on all nodes (critical for Harbor image pulls).

## 4. Cluster Components Setup

### Networking: Cilium + Hubble
Cilium replaces the default CNI for eBPF-based security and observability.
```bash
cilium install --set hubble.enabled=true --set hubble.relay.enabled=true --set hubble.ui.enabled=true
```
*Reference: `docs/cilium-hubble-lab.md`*

### Ingress: APISIX
APISIX serves as the unified North-South entry point.
- Use Helm to install APISIX and APISIX Ingress Controller.
- Configure routes for external access to Harbor/GitLab if needed, or internal services.

### LoadBalancer: MetalLB
To provide `type: LoadBalancer` support in the Hyper-V lab.
- Install MetalLB via Helm.
- Configure an `IPAddressPool` within the VM network range (e.g., `192.168.100.200-192.168.100.250`).

### GitOps: Argo CD
Argo CD pulls configurations from VM1 (GitLab) and applies them to VM2.
- Install Argo CD via Helm.
- Configure Repository credentials for `gitlab.it205.ski.ad`.

## 5. CI/CD Workflow
1. **Source**: GitLab Repo (VM1).
2. **CI**: GitLab Runner (running in K8S on VM2).
   - Build Image -> Push to Harbor (VM1).
   - Update GitOps Manifests Repo.
3. **CD**: Argo CD (VM2).
   - Detect change -> Sync to K8S.

---
*Generated based on Issue #54 requirements.*
