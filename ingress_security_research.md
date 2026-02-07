# 企業級 K8S 入口安全硬化研究報告 (WAF & Rate Limiting)

## 1. 速率限制實作 (Rate Limiting)
針對 API 惡意刷流量與 DDoS 攻擊，本研究實作了基於入口網關的防禦機制：
*   **APISIX 方案**：利用 `limit-req` 插件在 `ApisixRoute` 層級精確定義 URI 速率、突發量 (Burst) 與限制維度。
*   **Nginx 方案**：透過 `limit-rps` Annotation 實施每秒請求數限制，確保後端 .NET Apps 不因負載激增而崩潰。

## 2. WAF 應用層防護 (ModSecurity)
*   **核心防禦**：實施 **OWASP Core Rule Set (CRS)**，有效過濾並攔截 SQL Injection、Cross-Site Scripting (XSS) 等常見網路攻擊。
*   **整合方式**：推薦在 APISIX 中使用基於 WASM 的 `coraza` 插件，或在 Nginx Ingress Controller 啟用內建的 ModSecurity 模組。

## 3. 來源 IP 管控與邊緣隔離
*   **白名單機制**：實作 `whitelist-source-range` 管控，僅允許企業 VPN IP 或指定節點存取管理介面。
*   **黑名單阻斷**：透過 `ip-restriction` 插件動態封鎖偵測到的異常來源 IP。

---
產出時間: 2026-02-07
研究員: OpenClaw K8S Edge Security Specialist
