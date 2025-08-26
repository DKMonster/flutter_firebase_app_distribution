#!/bin/bash

# 有 Flavor 版本的 Android Firebase App Distribution 部署腳本
# 適用於有設定 Flavor 的 Flutter 專案

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
        print_message $YELLOW "請在 .env 檔案中設定 $app_id_var"
        print_message $YELLOW "或設定系統環境變數 $app_id_var"
        exit 1
    fi

    print_message $GREEN "✅ 已找到 Firebase App ID: ${!app_id_var:0:10}..."
}

# 取得版本號碼
get_version() {
    local yaml_file="pubspec.yaml"
    if [ -f "$yaml_file" ]; then
        version=$(grep "^version:" "$yaml_file" | sed 's/version: //')
        # 輸出訊息到 stderr 避免干擾返回值
        print_message $BLUE "📦 當前版本: $version" >&2
        echo "$version"
    else
        print_message $RED "錯誤: 找不到 pubspec.yaml 檔案"
        print_message $YELLOW "請確保在 Flutter 專案根目錄下執行此腳本"
        print_message $YELLOW "當前目錄: $(pwd)"
        exit 1
    fi
}

# 建置 APK 或 AAB
build_app() {
    local flavor=$1
    local build_type=${2:-apk}  # 預設建置 APK

    print_message $BLUE "🔨 開始建置 $flavor $build_type..."

    # 清理之前的建置
    print_message $YELLOW "清理之前的建置..."
    flutter clean

    # 取得 packages
    print_message $YELLOW "取得 packages..."
    flutter pub get

    # 建置應用程式
    if [ "$build_type" = "aab" ]; then
        print_message $BLUE "建置 AAB (App Bundle)..."
        flutter build appbundle \
            --flavor $flavor \
            --release

        # AAB 檔案位置
        BUILD_OUTPUT="build/app/outputs/bundle/${flavor}Release/app-${flavor}-release.aab"
    else
        print_message $BLUE "建置 APK..."
        flutter build apk \
            --flavor $flavor \
            --release

        # APK 檔案位置
        BUILD_OUTPUT="build/app/outputs/flutter-apk/app-${flavor}-release.apk"
    fi

    # 檢查建置結果
    if [ -f "$BUILD_OUTPUT" ]; then
        print_message $GREEN "✅ 建置成功！"
        print_message $BLUE "📁 檔案位置: $BUILD_OUTPUT"

        # 顯示檔案大小
        size=$(ls -lh "$BUILD_OUTPUT" | awk '{print $5}')
        print_message $BLUE "📊 檔案大小: $size"
    else
        print_message $RED "❌ 建置失敗：找不到輸出檔案"
        exit 1
    fi
}

# 部署到 Firebase App Distribution
deploy_to_firebase() {
    local flavor=$1
    local build_type=${2:-apk}
    local release_notes=${3:-"新版本發布 - $flavor $(date +'%Y-%m-%d %H:%M')"}

    # 取得對應的 App ID
    local app_id_var=""
    local tester_group_var=""

    case $flavor in
        "development")
            app_id_var="FIREBASE_APP_ID_DEVELOPMENT"
            tester_group_var="DEFAULT_TESTER_GROUP_DEV"
            ;;
        "staging")
            app_id_var="FIREBASE_APP_ID_STAGING"
            tester_group_var="DEFAULT_TESTER_GROUP_STAGING"
            ;;
        "production")
            app_id_var="FIREBASE_APP_ID_PRODUCTION"
            tester_group_var="DEFAULT_TESTER_GROUP_PRODUCTION"
            ;;
    esac

    local app_id="${!app_id_var}"
    local tester_group="${!tester_group_var}"

    print_message $BLUE "🚀 開始部署到 Firebase App Distribution..."
    print_message $YELLOW "📝 Flavor: $flavor"
    print_message $YELLOW "📱 App ID: ${app_id:0:10}..."

    # 設定檔案路徑
    if [ "$build_type" = "aab" ]; then
        file_path="build/app/outputs/bundle/${flavor}Release/app-${flavor}-release.aab"
    else
        file_path="build/app/outputs/flutter-apk/app-${flavor}-release.apk"
    fi

    # 檢查檔案是否存在
    if [ ! -f "$file_path" ]; then
        print_message $RED "錯誤: 找不到建置檔案 $file_path"
        exit 1
    fi

    # 準備發布說明
    if [ -f "release_notes.txt" ]; then
        print_message $YELLOW "使用 release_notes.txt 作為發布說明"
        release_notes_file="release_notes.txt"
    else
        # 建立臨時發布說明檔案
        echo "$release_notes" > temp_release_notes.txt
        release_notes_file="temp_release_notes.txt"
    fi

    # 執行部署
    if [ -n "$tester_group" ]; then
        print_message $YELLOW "👥 測試群組: $tester_group"
        firebase appdistribution:distribute "$file_path" \
            --app "$app_id" \
            --release-notes-file "$release_notes_file" \
            --groups "$tester_group"
    else
        firebase appdistribution:distribute "$file_path" \
            --app "$app_id" \
            --release-notes-file "$release_notes_file"
    fi

    # 清理臨時檔案
    [ -f "temp_release_notes.txt" ] && rm temp_release_notes.txt

    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 部署成功！"
        print_message $BLUE "📱 已發布到 Firebase App Distribution ($flavor)"
    else
        print_message $RED "❌ 部署失敗"
        exit 1
    fi
}

