# 企業級 K8S API 網關安全硬化 (APISIX & Keycloak) 研究報告

## 1. OIDC 自省機制整合 (Keycloak Introspection)
針對金融級安全性，本研究採用了 APISIX 的 `openid-connect` 插件實作了即時身份檢核：
*   **即時驗證**：不同於傳統的 JWT 本地解碼，網關在接收請求時會向 Keycloak 執行「Token 自省」，確保該帳號未被停權或撤銷。
*   **細粒度控管**：利用 `required_scopes` 實施 API 級別的操作權限控制，確保各服務間的呼叫具備明確的業務授權。

## 2. API 網關層級資料脫敏 (Response Scrubbing)
*   **零侵入脫敏**：利用 APISIX 的 `response-rewrite` 插件，在資料離開叢集前透過正則表達式 (Regex) 自動屏蔽手機號碼、電子郵件等 PII 欄位。
*   **數據合規**：確保即使後端微服務未實作脫敏，敏感資料也不會因 API 回傳而外洩，達成網關層級的 DLP 防護。

## 3. mTLS 雙向認證與傳輸安全
*   **外部存取防護**：在入口網關強制執行 mTLS 驗證，確保僅有持有企業核發憑證的外部系統能建立連線。
*   **零信任延伸**：建議在網關與後端 Upstream 之間同樣配置 SSL 驗證，補全全鏈路的傳輸安全。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S API Security Specialist
