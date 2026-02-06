# 保險業資安自律規範 - K8S 與 DevSecOps 導入注意事項清單

本文件針對 `enterprise-k8s-architecture-research` 專案需求，依據《保險業辦理資訊安全防護自律規範》（以下簡稱「自律規範」）進行分析，整理出 K8S 架構與 DevSecOps 流程之合規導入重點。

## 1. 遠距辦公與存取控制 (VPN/MFA)
根據自律規範第 14 條及第 21 條要求：

*   **遠端連線管制：**
    *   **VPN/VDI 規定：** 外部連線進入 K8S 管理介面（如 Dashboard, Lens）或內部開發環境時，必須使用 VPN 或 VDI，並落實「資料不落地」機制。
    *   **雙因子驗證 (MFA)：** 對於網際網路服務伺服器、AD 及具備「最高權限」或「特殊功能」之帳號，**強制實施 MFA**。
*   **K8S 導入建議：**
    *   所有存取 K8S API Server 的管理員及開發者帳號，必須整合 Keycloak 並啟用 MFA (TOTP/OIDC)。
    *   管理入口（Ingress）應限制僅能從公司 VPN 段 IP 存取。

## 2. 帳號與權限管理 (IAM/RBAC)
根據自律規範第 5 條及第 21 條要求：

*   **最小權限原則 (Least Privilege)：** 應依職務分工配發權限，並定期審查帳號合理性。
*   **特權帳號管理 (PAM)：** 管理營運環境（如 Master Node, SSH）應透過跳板機或 PAM 系統，並留存操作紀錄。
*   **K8S 導入建議：**
    *   實施 K8S RBAC，嚴格限制 `cluster-admin` 權限的使用。
    *   定期清理已離職員工或非必要之 ServiceAccount 權限。

## 3. 容器安全與漏洞管理 (Image Scan)
根據自律規範第 16 條要求：

*   **弱點掃描：** 網際網路系統應至少每季、核心系統應至少每半年進行弱點掃描。
*   **程式碼掃描 (SAST/DAST)：** 新系統上線前或異動時，應進行程式碼掃描或黑箱測試。
*   **K8S 導入建議：**
    *   **Image Scan 自動化：** 將 Trivy 或 Harbor 整合至 CI/CD 流程中。若發現 High 或 Critical 漏洞，應自動終止 Pipeline。
    *   **基礎映像檔管理：** 僅能使用經公司審核之 Base Image（黃金映像檔）。

## 4. 日誌留存與監控 (Logging)
根據自律規範第 19 條要求：

*   **留存天數：** 第一、二類電腦系統之事件日誌需**至少保留 180 天**。
*   **集中管理：** 日誌應送至原系統外之其他系統進行集中管理（如 ELK），並確保日誌完整性不可竄改。
*   **日誌內容：** 必須包含事件類型、時間、位置、使用者身分。
*   **K8S 導入建議：**
    *   整合 ELK Stack 收集 K8S Audit Logs 以及應用程式 Log。
    *   設定 ELK 之 Index Lifecycle Management (ILM) 確保資料保存 180 天以上。
    *   針對權限變更、登入失敗等異常行為設定告警。

## 5. 資料外洩防護 (DLP)
根據自律規範第 14 條及第 17 條要求：

*   **機敏資料防護：** 遠端作業應評估機敏資料防護，且委外開發時若涉及客戶資料需具備個人資料安全防範措施。
*   **K8S 導入建議：**
    *   **Secrets 管理：** 禁止將機敏資訊（密碼、金鑰）明文寫在 YAML 或程式碼中。應使用 K8S Secret 並搭配封裝工具（如 Sealed Secrets）或外部 Vault。
    *   **網路隔離 (Segmentation)：** 實施 Network Policy，限制不同 Namespace 之間的通訊（如應用層不可直接連至資料層中非必要的服務）。

## 6. 系統上線與變更管理 (DevSecOps)
根據自律規範第 6 條及第 17 條要求：

*   **架構審查：** 系統轉換前應建立架構審查機制，從資安、網路、平台面向進行評估。
*   **擬真測試：** 應建置擬真測試環境 (UAT) 進行功能與壓力測試。
*   **K8S 導入建議：**
    *   **GitOps 流程：** 採用 ArgoCD 實作變更管理，所有的配置異動（Manifests）皆需經過 Git PR 審核。
    *   **版本控制：** 嚴格落實 Helm Chart 與 Image Tag 的版本控制，嚴禁使用 `latest` 標籤。

---
**專案參考：** [tedtv1007-ctrl/enterprise-k8s-architecture-research](https://github.com/tedtv1007-ctrl/enterprise-k8s-architecture-research)
**法規來源：** [保險業辦理資訊安全防護自律規範](https://law.lia-roc.org.tw/Law/Content?lsid=FL072726)
