#!/bin/bash

# 無 Flavor 部署腳本測試工具
# 用於驗證部署腳本的基本功能

set -e

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

# 測試項目
test_script_exists() {
    print_message $BLUE "測試 1: 檢查部署腳本是否存在"
    if [ -f "deploy-without-flavor.sh" ]; then
        print_message $GREEN "✅ 部署腳本存在"
        return 0
    else
        print_message $RED "❌ 部署腳本不存在"
        return 1
    fi
}

test_script_permissions() {
    print_message $BLUE "測試 2: 檢查腳本執行權限"
    if [ -x "deploy-without-flavor.sh" ]; then
        print_message $GREEN "✅ 腳本具有執行權限"
        return 0
    else
        print_message $RED "❌ 腳本沒有執行權限"
        return 1
    fi
}

test_env_example_exists() {
    print_message $BLUE "測試 3: 檢查環境變數範例檔案"
    if [ -f "env.example.no-flavor" ]; then
        print_message $GREEN "✅ 環境變數範例檔案存在"
        return 0
    else
        print_message $RED "❌ 環境變數範例檔案不存在"
        return 1
    fi
}

test_help_option() {
    print_message $BLUE "測試 4: 檢查幫助選項"
    if ./deploy-without-flavor.sh --help &> /dev/null; then
        print_message $GREEN "✅ 幫助選項正常運作"
        return 0
    else
        print_message $RED "❌ 幫助選項無法運作"
        return 1
    fi
}

test_script_syntax() {
    print_message $BLUE "測試 5: 檢查腳本語法"
    if bash -n deploy-without-flavor.sh; then
        print_message $GREEN "✅ 腳本語法正確"
        return 0
    else
        print_message $RED "❌ 腳本語法錯誤"
        return 1
    fi
}

test_documentation_exists() {
    print_message $BLUE "測試 6: 檢查文件是否存在"
    local docs=("no-flavor-deployment-guide.md" "release_notes_example.txt")
    local all_exist=true
    
    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            print_message $GREEN "✅ $doc 存在"
        else
            print_message $RED "❌ $doc 不存在"
            all_exist=false
        fi
    done
    
    if [ "$all_exist" = true ]; then
        return 0
    else
        return 1
    fi
}

# 主測試函數
main() {
    print_message $GREEN "開始無 Flavor 部署腳本測試"
    echo ""
    
    local tests=(
        "test_script_exists"
        "test_script_permissions"
        "test_env_example_exists"
        "test_help_option"
        "test_script_syntax"
        "test_documentation_exists"
    )
    
    local passed=0
    local total=${#tests[@]}
    
    for test in "${tests[@]}"; do
        if $test; then
            ((passed++))
        fi
        echo ""
    done
    
    # 顯示測試結果
    print_message $BLUE "測試結果摘要:"
    print_message $GREEN "通過: $passed/$total"
    
    if [ $passed -eq $total ]; then
        print_message $GREEN "🎉 所有測試通過！無 Flavor 部署腳本已準備就緒"
        echo ""
        print_message $YELLOW "下一步："
        print_message $YELLOW "1. 複製 env.example.no-flavor 為 .env"
        print_message $YELLOW "2. 在 .env 中設定 FIREBASE_APP_ID"
        print_message $YELLOW "3. 執行 ./deploy-without-flavor.sh"
    else
        print_message $RED "⚠️  部分測試失敗，請檢查上述問題"
    fi
}

# 執行測試
main 