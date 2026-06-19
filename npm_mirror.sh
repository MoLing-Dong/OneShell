#!/bin/bash

##############################################################################
# NPM Registry Mirror Configuration Manager
# Description: Set, view, and reset npm registry mirror configuration.
#              Supports multiple popular npm mirrors. Includes built-in
#              network detection and speed testing.
# Usage: bash npm_mirror.sh
##############################################################################

set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Language settings (default: English)
LANG_SELECTION="en"

# ── Translations ────────────────────────────────────────────────────────────

# English
TR_en_TITLE="NPM Registry Mirror Manager"
TR_en_WELCOME="Welcome to NPM Mirror Manager"
TR_en_SELECT_LANG="Please select your language / 请选择你的语言:"
TR_en_SELECT_OP="Please select operation:"
TR_en_VIEW="View Current Registry"
TR_en_SET="Set Registry Mirror"
TR_en_RESET="Reset to Default (npmjs.org)"
TR_en_SPEED_TEST="Speed Test & Recommend"
TR_en_EXIT="Exit"
TR_en_ENTER_CHOICE="Enter your choice (1-5): "
TR_en_INVALID_CHOICE="Invalid choice, exiting..."
TR_en_CURRENT_REGISTRY="Current npm registry:"
TR_en_DEFAULT_REGISTRY="Default npm registry (npmjs.org)"
TR_en_REGISTRY_SET="Registry has been set to:"
TR_en_REGISTRY_RESET="Registry has been reset to default:"
TR_en_SELECT_MIRROR="Select a mirror:"
TR_en_ENTER_MIRROR_CHOICE="Enter your choice (1-%d): "
TR_en_INVALID_MIRROR="Invalid choice"
TR_en_CONFIRM_SET="Set registry to %s? (y/n): "
TR_en_OPERATION_CANCELLED="Operation cancelled"
TR_en_NPM_NOT_FOUND="npm is not installed or not found in PATH. Please install Node.js first."
TR_en_TESTING_SPEED="Testing mirror speed, please wait..."
TR_en_SPEED_FAIL="Unreachable"
TR_en_SPEED_RANK="Speed test results (fastest first):"
TR_en_PRESS_ENTER="Press Enter to return to menu..."
TR_en_ENTER_CUSTOM="Enter custom registry URL"
TR_en_CUSTOM_URL_PROMPT="Enter registry URL: "
TR_en_INVALID_URL="Invalid URL. URL must start with http:// or https://"
TR_en_NPMRC_LOCATION="Config file location:"
TR_en_DETECTING="Detecting network environment..."
TR_en_PUBLIC_IP="Public IP"
TR_en_LOCATION="Location"
TR_en_RECOMMENDED="Recommended mirror for your network:"
TR_en_CURRENT_MIRROR="Currently configured:"
TR_en_ALREADY_BEST="You are already using the best available mirror!"
TR_en_SWITCH_RECOMMEND="Consider switching to the recommended mirror above for better speed."
TR_en_MIRROR_STATUS_OK="Available"
TR_en_MIRROR_STATUS_SLOW="Slow"
TR_en_MIRROR_STATUS_FAIL="Down"

