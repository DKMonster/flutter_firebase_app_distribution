#!/bin/bash

# 安全版本的 Android Firebase App Distribution 部署腳本
# 使用環境變數來保護敏感資訊

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
    local flavor=$1
    local app_id_var=""
    
    case $flavor in
        "development")
            app_id_var="FIREBASE_APP_ID_DEVELOPMENT"
            ;;
        "staging")
            app_id_var="FIREBASE_APP_ID_STAGING"
            ;;
        "production")
            app_id_var="FIREBASE_APP_ID_PRODUCTION"
            ;;
    esac
    
    # 檢查 App ID 是否設定
    if [ -z "${!app_id_var}" ]; then
        print_message $RED "錯誤: 環境變數 $app_id_var 未設定"
        print_message $YELLOW "請設定環境變數或建立 .env 檔案"
        exit 1
    fi
}

# 函數：部署到 Firebase App Distribution（安全版本）
deploy_to_firebase_secure() {
    local flavor=$1
    local apk_path=$2
    
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
    
    # 根據 Flavor 使用對應的應用程式 ID（從環境變數讀取）
    case $flavor in
        "development")
            firebase_cmd="$firebase_cmd --app \"$FIREBASE_APP_ID_DEVELOPMENT\""
            ;;
        "staging")
            firebase_cmd="$firebase_cmd --app \"$FIREBASE_APP_ID_STAGING\""
            ;;
        "production")
            firebase_cmd="$firebase_cmd --app \"$FIREBASE_APP_ID_PRODUCTION\""
            ;;
    esac
    
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
    echo "  -f, --flavor <flavor>        指定 Flavor (development|staging|production)"
    echo "  -g, --group <group>          Firebase 測試群組 (可選)"
    echo "  -r, --release-notes <file>   發布說明檔案 (可選)"
    echo "  -h, --help                   顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 -f staging"
    echo "  $0 -f production -g testers -r release_notes.txt"
    echo ""
    echo "環境變數設定:"
    echo "  請參考 .env.example 檔案"
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

# 函數：建置 Android APK
build_android_apk() {
    local flavor=$1
    print_message $BLUE "建置 Android APK (Flavor: $flavor)..."
    
    # 清理舊的建置檔案
    flutter clean
    
    # 取得套件
    flutter pub get
    
    # 建置 APK
    flutter build apk --flavor $flavor --release
    
    # 設定 APK 路徑
    APK_PATH="build/app/outputs/flutter-apk/app-${flavor}-release.apk"
    
    if [[ ! -f "$APK_PATH" ]]; then
        print_message $RED "錯誤: APK 檔案未找到: $APK_PATH"
        exit 1
    fi
    
    print_message $GREEN "Android APK 建置完成: $APK_PATH"
}

# 預設值
FLAVOR=""
TESTER_GROUP=""
RELEASE_NOTES_FILE=""

# 解析命令列參數
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--flavor)
            FLAVOR="$2"
            shift 2
            ;;
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

# 驗證必要參數
if [[ -z "$FLAVOR" ]]; then
    print_message $RED "錯誤: 必須指定 Flavor (-f 或 --flavor)"
    show_usage
    exit 1
fi

# 驗證 Flavor 參數
if [[ "$FLAVOR" != "development" && "$FLAVOR" != "staging" && "$FLAVOR" != "production" ]]; then
    print_message $RED "錯誤: Flavor 必須是 development、staging 或 production"
    exit 1
fi

# 主執行流程
main() {
    # 載入環境變數
    load_env
    
    # 驗證環境變數
    validate_env $FLAVOR
    
    print_message $GREEN "開始 Android Firebase App Distribution 部署流程"
    print_message $BLUE "Flavor: $FLAVOR"
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
    
    # 執行部署流程
    build_android_apk $FLAVOR
    deploy_to_firebase_secure $FLAVOR $APK_PATH
    
    print_message $GREEN "Android 部署流程完成！"
    print_message $YELLOW "請檢查 Firebase Console 確認部署狀態"
    print_message $YELLOW "測試者將收到下載連結"
}

# 啟動主程序
main