# Firebase App Distribution 快速參考

## 🚀 快速命令

### 基本部署
```bash
# 開發版本
./scripts/deploy_android_firebase.sh -f development

# 測試版本
./scripts/deploy_android_firebase.sh -f staging

# 生產版本
./scripts/deploy_android_firebase.sh -f production
```

### 進階部署
```bash
# 指定測試群組
./scripts/deploy_android_firebase.sh -f staging -g qa-team

# 加入發布說明
./scripts/deploy_android_firebase.sh -f staging -r release_notes.txt

# 完整指令
./scripts/deploy_android_firebase.sh -f production -g beta-testers -r release_notes_v1.0.txt
```

## 📋 檢查清單

### 部署前檢查
- [ ] Flutter SDK 已安裝
- [ ] Firebase CLI 已安裝 (`npm install -g firebase-tools`)
- [ ] 已登入 Firebase (`firebase login`)
- [ ] 專案已設定 Flavors
- [ ] Firebase 專案已建立對應的應用程式

### 部署後確認
- [ ] Firebase Console 顯示新版本
- [ ] 測試者收到通知郵件
- [ ] APK 可以正常下載安裝
- [ ] 版本號碼正確

## 🔧 環境設定

### Firebase App ID
```bash
# 在腳本中更新 App ID
# 格式: 1:PROJECT_NUMBER:android:APP_ID
development: YOUR_DEVELOPMENT_APP_ID
staging:     YOUR_STAGING_APP_ID
production:  YOUR_PRODUCTION_APP_ID
```

### Flavor 設定
```kotlin
// android/app/flavorizr.gradle.kts
productFlavors {
    create("development") {
        applicationId = "com.uspace.uspacepremium.dev"
    }
    create("staging") {
        applicationId = "com.uspace.uspacepremium.staging"
    }
    create("production") {
        applicationId = "com.uspace"
    }
}
```

## 🛠️ 故障排除

### 常見錯誤
| 錯誤訊息 | 解決方法 |
|---------|---------|
| Flutter 未安裝 | 安裝 Flutter SDK 並加入 PATH |
| Firebase CLI 未安裝 | `npm install -g firebase-tools` |
| 未登入 Firebase | `firebase login` |
| APK 建置失敗 | `flutter clean && flutter pub get` |
| App ID 錯誤 | 從 Firebase Console 複製正確的 App ID |

### 除錯命令
```bash
# 檢查 Flutter
flutter doctor

# 檢查 Firebase
firebase --version
firebase projects:list

# 手動建置測試
flutter build apk --flavor staging --release

# 查看 APK 位置
ls -la build/app/outputs/flutter-apk/
```

## 📝 發布說明模板

```markdown
版本: 1.0.0
日期: 2025-01-22

新功能:
- 功能描述 1
- 功能描述 2

修復:
- 修復問題 1
- 修復問題 2

已知問題:
- 問題描述

測試重點:
- 請測試新功能
- 確認問題已修復
```

## 🔗 重要連結

- [Firebase Console](https://console.firebase.google.com)
- [Firebase App Distribution 文件](https://firebase.google.com/docs/app-distribution)
- [Flutter Flavors 文件](https://docs.flutter.dev/deployment/flavors)

## 💡 小技巧

1. **建立別名**
   ```bash
   # 在 ~/.bashrc 或 ~/.zshrc 中加入
   alias deploy-dev='./scripts/deploy_android_firebase.sh -f development'
   alias deploy-staging='./scripts/deploy_android_firebase.sh -f staging -g qa-team'
   ```

2. **自動產生發布說明**
   ```bash
   git log --oneline -10 > release_notes.txt
   ```

3. **批次部署**
   ```bash
   for flavor in development staging; do
       ./scripts/deploy_android_firebase.sh -f $flavor
   done
   ```

---
快速參考卡 v1.0 | 2025-07-29