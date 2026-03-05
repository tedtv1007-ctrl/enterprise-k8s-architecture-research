# Enterprise K8S Architecture Research

本專案專注於企業級 Kubernetes 架構的安全性、可觀測性與維運優化研究。

## 📖 快速導讀 (New!)
如果您不熟悉 K8S 相關技術，請先閱讀 [**EXPLAIN_LIKE_IM_FIVE.md**](./EXPLAIN_LIKE_IM_FIVE.md) 以獲得專案核心價值的簡單說明。

## 🕸️ 核心網路與安全 (Networking & Security)
### Cilium & Hubble (eBPF)
- **Identity-based Security**: 擺脫傳統 IP 限制，改用 Pod Identity 進行 L3/L4 隔離。
- **L7 流量控制**: 針對 HTTP/gRPC 進行細粒度管控（如：僅允許對特定 API 路徑的 POST 請求）。
- **Transparent Encryption**: 使用 IPsec 或 WireGuard 進行自動加密，無需修改應用程式。
- **Hubble 觀測**: 視覺化服務依賴圖，監控網路延遲與錯誤率。

## 🔐 憑證與金鑰管理 (Secrets Management)
### External Secrets Operator (ESO)
- **整合目標**: 將 K8S Secrets 與外部 Provider (如 HashiCorp Vault, AWS Secrets Manager, GitHub Secrets) 同步。
- **安全性**: 避免將機敏資料直接存放在 Git (GitOps 安全實踐)。

## 💾 備份與災難復原 (Backup & DR)
### Velero
- **應用情境**: 定期備份 K8S 資源與 Persistent Volumes (PV)。
- **遷移**: 支援跨移至不同叢集或 Cloud Provider。

## 🧪 本地實驗室 (Local Labs)
本專案包含多個自動化腳本，可讓您在本地環境中快速啟動研究場景：
- **[Linux/WSL/macOS 一鍵部署](./scripts/deploy-lab.sh)**: 使用 Shell 腳本自動化部署完整研究環境。
- **[Windows PowerShell 一鍵部署](./scripts/setup-full-lab.ps1)**: 針對 Windows 使用者的自動化部署腳本。
- **[Vault + ESO 實驗室](./docs/vault-eso-lab.md)**: 密碼同步與機敏資料管理演練。
- **[Cilium + Hubble 實驗室](./docs/cilium-hubble-lab.md)**: eBPF 網路流量觀測與 L7 安全演練。
- **[Hubble 監控實驗室](./docs/hubble-monitoring-lab.md)**: Prometheus 與 Grafana 指標監控演練。
- **[Velero 災難復原實驗室](./docs/velero-dr-lab.md)**: 備份與還原演練。

## 📍 研究清單 (Research Todo)
- [ ] Cilium Cluster Mesh 多叢集連動測試
- [x] Hubble 監控指標與 Grafana Dashboard 整合 ([Hubble Monitoring Lab](./docs/hubble-monitoring-lab.md))
- [x] ESO 與私有 Vault 的自動化部署範本 ([Vault ESO Lab](./docs/vault-eso-lab.md))
- [x] Velero 針對 RWO 磁碟的備份一致性驗證 ([Velero DR Lab](./docs/velero-dr-lab.md))
