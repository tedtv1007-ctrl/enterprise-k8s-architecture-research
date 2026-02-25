# Cilium (CNI & Security) — 2026-02-14

Overview
- Cilium uses eBPF for high-performance networking, network policies, and load-balancing.
- Benefits vs iptables-based CNIs: better performance, richer observability, and identity-aware policies.

Install (Helm)
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium --version 1.14.0 \
  --namespace kube-system --set nodeinit.enabled=true

NetworkPolicies
- Prefer using CiliumNetworkPolicy (CNP) for identity-aware policies and L7 filtering where needed.
- Start with default deny and explicitly allow required traffic (APISIX, databases, kube-api).

Observability
- Enable Hubble for flow visibility:
  -- set hubble.enabled=true in Helm values and expose Hubble UI/metrics.

Best practices
- Test policies in 'monitor' mode before enforcing.
- Use identity-based policies for services that scale dynamically.

Next steps I can do
- Provide sample CiliumNetworkPolicy for milk-api-manager-system components (APISIX, backend, DB).
- Provide Helm values tuned for cluster size and CPU/memory constraints.
