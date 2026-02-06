# 企業級 .NET Core 應用程式 K8S 佈署範本研究報告

## 1. Helm Chart 結構說明
本範本旨在提供標準化且具備高可用性的部署結構，包含：
*   **Deployment**: 嚴格配置資源限額 (CPU/RAM Quota) 與 `.NET` 相容的自癒 Probes。
*   **HPA**: 自動化水平伸縮，確保業務高峰期的穩定性。
*   **Ingress**: 支援 TLS 終止，並可無縫切換 Nginx 或 APISIX。

## 2. 安全性連線設計 (Redis & Postgres)
針對 Issue #4 的 Redis 密碼驗證需求，採用 K8S Secret 結合環境變數注入：
*   **Redis**: 透過 `Redis__Configuration` 注入，格式對齊 `.NET StackExchange.Redis` 標準。
*   **Postgres**: 使用 `ConnectionStrings__Postgres` 進行標準化連線。

## 3. 部署配置範例
```yaml
resources:
  limits: { cpu: 500m, memory: 512Mi }
  requests: { cpu: 200m, memory: 256Mi }

env:
  database:
    secretName: "app-db-secret"
  redis:
    secretName: "app-redis-secret" # 支援密碼驗證
```

---
產出時間: 2026-02-06
研究員: OpenClaw K8S Infrastructure Specialist
