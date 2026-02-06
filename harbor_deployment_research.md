# Harbor 部署規劃與 Helm Chart 配置 (Longhorn + Trivy + Ingress)

本文件針對 `enterprise-k8s-architecture-research` 專案需求，提供 Harbor 私有鏡像庫的 Helm Chart 配置範本與說明。

## 1. 環境需求與預設條件
- **K8S 叢集**: 已安裝 `Ingress Controller` (如 Nginx 或 APISIX)。
- **儲存方案**: 已安裝 `Longhorn` 並建立預設 StorageClass (`longhorn`)。
- **憑證管理**: 建議配合 `cert-manager` 使用，或手動建立 TLS Secret。

## 2. Harbor values.yaml 範本

以下配置基於官方 Harbor Helm Chart，針對專案需求進行最佳化：

```yaml
# harbor-values.yaml

expose:
  type: ingress
  tls:
    enabled: true
    secretName: harbor-tls # 需預先建立或透過 cert-manager 產生
  ingress:
    hosts:
      core: harbor.example.com # 修改為您的網域
    controller: default
    className: nginx # 依據您的 Ingress Controller 設定
    annotations:
      ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "0" # 允許上傳大型 Image

externalURL: https://harbor.example.com

# 數據持久化配置 - 對接 Longhorn
persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "longhorn"
      accessMode: ReadWriteOnce
      size: 100Gi
    chartmuseum:
      storageClass: "longhorn"
      accessMode: ReadWriteOnce
      size: 5Gi
    jobservice:
      storageClass: "longhorn"
      accessMode: ReadWriteOnce
      size: 1Gi
    database:
      storageClass: "longhorn"
      accessMode: ReadWriteOnce
      size: 5Gi
    redis:
      storageClass: "longhorn"
      accessMode: ReadWriteOnce
      size: 1Gi

# 掃描器配置 - 啟用 Trivy
trivy:
  enabled: true
  image:
    repository: goharbor/trivy-adapter-photon
    tag: v2.10.0
  # Trivy 數據庫持久化
  persistence:
    enabled: true
    storageClass: "longhorn"
    accessMode: ReadWriteOnce
    size: 5Gi

# 資料庫與 Redis (企業環境建議使用外部資料庫，此處為內建並持久化至 Longhorn)
database:
  type: internal
redis:
  type: internal
```

## 3. 關鍵設計說明

1.  **Ingress 整合**: 設定 `proxy-body-size: "0"` 以確保大型 Docker Image 能順利推送。
2.  **Longhorn 持久化**: 所有組件（Registry, DB, Redis, Trivy）皆指定 `longhorn` StorageClass，確保數據具備高度可用性與災難復原能力。
3.  **Trivy 資安整合**: 啟動 Trivy Adapter 並設定持久化儲存其漏洞數據庫。這能完美對接專案中的 **SecDevOps 上版流程**，在 Image Push 後自動觸發安全掃描。

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Infrastructure Specialist
