# External Secrets / Secret Management — 2026-02-14

Overview
- External Secrets (external-secrets/kubernetes-external-secrets or ExternalSecrets operator) synchronizes secrets from external providers (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault) into Kubernetes Secrets.
- Alternatives: SealedSecrets (Bitnami) for encrypted secrets in repo; Vault Agent Injector for runtime injection; ExternalSecrets for dynamic sync.

Recommendation
- For dynamic secrets and rotation: ExternalSecrets with Vault or cloud provider secrets manager.
- For storing deployment secrets in git (encrypted): SealedSecrets.

Example: ExternalSecrets using AWS Secrets Manager
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-credentials
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: aws-secret-store
    kind: SecretStore
  target:
    name: db-credentials
  data:
    - secretKey: username
      remoteRef:
        key: prod/db/username
    - secretKey: password
      remoteRef:
        key: prod/db/password

Security notes
- Use least-privilege IAM roles for the secret store.
- Prefer short-lived credentials and role assumption when possible.

Next steps I can do
- Provide an operator Helm values.yaml example and sample SecretStore definitions for AWS/GCP/Vault.
