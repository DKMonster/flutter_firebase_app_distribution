# Firebase App Distribution 自動化部署

這個文件包含了完整的 Firebase App Distribution 自動化部署解決方案，適用於 Flutter 專案的 Android 應用程式部署，iOS教學我後續待補，主要是設定上會稍微麻煩一些。

## 🎯 部署模式

本專案支援兩種部署模式：

### 1. 有 Flavor 模式（多環境）
適用於需要多環境部署的正式專案：
- **development**：開發環境
- **staging**：測試環境  
- **production**：正式環境

### 2. 無 Flavor 模式（單一環境）
適用於簡單專案或原型開發：
- 不需要複雜的環境設定
- 快速部署單一版本
- 簡化的配置流程

## 開始之前

### 有 Flavor 模式設定
1. 複製 `.env.example` 為 `.env`
2. 填入實際的 Firebase App ID 和其他設定
3. 確保 `.env` 檔案已加入 `.gitignore`
4. 參考 `security-guide.md` 了解安全最佳實踐

### 無 Flavor 模式設定
1. 複製 `env.example.no-flavor` 為 `.env`
2. 填入 Firebase App ID
3. 確保 `.env` 檔案已加入 `.gitignore`

## 🚀 快速開始

### 有 Flavor 模式部署
1. 確認環境設定完成（參考 `implementation-guide.md`）
2. 執行部署腳本：
   ```bash
   ./secure-deploy-example.sh -f staging
   ```

### 無 Flavor 模式部署
1. 確認環境設定完成（參考 `no-flavor-deployment-guide.md`）
2. 執行部署腳本：
   ```bash
   ./deploy-without-flavor.sh
   ```

## 🎯 主要特色

- **支援多環境部署**：development、staging、production
- **支援無 Flavor 模式**：簡化的單環境部署
- **自動化建置流程**：從建置到部署一鍵完成
- **錯誤處理機制**：完善的錯誤檢查與提示
- **彩色輸出介面**：清晰的執行狀態顯示
- **智能檢測**：自動檢測專案 Flavor 設定

## 📝 文件說明

### 1. 簡報指南 (`presentation-guide.md`)
適合用於簡報分享，包含：
- 功能亮點
- 架構圖
- 演示流程
- Q&A 準備

### 2. 實作指南 (`implementation-guide.md`)
詳細的實作步驟，包含：
- 環境設定
- Firebase 專案設定
- 腳本安裝與設定
- 常見問題解決

### 3. 無 Flavor 部署指南 (`no-flavor-deployment-guide.md`)
無 Flavor 模式的完整指南，包含：
- 快速開始步驟
- 環境設定說明
- 故障排除指南
- 與有 Flavor 模式的比較

### 4. 腳本分析 (`script-analysis.md`)
深入的技術分析，包含：
- 程式碼結構解析
- 關鍵功能說明
- 擴充建議

## 📁 腳本檔案

- `secure-deploy-example.sh`：有 Flavor 模式的部署腳本
- `deploy-without-flavor.sh`：無 Flavor 模式的部署腳本
- `env.example.no-flavor`：無 Flavor 模式的環境變數範例

## 👥 適用對象

- Flutter 開發者
- DevOps 工程師
- 對自動化部署有興趣的開發者
- 需要快速部署的專案團隊

## 📞 聯絡資訊

如有問題或建議，歡迎透過以下方式聯繫：
- GitHub Issues
- Pull Requests

---
最後更新：2025-07-29