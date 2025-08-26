#!/bin/bash

# 無 Flavor 版本的 Android Firebase App Distribution 部署腳本
# 適用於沒有設定 Flavor 的 Flutter 專案

set -e  # 遇到錯誤時停止執行

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：打印帶顏色的訊息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 載入環境變數
load_env() {
    # 檢查 .env 檔案是否存在
    if [ -f .env ]; then
        print_message $BLUE "載入環境變數..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        print_message $YELLOW "警告: .env 檔案不存在，將使用系統環境變數"
    fi
}

# 驗證環境變數
validate_env() {
    # 檢查是否有設定 Firebase App ID
    if [ -z "$FIREBASE_APP_ID" ]; then
        print_message $RED "錯誤: 環境變數 FIREBASE_APP_ID 未設定"
        print_message $YELLOW "請在 .env 檔案中設定 FIREBASE_APP_ID"
        print_message $YELLOW "或設定系統環境變數 FIREBASE_APP_ID"
        exit 1
    fi
}

# 檢查 Flutter 專案是否有設定 Flavor
check_flutter_flavors() {
    print_message $BLUE "檢查 Flutter 專案 Flavor 設定..."
    
    # 檢查是否有 flavorizr.gradle.kts 檔案
    if [ -f "android/app/flavorizr.gradle.kts" ]; then
        print_message $YELLOW "檢測到 Flavor 設定檔案，建議使用有 Flavor 的部署腳本"
        print_message $YELLOW "但將繼續使用無 Flavor 模式部署"
        return 1
    fi
    
    # 檢查 build.gradle.kts 中是否有 flavor 相關設定
    if grep -q "flavorDimensions\|productFlavors" android/app/build.gradle.kts 2>/dev/null; then
        print_message $YELLOW "檢測到 build.gradle.kts 中有 Flavor 設定"
        print_message $YELLOW "但將繼續使用無 Flavor 模式部署"
        return 1
    fi
    
    print_message $GREEN "確認專案使用無 Flavor 模式"
    return 0
}

# 函數：部署到 Firebase App Distribution（無 Flavor 版本）
deploy_to_firebase_no_flavor() {
    local apk_path=$1

    print_message $BLUE "部署 Android APK 到 Firebase App Distribution..."
    
    # 準備 Firebase 命令
    local firebase_cmd="firebase appdistribution:distribute \"$apk_path\""
    
    # 添加測試群組
    if [[ -n "$TESTER_GROUP" ]]; then
        firebase_cmd="$firebase_cmd --groups \"$TESTER_GROUP\""
    fi
    
    # 添加發布說明
    if [[ -n "$RELEASE_NOTES_FILE" && -f "$RELEASE_NOTES_FILE" ]]; then
        firebase_cmd="$firebase_cmd --release-notes-file \"$RELEASE_NOTES_FILE\""
    fi
    
    # 使用環境變數中的 App ID
    firebase_cmd="$firebase_cmd --app \"$FIREBASE_APP_ID\""
    
    # 不顯示敏感的 App ID
    print_message $YELLOW "執行部署命令..."
    eval $firebase_cmd
    
    print_message $GREEN "Android APK 部署完成！"
}

# 函數：顯示使用說明
show_usage() {
    echo "使用方法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  -g, --group <group>          Firebase 測試群組 (可選)"
    echo "  -r, --release-notes <file>   發布說明檔案 (可選)"
    echo "  -h, --help                   顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0"
    echo "  $0 -g testers -r release_notes.txt"
    echo ""
    echo "環境變數設定:"
    echo "  FIREBASE_APP_ID: Firebase 應用程式 ID"
    echo "  TESTER_GROUP: 測試群組 (可選)"
    echo "  RELEASE_NOTES_FILE: 發布說明檔案路徑 (可選)"
    echo ""
    echo "請參考 .env.example 檔案進行設定"
}

# 檢查必要工具
check_requirements() {
    print_message $BLUE "檢查必要工具..."
    
    # 檢查 Flutter
    if ! command -v flutter &> /dev/null; then
        print_message $RED "錯誤: Flutter 未安裝或不在 PATH 中"
        exit 1
    fi
    
    # 檢查 Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_message $RED "錯誤: Firebase CLI 未安裝"
        print_message $YELLOW "請執行: npm install -g firebase-tools"
        exit 1
    fi
    
    # 檢查是否已登入 Firebase
    if ! firebase projects:list &> /dev/null; then
        print_message $RED "錯誤: 未登入 Firebase"
        print_message $YELLOW "請執行: firebase login"
        exit 1
    fi
    
    print_message $GREEN "所有必要工具檢查完成"
}

# 函數：建置 Android APK（無 Flavor）
build_android_apk_no_flavor() {
    print_message $BLUE "建置 Android APK (無 Flavor 模式)..."
    
    # 清理舊的建置檔案
    flutter clean
    
    # 取得套件
    flutter pub get
    
    # 建置 APK（無 Flavor）
    flutter build apk --release
    
    # 設定 APK 路徑（無 Flavor 的預設路徑）
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    
    if [[ ! -f "$APK_PATH" ]]; then
        print_message $RED "錯誤: APK 檔案未找到: $APK_PATH"
        print_message $YELLOW "請檢查建置是否成功完成"
        exit 1
    fi
    
    print_message $GREEN "Android APK 建置完成: $APK_PATH"
}

# 預設值
TESTER_GROUP=""
RELEASE_NOTES_FILE=""

# 解析命令列參數
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--group)
            TESTER_GROUP="$2"
            shift 2
            ;;
        -r|--release-notes)
            RELEASE_NOTES_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_message $RED "未知選項: $1"
            show_usage
            exit 1
            ;;
    esac
done

# 主執行流程
main() {
    # 載入環境變數
    load_env
    
    # 驗證環境變數
    validate_env
    
    print_message $GREEN "開始 Android Firebase App Distribution 部署流程 (無 Flavor 模式)"
    if [[ -n "$TESTER_GROUP" ]]; then
        print_message $BLUE "測試群組: $TESTER_GROUP"
    fi
    if [[ -n "$RELEASE_NOTES_FILE" ]]; then
        print_message $BLUE "發布說明檔案: $RELEASE_NOTES_FILE"
    fi
    echo ""
    
    # 檢查必要工具
    check_requirements
    
    # 檢查 Flutter 版本
    print_message $BLUE "Flutter 版本: $(flutter --version | head -n 1)"
    
    # 檢查 Flavor 設定
    check_flutter_flavors
    
    # 執行部署流程
    build_android_apk_no_flavor
    deploy_to_firebase_no_flavor $APK_PATH
    
    print_message $GREEN "Android 部署流程完成！"
    print_message $YELLOW "請檢查 Firebase Console 確認部署狀態"
    print_message $YELLOW "測試者將收到下載連結"
}

# 啟動主程序
main 