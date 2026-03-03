# Cilium & Hubble (eBPF) 本地實驗指南

本指南說明如何透過自動化腳本，在本地使用 Kind (Kubernetes in Docker) 建立一個專屬的 eBPF 網路觀測環境。這解決了研究清單中的「Cilium 網絡與 Hubble 觀測實作」項目。

## 為什麼這很重要？
傳統的 K8S 網路（如 iptables）在大規模環境下性能較差且難以觀測。Cilium 透過 **eBPF** 技術直接在 Linux 核心處理封包，提供了：
1. **高效能**：繞過傳統網路堆疊，提升吞吐量。
2. **深層觀測 (Hubble)**：不需修改程式碼，即可看到 L7 (HTTP/DNS) 的連線細節與錯誤率。
3. **身分安全**：基於 Pod 標籤而非 IP 位址來定義安全規則。

## 執行步驟
1. 確保您的環境已啟動 Docker Desktop。
2. 執行自動化測試腳本（此腳本會建立名為 `cilium-lab` 的 Kind 叢集）：
   ```powershell
   .\scripts\setup-cilium-lab.ps1
   ```
3. **開啟流量地圖介面**：
   執行以下指令，系統會自動在瀏覽器開啟 Hubble UI：
   ```powershell
   cilium hubble ui
   ```

## 如何觀察流量？
1. 在 Hubble UI 左上角的 **Namespace** 選單選擇 `kube-system`。
2. 您將看到 K8S 核心組件（如 CoreDNS, API Server）之間的即時連線圖。
3. 點擊連線線條，可以查看詳細的傳輸協定、延遲與封包狀態。

## 清理環境
實驗結束後，若要刪除此測試叢集以節省資源：
```powershell
kind delete cluster --name cilium-lab
```
