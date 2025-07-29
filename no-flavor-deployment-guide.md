# 無 Flavor Firebase App Distribution 部署指南

## 📋 概述

這個指南說明如何在沒有設定 Flutter Flavors 的情況下，使用 Firebase App Distribution 進行 Android 應用程式的自動化部署。

## 🎯 適用場景

- Flutter 專案沒有設定 Flavors
- 只需要部署單一版本的應用程式
- 簡化的部署流程
- 快速原型開發和測試

## 🚀 快速開始

### 1. 環境設定

#### 複製環境變數檔案
```bash
cp env.example.no-flavor .env
```

#### 編輯 .env 檔案
```bash
# 填入您的 Firebase App ID
FIREBASE_APP_ID=1:123456789:android:abcdef1234567890

# 可選：設定測試群組
TESTER_GROUP=testers

# 可選：設定發布說明檔案
RELEASE_NOTES_FILE=release_notes.txt
```

### 2. 執行部署

#### 基本部署
```bash
chmod +x deploy-without-flavor.sh
./deploy-without-flavor.sh
```

#### 指定測試群組
```bash
./deploy-without-flavor.sh -g testers
```

#### 指定發布說明檔案
```bash
./deploy-without-flavor.sh -r release_notes.txt
```

#### 同時指定群組和發布說明
```bash
./deploy-without-flavor.sh -g testers -r release_notes.txt
```

## 🔧 前置需求

### 1. Flutter 環境
- Flutter SDK 3.0+
- Android Studio
- Android SDK

### 2. Firebase 設定
- Firebase CLI 已安裝
- 已登入 Firebase 帳戶
- Firebase 專案已建立
- Android 應用程式已在 Firebase Console 中註冊

### 3. 安裝 Firebase CLI
```bash
# 使用 npm 安裝
npm install -g firebase-tools

# 或使用 brew (macOS)
brew install firebase-cli

# 驗證安裝
firebase --version
```

### 4. Firebase 登入
```bash
# 登入 Firebase
firebase login

# 確認登入狀態
firebase projects:list
```

## 📱 Firebase 專案設定

### 1. 建立 Android 應用程式
1. 前往 [Firebase Console](https://console.firebase.google.com)
2. 選擇您的專案
3. 點擊「新增應用程式」→「Android」
4. 輸入 Android 套件名稱（例如：`com.example.myapp`）
5. 下載 `google-services.json` 檔案

### 2. 設定 google-services.json
將下載的 `google-services.json` 檔案放置在：
```
android/app/google-services.json
```

### 3. 取得 Firebase App ID
在 Firebase Console 中：
1. 選擇您的 Android 應用程式
2. 點擊「專案設定」
3. 在「一般」標籤中找到「應用程式 ID」
4. 複製此 ID 到 `.env` 檔案的 `FIREBASE_APP_ID`

### 4. 啟用 App Distribution
1. 在 Firebase Console 中
2. 選擇「Release & Monitor」→「App Distribution」
3. 點擊「開始使用」

## 📝 腳本功能說明

### 主要功能
- **自動建置**：清理並建置 Android APK
- **Flavor 檢測**：自動檢測專案是否有 Flavor 設定
- **環境驗證**：檢查必要的環境變數和工具
- **安全部署**：使用環境變數保護敏感資訊
- **錯誤處理**：完善的錯誤檢查與提示

### 命令列選項
- `-g, --group <group>`：指定 Firebase 測試群組
- `-r, --release-notes <file>`：指定發布說明檔案
- `-h, --help`：顯示使用說明

### 環境變數
- `FIREBASE_APP_ID`：Firebase 應用程式 ID（必需）
- `TESTER_GROUP`：測試群組（可選）
- `RELEASE_NOTES_FILE`：發布說明檔案路徑（可選）

## 🔍 故障排除

### 常見問題

#### 1. Flutter 未安裝
```bash
# 錯誤訊息：Flutter 未安裝或不在 PATH 中
# 解決方案：安裝 Flutter SDK
flutter doctor
```

#### 2. Firebase CLI 未安裝
```bash
# 錯誤訊息：Firebase CLI 未安裝
# 解決方案：安裝 Firebase CLI
npm install -g firebase-tools
```

#### 3. 未登入 Firebase
```bash
# 錯誤訊息：未登入 Firebase
# 解決方案：登入 Firebase
firebase login
```

#### 4. 環境變數未設定
```bash
# 錯誤訊息：FIREBASE_APP_ID 未設定
# 解決方案：設定環境變數
echo "FIREBASE_APP_ID=your_app_id" >> .env
```

#### 5. APK 建置失敗
```bash
# 檢查 Flutter 專案設定
flutter doctor
flutter clean
flutter pub get
flutter build apk --release
```

#### 6. 部署失敗
```bash
# 檢查 Firebase App ID 是否正確
# 確認 google-services.json 檔案位置
# 驗證 Firebase 專案設定
```

## 📊 與有 Flavor 模式的比較

| 功能 | 無 Flavor 模式 | 有 Flavor 模式 |
|------|----------------|----------------|
| 設定複雜度 | 簡單 | 中等 |
| 部署速度 | 快速 | 中等 |
| 環境管理 | 單一環境 | 多環境 |
| 適用場景 | 原型開發、簡單專案 | 正式產品、多環境 |
| 維護成本 | 低 | 中等 |

## 🔄 從無 Flavor 升級到有 Flavor

如果您之後需要支援多環境部署，可以：

1. 參考 `implementation-guide.md` 設定 Flutter Flavors
2. 使用 `secure-deploy-example.sh` 腳本
3. 設定多個 Firebase 應用程式
4. 更新環境變數設定

## 📞 支援

如有問題或建議，請：
1. 檢查本文件的故障排除章節
2. 參考 `implementation-guide.md`
3. 查看 `security-guide.md` 了解安全最佳實踐
4. 提交 GitHub Issue

## 📄 相關文件

- [實作指南](implementation-guide.md)
- [安全指南](security-guide.md)
- [快速參考](quick-reference.md)
- [基本使用範例](dev/examples/basic-usage.md) 