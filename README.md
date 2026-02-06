# 企業級 K8S 架構研究 (Enterprise K8S Architecture Research)

本專案旨在研究並建構一套適合企業環境的 Kubernetes (K8S) 基礎設施架構，涵蓋關鍵應用整合、自動化運維與資安防護要求。

## 1. 核心應用組件 (Application Stack)
K8S 叢集將承載以下關鍵服務：
- **協作工具**：Mattermost (通訊)、Wiki.js (知識庫)、Outline (文件)。
- **監控與日誌**：ELK Stack (Elasticsearch, Logstash, Kibana)。
- **資料庫與緩存**：PostgreSQL (關聯式資料庫)、Redis (快取與 Session 儲存)。
- **應用開發**：.NET Core 容器化服務。

## 2. 基礎設施架構要求
- **Ingress 控制**：建議使用 NGINX Ingress Controller 或 APISIX。
- **儲存管理**：Persistent Volume (PV) 管理（建議整合企業 NAS 或分散式儲存如 Longhorn/Ceph）。
- **身分驗證**：整合 Keycloak (OIDC/SAML) 以達成 SSO。

## 3. 資安與上版流程 (SecDevOps)
- **Image 掃描**：整合 Trivy 或 Harbor 進行映像檔漏洞掃描。
- **上版流程 (CI/CD)**：
    - 使用 GitHub Actions 或 GitLab CI 進行建置。
    - 採用 ArgoCD 實作 GitOps 自動化佈署。
- **網路安全**：實作 Network Policy 進行 Namespace 層級的隔離。

## 4. 系統架構圖 (Architecture Diagrams)

### 4.1 核心服務佈署架構 (Cluster Overview)
本架構採用多層 Namespace 隔離設計，並透過 Ingress Controller 統一出口。

```mermaid
graph TD
    User([使用者]) --> Ingress[Ingress Controller / APISIX]
    
    subgraph "enterprise-apps (應用層)"
        Ingress --> MM[Mattermost]
        Ingress --> WK[Wiki.js]
        Ingress --> OL[Outline]
        Ingress --> NET[.NET Core Apps]
    end
    
    subgraph "enterprise-data (資料層)"
        MM --> PG[(PostgreSQL)]
        WK --> PG
        OL --> PG
        NET --> PG
        MM --> RD_MM((Redis for Mattermost))
        NET --> RD_NET((Redis for .NET Apps))
    end
    
    subgraph "enterprise-infra (監控與管理)"
        ELK[(ELK Stack)]
        KC[Keycloak SSO]
        SCAN[Trivy Image Scan]
    end
    
    %% 持久化儲存關聯
    PG -.-> Longhorn[Longhorn Persistent Volume]
    ELK -.-> Longhorn
```

### 4.2 SecDevOps 上版流程 (CI/CD Pipeline)
展示從代碼提交到部署的安全自動化路徑。

```mermaid
sequenceDiagram
    participant Dev as 開發者
    participant GH as GitHub Actions
    participant Scan as Trivy Scanner
    participant Registry as Harbor / Registry
    participant CD as ArgoCD
    participant K8S as K8S Cluster

    Dev->>GH: Git Push Code
    GH->>GH: Build Container Image
    GH->>Scan: 執行漏洞掃描 (Security Scan)
    Scan-->>GH: 掃描結果 (High/Critical Check)
    
    alt 發現嚴重漏洞
        GH-->>Dev: 終止佈署並報錯
    else 通過檢核
        GH->>Registry: Push Verified Image
        GH->>GH: 更新 Helm / Kustomize Manifests
        CD->>GH: 偵測到配置變更
        CD->>K8S: 同步狀態 (GitOps Sync)
        K8S-->>CD: 佈署完成
    end
```

## 5. 研究 Issue 追蹤
詳細的技術規劃與實作進度請參考本倉庫的 [Issues](https://github.com/tedtv1007-ctrl/enterprise-k8s-architecture-research/issues)。
