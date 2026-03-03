# Hubble 指標與 Grafana 整合監控實驗指南

本指南說明如何透過自動化腳本，將 Cilium (eBPF) 的網路指標整合進 Prometheus 與 Grafana，實現企業級的維運監控與視覺化。

## 為什麼這很重要？
視覺化的流量地圖（Hubble UI）雖然好用，但無法追蹤歷史趨勢。透過此監控堆疊，您可以：
1. **趨勢分析**：觀察過去 24 小時內的網路延遲變化。
2. **故障診斷**：透過封包丟失 (Drop) 指標快速定位網路擁塞點。
3. **主動警報**：當特定 API 的連線失敗率過高時，可以結合 Prometheus Alertmanager 發送警報。

## 執行步驟
1. 確保您的環境已執行 `setup-full-lab.ps1`。
2. 執行 **監控自動化腳本**：
   ```powershell
   .\scripts\setup-monitoring-lab.ps1
   ```
3. **存取 Grafana 介面**：
   ```powershell
   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
   ```
   - 造訪: `http://localhost:3000`
   - 帳號/密碼: `admin` / `prom-operator`

## 導入專業 Dashboard
1. 在 Grafana 中，點擊 **Dashboards > Import**。
2. 輸入 Dashboard ID: **`14730`** (Cilium Hubble Metrics)。
3. 選擇 **Prometheus** 作為資料來源。
4. 您將看到包含 HTTP 延遲、TCP 重傳、DNS 查詢成功率等深度網路指標。

## 清理環境
實驗結束後，若要刪除監控命名空間以節省資源：
```powershell
kubectl delete namespace monitoring
```