# Chinese
TR_zh_TITLE="NPM 镜像源配置管理器"
TR_zh_WELCOME="欢迎使用 NPM 镜像管理器"
TR_zh_SELECT_LANG="请选择你的语言 / Please select your language:"
TR_zh_SELECT_OP="请选择操作:"
TR_zh_VIEW="查看当前镜像源"
TR_zh_SET="设置镜像源"
TR_zh_RESET="恢复默认源 (npmjs.org)"
TR_zh_SPEED_TEST="测速并推荐镜像源"
TR_zh_EXIT="退出"
TR_zh_ENTER_CHOICE="请输入你的选择 (1-5): "
TR_zh_INVALID_CHOICE="无效选择，退出..."
TR_zh_CURRENT_REGISTRY="当前 npm 镜像源:"
TR_zh_DEFAULT_REGISTRY="默认 npm 镜像源 (npmjs.org)"
TR_zh_REGISTRY_SET="镜像源已设置为:"
TR_zh_REGISTRY_RESET="镜像源已恢复为默认:"
TR_zh_SELECT_MIRROR="请选择镜像源:"
TR_zh_ENTER_MIRROR_CHOICE="请输入你的选择 (1-%d): "
TR_zh_INVALID_MIRROR="无效选择"
TR_zh_CONFIRM_SET="确认设置镜像源为 %s？(y/n): "
TR_zh_OPERATION_CANCELLED="操作已取消"
TR_zh_NPM_NOT_FOUND="未找到 npm，请先安装 Node.js"
TR_zh_TESTING_SPEED="正在测速镜像源，请稍候..."
TR_zh_SPEED_FAIL="不可达"
TR_zh_SPEED_RANK="测速结果 (速度从快到慢):"
TR_zh_PRESS_ENTER="按回车键返回菜单..."
TR_zh_ENTER_CUSTOM="输入自定义镜像地址"
TR_zh_CUSTOM_URL_PROMPT="请输入镜像地址: "
TR_zh_INVALID_URL="无效地址，地址必须以 http:// 或 https:// 开头"
TR_zh_NPMRC_LOCATION="配置文件位置:"
TR_zh_DETECTING="正在检测网络环境..."
TR_zh_PUBLIC_IP="公网 IP"
TR_zh_LOCATION="归属地"
TR_zh_RECOMMEND="为您推荐的镜像源:"
TR_zh_CURRENT_MIRROR="当前使用的镜像源:"
TR_zh_ALREADY_BEST="当前已是最佳镜像源，无需切换！"
TR_zh_SWITCH_RECOMMEND="建议切换到上方推荐的镜像源以获得更快的速度。"
TR_zh_MIRROR_STATUS_OK="可用"
TR_zh_MIRROR_STATUS_SLOW="较慢"
TR_zh_MIRROR_STATUS_FAIL="不可用"

# ── Print functions ──────────────────────────────────────────────────────────

print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[OK]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Translation helper
tr() {
    local key=$1
    local var_name="TR_${LANG_SELECTION}_${key}"
    echo -n "${!var_name}"
}

# ── Language selection ───────────────────────────────────────────────────────

select_language() {
    echo
    echo "================================================"
    echo "$(tr SELECT_LANG)"
    echo "================================================"
    echo
    echo "1) English"
    echo "2) 中文 (Chinese)"
    echo
    read -p "Enter your choice (1-2): " -r < /dev/tty
    echo
    case $REPLY in
        1) LANG_SELECTION="en" ;;
        2) LANG_SELECTION="zh" ;;
        *) LANG_SELECTION="en" ;;
    esac
}

# ── Mirror definitions ──────────────────────────────────────────────────────
#
# Each mirror: "display_name|registry_url"
# Order does not matter — speed test will sort them.
# Mirrors are validated; only those returning HTTP 2xx/3xx for a known package
# are considered "available".

get_mirror_list() {
    if [[ "$LANG_SELECTION" == "zh" ]]; then
        cat << 'EOF'
淘宝 npmmirror (推荐)|https://registry.npmmirror.com/
腾讯云|https://mirrors.tencent.com/npm/
华为云|https://repo.huaweicloud.com/repository/npm/
官方 npmjs.org|https://registry.npmjs.org/
EOF
    else
        cat << 'EOF'
npmmirror (Taobao)|https://registry.npmmirror.com/
Tencent Cloud|https://mirrors.tencent.com/npm/
Huawei Cloud|https://repo.huaweicloud.com/repository/npm/
Default npmjs.org|https://registry.npmjs.org/
EOF
    fi
}

# ── Network detection ───────────────────────────────────────────────────────