# 顯示使用說明
show_usage() {
    echo "使用方法: $0 -f <flavor> [選項]"
    echo ""
    echo "必要參數:"
    echo "  -f <flavor>    指定 flavor (development|staging|production)"
    echo ""
    echo "選項:"
    echo "  -t <type>      建置類型 (apk|aab)，預設: apk"
    echo "  -n <notes>     發布說明"
    echo "  -b             只建置，不部署"
    echo "  -d             只部署，不建置（需要已存在的建置檔案）"
    echo "  -h             顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 -f development                    # 建置並部署開發版 APK"
    echo "  $0 -f staging -t aab                 # 建置並部署測試版 AAB"
    echo "  $0 -f production -b                  # 只建置生產版，不部署"
    echo "  $0 -f staging -d                     # 只部署已建置的測試版"
    echo "  $0 -f development -n \"修復錯誤\"      # 部署並附上發布說明"
}

# 主程式
main() {
    local flavor=""
    local build_type="apk"
    local release_notes=""
    local build_only=false
    local deploy_only=false

    # 解析命令列參數
    while getopts "f:t:n:bdh" opt; do
        case $opt in
            f)
                flavor="$OPTARG"
                ;;
            t)
                build_type="$OPTARG"
                ;;
            n)
                release_notes="$OPTARG"
                ;;
            b)
                build_only=true
                ;;
            d)
                deploy_only=true
                ;;
            h)
                show_usage
                exit 0
                ;;
            \?)
                print_message $RED "無效的選項: -$OPTARG"
                show_usage
                exit 1
                ;;
        esac
    done

    # 檢查必要參數
    if [ -z "$flavor" ]; then
        print_message $RED "錯誤: 請指定 flavor"
        show_usage
        exit 1
    fi

    # 驗證 flavor
    if [[ ! "$flavor" =~ ^(development|staging|production)$ ]]; then
        print_message $RED "錯誤: 無效的 flavor: $flavor"
        print_message $YELLOW "有效的 flavor: development, staging, production"
        exit 1
    fi

    # 驗證建置類型
    if [[ ! "$build_type" =~ ^(apk|aab)$ ]]; then
        print_message $RED "錯誤: 無效的建置類型: $build_type"
        print_message $YELLOW "有效的類型: apk, aab"
        exit 1
    fi

    # 檢查互斥選項
    if [ "$build_only" = true ] && [ "$deploy_only" = true ]; then
        print_message $RED "錯誤: -b 和 -d 選項不能同時使用"
        exit 1
    fi

    print_message $GREEN "========================================="
    print_message $GREEN "🚀 Firebase App Distribution 自動部署"
    print_message $GREEN "========================================="

    # 載入環境變數
    load_env

    # 驗證環境變數
    validate_env "$flavor"

    # 顯示版本資訊
    version=$(get_version)

    if [ "$deploy_only" = true ]; then
        # 只部署
        print_message $BLUE "📦 跳過建置，直接部署..."
        deploy_to_firebase "$flavor" "$build_type" "$release_notes"
    elif [ "$build_only" = true ]; then
        # 只建置
        build_app "$flavor" "$build_type"
        print_message $BLUE "📦 建置完成，跳過部署"
    else
        # 建置並部署
        build_app "$flavor" "$build_type"
        deploy_to_firebase "$flavor" "$build_type" "$release_notes"
    fi

    print_message $GREEN "========================================="
    print_message $GREEN "✨ 所有操作完成！"
    print_message $GREEN "========================================="
}

# 執行主程式
main "$@"