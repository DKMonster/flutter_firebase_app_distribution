# 安全性指南

## 🔐 機密資訊管理

### 需要保護的敏感資訊

1. **Firebase App IDs**
   - 格式：`1:PROJECT_NUMBER:android:APP_ID`
   - 每個環境（development、staging、production）都有獨立的 ID

2. **Firebase Project ID**
   - 用於識別 Firebase 專案
   - 顯示在 Firebase Console URL 中

3. **簽名憑證資訊**
   - Keystore 檔案路徑
   - Keystore 密碼
   - Key alias 和密碼

4. **API Keys**
   - Google Maps API Key
   - 其他第三方服務金鑰

### 保護方式

#### 1. 使用環境變數
```bash
# 在腳本中使用環境變數
firebase_cmd="$firebase_cmd --app ${FIREBASE_APP_ID_STAGING}"
```

#### 2. 使用 .env 檔案
```bash
# 載入環境變數
if [ -f .env ]; then
    export $(cat .env | xargs)
fi
```

#### 3. 使用 secrets.properties（Android 專用）
```kotlin
// build.gradle.kts
val secretsFile = rootProject.file("secrets.properties")
val secrets = Properties()
if (secretsFile.exists()) {
    secrets.load(FileInputStream(secretsFile))
}
```

### Git 設定

#### .gitignore 必要項目
```gitignore
# 環境變數
.env
.env.local
.env.*.local

# Android 機密檔案
secrets.properties
*.keystore
*.jks

# Firebase 設定
google-services.json
GoogleService-Info.plist

# 個人設定
local.properties
```

### CI/CD 環境變數設定

#### GitHub Actions
```yaml
env:
  FIREBASE_APP_ID_STAGING: ${{ secrets.FIREBASE_APP_ID_STAGING }}
```

#### GitLab CI
```yaml
variables:
  FIREBASE_APP_ID_STAGING: $FIREBASE_APP_ID_STAGING
```

## 🛡️ 最佳實踐

### 1. 定期輪換密鑰
- 每季更新簽名憑證密碼
- 定期檢查 API Key 使用情況
- 移除不再使用的憑證

### 2. 最小權限原則
- 只給予必要的 Firebase 權限
- 使用服務帳號而非個人帳號
- 定期審查存取權限

### 3. 監控與稽核
- 啟用 Firebase 稽核日誌
- 監控異常的部署活動
- 設定警報通知

### 4. 安全的本地開發
```bash
# 使用加密的憑證儲存
# macOS
security add-generic-password -a "$USER" -s "firebase-app-id" -w "YOUR_APP_ID"

# 讀取憑證
FIREBASE_APP_ID=$(security find-generic-password -a "$USER" -s "firebase-app-id" -w)
```

## 📋 安全檢查清單

部署前檢查：
- [ ] 所有機密資訊都已從程式碼中移除
- [ ] .gitignore 正確設定
- [ ] 環境變數正確載入
- [ ] 沒有在日誌中輸出敏感資訊
- [ ] CI/CD 使用加密的環境變數

定期檢查：
- [ ] 審查 Git 歷史記錄中的敏感資訊
- [ ] 更新過期的憑證
- [ ] 檢查 Firebase 存取日誌
- [ ] 驗證測試群組成員

## 🚨 緊急應變

### 如果機密資訊外洩：

1. **立即行動**
   - 在 Firebase Console 撤銷受影響的憑證
   - 產生新的 App ID（如果需要）
   - 更新所有相關的環境變數

2. **清理 Git 歷史**
   ```bash
   # 使用 BFG Repo-Cleaner
   bfg --delete-files secrets.properties
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```

3. **通知相關人員**
   - 通知開發團隊
   - 更新文件
   - 記錄事件

## 🔗 相關資源

- [Firebase 安全性最佳實踐](https://firebase.google.com/docs/rules/basics)
- [GitHub 密碼掃描](https://docs.github.com/en/code-security/secret-scanning)
- [Git 敏感資料移除指南](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

---
安全指南 v1.0 | 2025-07-29