detect_network() {
    echo
    echo "================================================"
    echo "$(tr DETECTING)"
    echo "================================================"
    echo

    local ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || \
               curl -s --connect-timeout 5 ip.sb 2>/dev/null || \
               echo "unknown")

    local geo=""
    if [[ "$ip" != "unknown" ]]; then
        geo=$(curl -s --connect-timeout 5 "https://ipinfo.io/${ip}" 2>/dev/null | \
              grep -oP '"city":\s*"\K[^"]+' || echo "")
        local region=$(curl -s --connect-timeout 5 "https://ipinfo.io/${ip}" 2>/dev/null | \
                       grep -oP '"region":\s*"\K[^"]+' || echo "")
        local country=$(curl -s --connect-timeout 5 "https://ipinfo.io/${ip}" 2>/dev/null | \
                        grep -oP '"country":\s*"\K[^"]+' || echo "")
        if [[ -n "$geo" && -n "$country" ]]; then
            geo="${geo}, ${region:+${region}, }${country}"
        else
            geo="N/A"
        fi
    fi

    printf "  ${BOLD}%-12s${NC} %s\n" "$(tr PUBLIC_IP):" "$ip"
    printf "  ${BOLD}%-12s${NC} %s\n" "$(tr LOCATION):" "${geo:-N/A}"
}

# ── Speed test ───────────────────────────────────────────────────────────────
#
# Tests each mirror by fetching metadata for the "express" package.
# Returns results sorted by response time.  Fills global arrays:
#   SPEED_NAMES[]  SPEED_URLS[]  SPEED_MS[]  SPEED_STATUS[]

SPEED_NAMES=()
SPEED_URLS=()
SPEED_MS=()
SPEED_STATUS=()

