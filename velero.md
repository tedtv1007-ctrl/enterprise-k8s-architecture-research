# Velero (Kubernetes Disaster Recovery) — 2026-02-14

Overview
- Velero provides backup and restore for Kubernetes clusters (etcd data + object storage for PVs).
- Common for DR: periodic backups of namespaces/cluster-resources + off-cluster object storage (S3-compatible).

Quick install (Helm)
- Prereqs: S3-compatible bucket (AWS S3, MinIO, or other), credentials with limited policy.

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
helm install velero vmware-tanzu/velero \
  --namespace velero --create-namespace \
  --set credentials.secretContents.cloud=./credentials-velero \
  --set configuration.provider=aws \
  --set configuration.backupStorageLocation.name=default \
  --set configuration.backupStorageLocation.bucket=<BUCKET> \
  --set configuration.backupStorageLocation.config.region=<REGION> \
  --set configuration.volumeSnapshotLocation.name=default \
  --set configuration.volumeSnapshotLocation.config.region=<REGION>

Best practices
- Keep backups frequent for critical namespaces (e.g., every 15-60 min depending on RPO requirements).
- Use lifecycle rules on object storage to move older backups to colder storage.
- Test restores regularly into a staging cluster.
- Secure credentials using ExternalSecrets or SealedSecrets (avoid plaintext in repo).
- Include cluster-scoped resources (CRDs, ClusterRoles) when necessary.

Restore example
- velero restore create --from-backup <BACKUP_NAME>

Notes on PVs and CSI snapshots
- For PVs use CSI snapshots when supported for consistent volume snapshots.
- When CSI Snapshots not available, Velero can copy data from PVs to object storage (costly and slow).

Exercises I can do next
- Provide a Helm values.yaml tuned for production (retention, pruning, MMS settings).
- Create a tested restore playbook (steps + verification tests).
