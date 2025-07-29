# Firebase App Distribution 自動化部署

這個文件包含了完整的 Firebase App Distribution 自動化部署解決方案，適用於 Flutter 專案的 Android 應用程式部署，iOS教學我後續待補，主要是設定上會稍微麻煩一些。

## 開始之前

這邊需要先設定環境變數：

1. 複製 `.env.example` 為 `.env`
2. 填入實際的 Firebase App ID 和其他設定
3. 確保 `.env` 檔案已加入 `.gitignore`
4. 參考 `security-guide.md` 了解安全最佳實踐

## 🚀 快速開始

1. 確認環境設定完成（參考 `implementation-guide.md`）
2. 執行部署腳本：
   ```bash
   ./scripts/deploy_android_firebase.sh -f staging
   ```

## 🎯 主要特色

- **支援多環境部署**：development、staging、production
- **自動化建置流程**：從建置到部署一鍵完成
- **錯誤處理機制**：完善的錯誤檢查與提示
- **彩色輸出介面**：清晰的執行狀態顯示

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

### 3. 腳本分析 (`script-analysis.md`)
深入的技術分析，包含：
- 程式碼結構解析
- 關鍵功能說明
- 擴充建議

## 👥 適用對象

- Flutter 開發者
- DevOps 工程師
- 對自動化部署有興趣的開發者

## 📞 聯絡資訊

如有問題或建議，歡迎透過以下方式聯繫：
- GitHub Issues
- Pull Requests

## 📄 授權

本專案採用 MIT License 授權 - 詳見 [LICENSE](LICENSE) 檔案

簡單來說，你可以：
- ✅ 商業使用
- ✅ 修改
- ✅ 分發
- ✅ 私人使用

唯一要求：
- 📋 保留版權和授權聲明

更多授權選擇請參考 [LICENSE-GUIDE.md](LICENSE-GUIDE.md)

---
最後更新：2025-07-29