run_speed_test() {
    SPEED_NAMES=()
    SPEED_URLS=()
    SPEED_MS=()
    SPEED_STATUS=()

    echo
    echo "================================================"
    echo "$(tr SPEED_TEST)"
    echo "================================================"
    echo
    print_info "$(tr TESTING_SPEED)"
    echo

    while IFS='|' read -r name url; do
        [[ -z "$name" ]] && continue
        local test_url="${url}express"

        local result=$(curl -o /dev/null -s -w "%{http_code}|%{time_total}" \
                       --connect-timeout 5 --max-time 15 "$test_url" 2>/dev/null || echo "000|99")

        local http_code="${result%%|*}"
        local time_total="${result#*|}"
        local ms_int=$(echo "$time_total" | awk '{printf "%.0f", $1 * 1000}')

        SPEED_NAMES+=("$name")
        SPEED_URLS+=("$url")

        if [[ "$http_code" =~ ^[23] ]]; then
            SPEED_MS+=("$ms_int")
            if [[ $ms_int -lt 1000 ]]; then
                SPEED_STATUS+=("ok")
                printf "  %-35s ${GREEN}%s${NC}  %s ms\n" "$name" "$(tr MIRROR_STATUS_OK)" "$ms_int"
            else
                SPEED_STATUS+=("slow")
                printf "  %-35s ${YELLOW}%s${NC}  %s ms\n" "$name" "$(tr MIRROR_STATUS_SLOW)" "$ms_int"
            fi
        else
            SPEED_MS+=("99999")
            SPEED_STATUS+=("fail")
            printf "  %-35s ${RED}%s${NC}  HTTP %s\n" "$name" "$(tr MIRROR_STATUS_FAIL)" "$http_code"
        fi
    done < <(get_mirror_list)

    # ── Sort by speed (simple bubble on small arrays) ────────────────────────
    local count=${#SPEED_NAMES[@]}
    for ((i = 0; i < count - 1; i++)); do
        for ((j = 0; j < count - i - 1; j++)); do
            if [[ ${SPEED_MS[$j]} -gt ${SPEED_MS[$((j+1))]} ]]; then
                # swap all four arrays
                tmp="${SPEED_NAMES[$j]}";      SPEED_NAMES[$j]="${SPEED_NAMES[$((j+1))]}";      SPEED_NAMES[$((j+1))]="$tmp"
                tmp="${SPEED_URLS[$j]}";        SPEED_URLS[$j]="${SPEED_URLS[$((j+1))]}";        SPEED_URLS[$((j+1))]="$tmp"
                tmp="${SPEED_MS[$j]}";          SPEED_MS[$j]="${SPEED_MS[$((j+1))]}";            SPEED_MS[$((j+1))]="$tmp"
                tmp="${SPEED_STATUS[$j]}";      SPEED_STATUS[$j]="${SPEED_STATUS[$((j+1))]}";    SPEED_STATUS[$((j+1))]="$tmp"
            fi
        done
    done

    # ── Print ranking ────────────────────────────────────────────────────────
    echo
    echo "$(tr SPEED_RANK)"
    echo
    for ((i = 0; i < count; i++)); do
        local rank=$((i + 1))
        local name="${SPEED_NAMES[$i]}"
        local ms="${SPEED_MS[$i]}"
        local status="${SPEED_STATUS[$i]}"
        local url="${SPEED_URLS[$i]}"

        if [[ "$status" == "fail" ]]; then
            printf "  #%-2d %-35s ${RED}%s${NC}\n" "$rank" "$name" "$(tr SPEED_FAIL)"
        elif [[ "$status" == "slow" ]]; then
            printf "  #%-2d %-35s ${YELLOW}%s ms${NC}  %s\n" "$rank" "$name" "$ms" "$url"
        else
            local label=""
            [[ $rank -eq 1 ]] && label=" ★"
            printf "  #%-2d %-35s ${GREEN}%s ms${NC}  %s${BOLD}%s${NC}\n" "$rank" "$name" "$ms" "$url" "$label"
        fi
    done
    echo

    # ── Recommendation ───────────────────────────────────────────────────────
    local best_url=""
    local best_name=""
    for ((i = 0; i < count; i++)); do
        if [[ "${SPEED_STATUS[$i]}" != "fail" ]]; then
            best_url="${SPEED_URLS[$i]}"
            best_name="${SPEED_NAMES[$i]}"
            break
        fi
    done

    if [[ -n "$best_url" ]]; then
        local current=$(npm config get registry 2>/dev/null)
        # Normalize trailing slash for comparison
        current="${current%/}/"
        best_url_norm="${best_url%/}/"

        echo "$(tr RECOMMEND)"
        printf "  ${GREEN}${BOLD}%s${NC} — %s\n" "$best_name" "$best_url"
        echo

        if [[ "$current" == "$best_url_norm" ]]; then
            print_success "$(tr ALREADY_BEST)"
        else
            print_info "$(tr SWITCH_RECOMMEND)"
            echo
            read -p "$(printf "$(tr CONFIRM_SET)" "$best_url")" -r < /dev/tty
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                npm config set registry "$best_url"
                echo
                print_success "$(tr REGISTRY_SET)"
                printf "  ${CYAN}%s${NC}\n" "$best_url"
            else
                print_info "$(tr OPERATION_CANCELLED)"
            fi
        fi
    fi
}

# ── View current registry ───────────────────────────────────────────────────

view_registry() {
    echo
    echo "================================================"
    echo "$(tr VIEW)"
    echo "================================================"
    echo

    local current=$(npm config get registry 2>/dev/null)
    local npmrc_user="$HOME/.npmrc"

    print_success "$(tr CURRENT_REGISTRY)"
    printf "  ${CYAN}%s${NC}\n" "$current"
    echo
    print_info "$(tr NPMRC_LOCATION)"
    echo "  User:   ${npmrc_user}"
    echo

    if [[ -f "$npmrc_user" ]]; then
        echo -e "${BLUE}~/.npmrc:${NC}"
        echo "  ─────────────────────────────"
        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            echo "  ${line}"
        done < "$npmrc_user"
        echo "  ─────────────────────────────"
    else
        print_info "~/.npmrc $( [[ "$LANG_SELECTION" == "zh" ]] && echo "不存在" || echo "not found" )"
    fi
}

# ── Set registry mirror ─────────────────────────────────────────────────────

set_registry() {
    echo
    echo "================================================"
    echo "$(tr SET)"
    echo "================================================"
    echo
    echo "$(tr SELECT_MIRROR)"
    echo

    local -a names urls
    local i=0
    while IFS='|' read -r name url; do
        [[ -z "$name" ]] && continue
        names+=("$name")
        urls+=("$url")
        printf "  ${GREEN}%d)${NC} %-35s ${CYAN}%s${NC}\n" $((i + 1)) "$name" "$url"
        i=$((i + 1))
    done < <(get_mirror_list)

    local count=${#names[@]}
    printf "  ${GREEN}%d)${NC} %s\n" $((count + 1)) "$(tr ENTER_CUSTOM)"
    echo
    read -p "$(printf "$(tr ENTER_MIRROR_CHOICE)" $((count + 1)))" -r < /dev/tty
    echo

    local chosen_url=""
    if [[ $REPLY -ge 1 && $REPLY -le $count ]]; then
        chosen_url="${urls[$((REPLY - 1))]}"
    elif [[ $REPLY -eq $((count + 1)) ]]; then
        read -p "$(tr CUSTOM_URL_PROMPT)" -r < /dev/tty
        echo
        if [[ "$REPLY" =~ ^https?:// ]]; then
            chosen_url="$REPLY"
        else
            print_error "$(tr INVALID_URL)"
            return 1
        fi
    else
        print_error "$(tr INVALID_MIRROR)"
        return 1
    fi

    read -p "$(printf "$(tr CONFIRM_SET)" "$chosen_url")" -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "$(tr OPERATION_CANCELLED)"
        return
    fi

    npm config set registry "$chosen_url"
    print_success "$(tr REGISTRY_SET)"
    printf "  ${CYAN}%s${NC}\n" "$chosen_url"
}

# ── Reset to default ────────────────────────────────────────────────────────

reset_registry() {
    echo
    echo "================================================"
    echo "$(tr RESET)"
    echo "================================================"
    echo

    local default_url="https://registry.npmjs.org/"
    read -p "$(printf "$(tr CONFIRM_SET)" "$default_url")" -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "$(tr OPERATION_CANCELLED)"
        return
    fi

    npm config set registry "$default_url"
    print_success "$(tr REGISTRY_RESET)"
    printf "  ${CYAN}%s${NC}\n" "$default_url"
}

# ── Menu ────────────────────────────────────────────────────────────────────

select_operation() {
    echo
    echo "================================================"
    echo "$(tr TITLE)"
    echo "================================================"
    echo
    echo "$(tr SELECT_OP)"
    echo
    echo "1) $(tr VIEW)"
    echo "2) $(tr SET)"
    echo "3) $(tr RESET)"
    echo "4) $(tr SPEED_TEST)"
    echo "5) $(tr EXIT)"
    echo
    read -p "$(tr ENTER_CHOICE)" -r < /dev/tty
    echo
    case $REPLY in
        1) OPERATION="view" ;;
        2) OPERATION="set" ;;
        3) OPERATION="reset" ;;
        4) OPERATION="speed" ;;
        5) OPERATION="exit" ;;
        *)
            print_error "$(tr INVALID_CHOICE)"
            exit 1
            ;;
    esac
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
    clear
    select_language

    # Pre-flight: ensure npm exists
    if ! command -v npm &> /dev/null; then
        print_error "$(tr NPM_NOT_FOUND)"
        exit 1
    fi

    while true; do
        clear
        select_operation

        case $OPERATION in
            view)   view_registry ;;
            set)    set_registry ;;
            reset)  reset_registry ;;
            speed)  detect_network; run_speed_test ;;
            exit)   exit 0 ;;
        esac

        echo
        read -p "$(tr PRESS_ENTER)" -r < /dev/tty
    done
}

main
