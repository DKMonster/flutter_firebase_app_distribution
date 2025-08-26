# Firebase App Distribution 自動化部署

Flutter 專案的 Firebase App Distribution 自動化部署解決方案，支援 Android 應用程式的快速部署。

## 🎯 部署模式

### 1. 有 Flavor 模式（多環境）
適用於需要區分多個環境的正式專案：
- **development**：開發環境
- **staging**：測試環境  
- **production**：正式環境

**使用腳本**: `deploy-with-flavor.sh`

### 2. 無 Flavor 模式（單一環境）
適用於簡單專案或原型開發：
- 不需要複雜的環境設定
- 快速部署單一版本

**使用腳本**: `deploy-without-flavor.sh`

## 🚀 快速開始

### 環境設定

#### 有 Flavor 模式
1. 複製 `.env.example` 為 `.env`
2. 填入各環境的 Firebase App ID：
   ```bash
   FIREBASE_APP_ID_DEVELOPMENT=your_dev_app_id
   FIREBASE_APP_ID_STAGING=your_staging_app_id
   FIREBASE_APP_ID_PRODUCTION=your_prod_app_id
   ```
3. 確保 `.env` 已加入 `.gitignore`

#### 無 Flavor 模式
1. 複製 `env.example.no-flavor` 為 `.env`
2. 填入單一 Firebase App ID：
   ```bash
   FIREBASE_APP_ID=your_app_id_here
   ```
3. 確保 `.env` 已加入 `.gitignore`

### 執行部署

#### 有 Flavor 模式
```bash
# 基本使用
./deploy-with-flavor.sh -f development

# 部署測試環境 AAB
./deploy-with-flavor.sh -f staging -t aab

# 只建置不部署
./deploy-with-flavor.sh -f production -b

# 附加發布說明
./deploy-with-flavor.sh -f development -n "修復登入問題"
```

#### 無 Flavor 模式
```bash
# 基本部署
./deploy-without-flavor.sh

# 指定建置類型
./deploy-without-flavor.sh -t aab

# 只建置不部署
./deploy-without-flavor.sh -b
```

## 📁 專案檔案

| 檔案 | 說明 |
|------|------|
| `deploy-with-flavor.sh` | 有 Flavor 模式部署腳本 |
| `deploy-without-flavor.sh` | 無 Flavor 模式部署腳本 |
| `.env.example` | 有 Flavor 環境變數範例 |
| `env.example.no-flavor` | 無 Flavor 環境變數範例 |
| `release_notes_example.txt` | 發布說明範例 |

## 🛠 前置需求

1. **Flutter SDK** - 已安裝並設定環境變數
2. **Firebase CLI** - 已安裝並登入：
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
3. **Firebase 專案** - 已建立並設定 App Distribution

## 📝 命令參數說明

### 有 Flavor 模式 (`deploy-with-flavor.sh`)
```
-f <flavor>    指定環境 (development|staging|production) [必要]
-t <type>      建置類型 (apk|aab)，預設: apk
-n <notes>     發布說明
-b             只建置，不部署
-d             只部署，不建置
-h             顯示說明
```

### 無 Flavor 模式 (`deploy-without-flavor.sh`)
```
-t <type>      建置類型 (apk|aab)，預設: apk
-n <notes>     發布說明  
-b             只建置，不部署
-d             只部署，不建置
-h             顯示說明
```

## ⚙️ 環境變數說明

### 必要變數
- `FIREBASE_APP_ID_*` - 各環境的 Firebase App ID（有 Flavor）
- `FIREBASE_APP_ID` - Firebase App ID（無 Flavor）

### 可選變數
- `DEFAULT_TESTER_GROUP_*` - 測試群組名稱
- `ENABLE_DEBUG_OUTPUT` - 除錯輸出開關
- `AUTO_INCREMENT_VERSION` - 自動增加版本號

## 🔍 常見問題

### Q: 如何取得 Firebase App ID？
A: 在 Firebase Console > 專案設定 > 您的應用程式 > App ID

### Q: APK 和 AAB 的差異？
A: 
- **APK**: 直接安裝檔，適合測試
- **AAB**: App Bundle，適合上架 Google Play

### Q: 如何新增測試人員？
A: Firebase Console > App Distribution > 測試人員和群組

## 📄 授權

MIT License