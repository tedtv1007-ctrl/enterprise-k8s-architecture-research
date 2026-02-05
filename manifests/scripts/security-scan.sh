#!/bin/bash
# 企業級 K8S Image 安全掃描腳本 (Mock for Research)
# 使用 Trivy 進行漏洞掃描並產出報告

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
    echo "使用方式: ./security-scan.sh [IMAGE_NAME]"
    exit 1
fi

echo "[資安掃描] 正在掃描映像檔: $IMAGE_NAME ..."

# 模擬 Trivy 掃描邏輯
# 實際環境需安裝 trivy: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
# trivy image --severity HIGH,CRITICAL $IMAGE_NAME

echo "[結果] 掃描完成。未發現 CRITICAL 等級漏洞。"
echo "[結果] 建議修復 2 個 HIGH 等級漏洞（基礎 OS 補丁）。"
