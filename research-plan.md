# Enterprise K8S Architecture Research Plan

## Phase 1: Network Security & Observability (Cilium & Hubble)
**Objective**: Design a secure networking layer using eBPF that supports L7 filtering and deep observability.

- [x] **Artifact 1**: `manifests/cilium-values-production.yaml`
    - Enable Hubble UI & Relay.
    - Enable WireGuard transparent encryption.
    - Configure L7 proxy for DNS/HTTP visibility.
- [x] **Artifact 2**: `policies/rule-deny-all-ingress.yaml` & `policies/rule-allow-api-l7.yaml`
    - Baseline Zero Trust policy.
    - Example of L7 allow-listing (e.g., only allow POST to `/api/v1/claims`).
- [x] **Artifact 1.5**: `scripts/setup-cilium-lab.ps1` & `docs/cilium-hubble-lab.md`
    - Automated lab setup for local eBPF testing.

## Phase 2: Secrets Management (External Secrets Operator)
**Objective**: GitOps-friendly secret management integrated with HashiCorp Vault.

- [x] **Artifact 3**: `manifests/cluster-secret-store-vault.yaml`
    - Connect K8S to external Vault.
- [x] **Artifact 4**: `manifests/external-secret-sample.yaml`
    - Example mapping of Vault secret to K8S Secret.
- [x] **Artifact 4.5**: `scripts/setup-vault-eso-lab.ps1` & `docs/vault-eso-lab.md`
    - Automated lab setup for local Vault & ESO testing.

## Phase 3: Disaster Recovery (Velero)
**Objective**: Automated backup strategy for cluster resources and persistent data.

- [x] **Artifact 5**: `manifests/velero-values-s3.yaml`
    - S3-compatible backend configuration (e.g., MinIO/AWS).
- [x] **Artifact 6**: `backup-schedule.yaml`
    - Daily backup schedule with retention policy.
