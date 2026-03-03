# 📄 專案導讀手冊：Enterprise K8S Architecture Research (企業級 K8S 架構研究)

## 📌 專案定位 (Project Vision)
這個專案是為了建立一套符合**企業級標準**的 Kubernetes (K8S) 維運範本。它不只是跑起來，而是要解決企業在 K8S 落地時最頭痛的三大問題：
1.  **安全性 (Security)**：如何保護網路與機敏資料？
2.  **可觀測性 (Observability)**：出問題時如何快速定位？
3.  **災難復原 (Backup & DR)**：萬一叢集掛了，資料怎麼救回來？

---

## 🏗️ 三大技術支柱 (Core Pillars)

### 1. 🕸️ 網路與安全性 (Cilium & Hubble)
*   **它是什麼**：基於 eBPF 技術的 K8S 網路組件 (CNI)。
*   **解決什麼問題**：
    *   **身分識別安全 (Pod Identity)**：不再依賴變動的 IP，而是根據 Pod 的身分來決定誰能連誰。
    *   **精準流量控制 (L7 Security)**：可以限制「Pod A 只能對 Pod B 發送 `/api/v1/health` 的 GET 請求」，其餘操作全部攔截。
    *   **Hubble 視覺化**：內建「流量地圖」，讓你一眼看出哪個服務在連線失敗、延遲是多少。

### 2. 🔐 金鑰管理 (External Secrets Operator - ESO)
*   **它是什麼**：K8S Secrets 的同步器。
*   **解決什麼問題**：
    *   **別把密碼放進 Git**：GitOps 流程中，我們不希望在程式碼裡看到密碼。
    *   **集中化管理**：讓 K8S 自動去跟外部工具（如 HashiCorp Vault, AWS Secrets Manager）同步密碼，實現「一處更改，全叢集更新」。

### 3. 💾 備份與還原 (Velero)
*   **它是什麼**：K8S 專用的備份與遷移工具。
*   **解決什麼問題**：
    *   **異地備份**：定期備份 K8S 所有的設定檔案 (Yaml) 與硬碟資料 (Persistent Volumes)。
    *   **快速重建**：當叢集損毀時，可以用 Velero 在一個全新的叢集上一鍵還原所有服務。

---

## 📂 資料夾導覽 (Folder Structure)

*   `docs/`：包含 `implementation-guide.md`，這是手把手的安裝與設定教學。
*   `manifests/`：存放正式環境的設定檔範本（如 Cilium 的生產環境設定、與 Vault 的連線設定）。
*   `charts/`：這是一個 Helm Chart 包，將上述所有組件封裝在一起，方便一鍵部署。
*   `policies/`：存放網路安全規則（L7 Rules），定義了應用程式之間的連線黑白名單。

---

## 🚀 如何快速上手？

如果您想了解目前的研究進度與實驗計畫，請參閱：
1.  **`README.md`**：查看專案整體目標與 TODO 清單。
2.  **`research-plan.md`**：目前正在進行的實驗細節（例如 Cluster Mesh 多叢集連線）。

---
*Last Updated: 2026-03-03*
