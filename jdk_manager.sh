#!/bin/bash

##############################################################################
# Java JDK Installation & Uninstallation Manager
# Description: Automatically install JDK from Adoptium (Eclipse Temurin) or
#              uninstall existing JDK installation. Supports multiple languages.
# Usage: sudo bash jdk_manager.sh
##############################################################################

set -e  # Exit on error

# Temporary file tracking
TEMP_FILES=()

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/usr/local"
JDK_DIR_NAME="jdk"

# Language settings (default: English)
LANG_SELECTION="en"

# Translations
# English
TR_en_TITLE="Java JDK Installation & Uninstallation Manager"
TR_en_WELCOME="Welcome to JDK Manager"
TR_en_SELECT_LANG="Please select your language / 请选择你的语言:"
TR_en_SELECT_OP="Please select operation:"
TR_en_INSTALL="Install JDK"
TR_en_UNINSTALL="Uninstall JDK"
TR_en_CHECK="Check JDK Status"
TR_en_EXIT="Exit"
TR_en_ENTER_CHOICE="Enter your choice (1-4): "
TR_en_INVALID_CHOICE="Invalid choice, exiting..."
TR_en_NOT_ROOT_WARNING="This script is not running as root. Installation to /usr/local requires root privileges."
TR_en_SUDO_TIP="You can run: sudo bash $0"
TR_en_CONTINUE_PROMPT="Continue with current user privileges? (y/n): "
TR_en_UNSUPPORTED_ARCH="Unsupported architecture: %s"
TR_en_FETCH_FAIL="Failed to fetch JDK version information"
TR_en_FETCHING="Fetching available JDK versions..."
TR_en_LATEST_VERSION="Latest version available: %s"
TR_en_ALREADY_INSTALLED="JDK is already installed:"
TR_en_VERSION_INFO="Version: %s"
TR_en_JAVA_HOME="JAVA_HOME: %s"
TR_en_REINSTALL_PROMPT="Do you want to reinstall/update JDK? (y/n): "
TR_en_INSTALL_CANCEL="Installation cancelled"
TR_en_ALREADY_LATEST="You already have the latest version installed"
TR_en_DOWNLOADING="Downloading JDK %s for %s..."
TR_en_DOWNLOAD_COMPLETE="Download completed"
TR_en_DOWNLOAD_FAIL="Failed to download JDK"
TR_en_INSTALLING="Installing JDK to %s..."
TR_en_REMOVING_OLD="Removing old JDK installation..."
TR_en_EXTRACTING="Extracting archive..."
TR_en_EXTRACT_FAIL="Installation failed: JDK directory not found"
TR_en_EXTRACT_SUCCESS="JDK extracted successfully"
TR_en_CONFIGURING="Configuring environment variables..."
TR_en_BACKUP_CREATED="Created backup: %s"
TR_en_ENV_ADDED="Environment variables added to %s"
TR_en_ENV_EXISTS="JDK environment variables already exist in %s"
TR_en_UPDATING_CONFIG="Updating existing configuration..."
TR_en_CONFIG_UPDATED="Configuration updated"
TR_en_CONFIG_ERROR="Syntax error detected in %s!"
TR_en_RESTORING_BACKUP="Restoring from backup..."
TR_en_BACKUP_RESTORED="Backup restored successfully"
TR_en_VERIFYING="Verifying installation..."
TR_en_INSTALL_SUCCESS="JDK installed successfully!"
TR_en_VERIFY_FAIL="Installation verification failed"
TR_en_SOURCE_TIP="Please manually run: source %s"
TR_en_INSTALL_COMPLETE="Installation completed successfully!"
TR_en_CONFIG_DONE="JDK is now configured"
TR_en_SOURCE_CURRENT="To use JDK in your CURRENT terminal, run:"
TR_en_AUTO_NEW="For NEW terminals, JDK will work automatically!"
TR_en_VERIFY_CMD="Verify installation with:"
TR_en_CLEANING="Cleaning up temporary files..."
TR_en_CLEANUP_DONE="Cleanup completed"
TR_en_UNINSTALL_TITLE="Starting JDK uninstallation..."
TR_en_FINDING_JDK="Searching for existing JDK installation..."
TR_en_JDK_NOT_FOUND="No existing JDK installation found"
TR_en_JDK_FOUND="Found JDK installation at: %s"
TR_en_UNINSTALL_CONFIRM="Are you sure you want to uninstall JDK? This will remove the JDK installation and clean up environment variables. (y/n): "
TR_en_UNINSTALL_CANCEL="Uninstallation cancelled"
TR_en_REMOVING_JDK="Removing JDK installation directory..."
TR_en_REMOVING_JDK_DONE="JDK installation directory removed"
TR_en_REMOVING_ENV="Removing JDK environment variables from configuration files..."
TR_en_ENV_REMOVED="JDK environment variables removed"
TR_en_UNINSTALL_SUCCESS="JDK uninstalled successfully!"
TR_en_UNINSTALL_DONE="Uninstallation completed"
TR_en_BACKUP_NOTE="A backup of your configuration files has been created with .bak extension"
TR_en_UNINSTALL_FINISH="Uninstallation completed. Please restart your terminal or run: source %s"
TR_en_JDK_NOT_INSTALLED="JDK is not installed"
TR_en_JDK_INSTALLED="JDK is installed"
TR_en_PRESS_ENTER="Press Enter to return to menu..."
TR_en_SELECT_VERSION="Select JDK version:"
TR_en_LATEST_VERSION_OPTION="Install latest LTS version (recommended)"
TR_en_CHOOSE_LTS="Choose from version list"
TR_en_CHOOSE_FROM_LIST="Choose from available versions"
TR_en_ENTER_MANUALLY="Enter version manually"
TR_en_AVAILABLE_VERSIONS="Available JDK LTS versions:"
TR_en_SELECT_FROM_LIST="Select a version (1-%d): "
TR_en_ENTER_VERSION="Enter JDK version (e.g., 21): "
TR_en_INVALID_VERSION="Invalid version. Available: 8, 11, 17, 21, 22, 23, 24, 25"
TR_en_FETCHING_VERSIONS="Fetching available JDK versions..."
TR_en_SELECT_LTS="Select version:"
TR_en_LTS_VERSIONS="Available versions:"

# Chinese
TR_zh_TITLE="Java JDK 安装卸载管理器"
TR_zh_WELCOME="欢迎使用 JDK 管理器"
TR_zh_SELECT_LANG="请选择你的语言 / Please select your language:"
TR_zh_SELECT_OP="请选择操作:"
TR_zh_INSTALL="安装 JDK"
TR_zh_UNINSTALL="卸载 JDK"
TR_zh_CHECK="检查 JDK 状态"
TR_zh_EXIT="退出"
TR_zh_ENTER_CHOICE="请输入你的选择 (1-4): "
TR_zh_INVALID_CHOICE="无效选择，退出..."
TR_zh_NOT_ROOT_WARNING="当前不是 root 用户，安装到 /usr/local 需要 root 权限"
TR_zh_SUDO_TIP="你可以使用: sudo bash $0"
TR_zh_CONTINUE_PROMPT="是否继续使用当前用户权限安装？(y/n): "
TR_zh_UNSUPPORTED_ARCH="不支持的架构: %s"
TR_zh_FETCH_FAIL="获取 JDK 版本信息失败"
TR_zh_FETCHING="正在获取可用的 JDK 版本..."
TR_zh_LATEST_VERSION="最新可用版本: %s"
TR_zh_ALREADY_INSTALLED="JDK 已经安装:"
TR_zh_VERSION_INFO="版本: %s"
TR_zh_JAVA_HOME="JAVA_HOME: %s"
TR_zh_REINSTALL_PROMPT="是否重新安装/更新 JDK？(y/n): "
TR_zh_INSTALL_CANCEL="安装已取消"
TR_zh_ALREADY_LATEST="你已经安装了最新版本"
TR_zh_DOWNLOADING="正在下载 JDK %s (%s)..."
TR_zh_DOWNLOAD_COMPLETE="下载完成"
TR_zh_DOWNLOAD_FAIL="下载 JDK 失败"
TR_zh_INSTALLING="正在安装 JDK 到 %s..."
TR_zh_REMOVING_OLD="正在移除旧的 JDK 安装..."
TR_zh_EXTRACTING="正在解压压缩包..."
TR_zh_EXTRACT_FAIL="安装失败: 未找到 JDK 目录"
TR_zh_EXTRACT_SUCCESS="JDK 解压成功"
TR_zh_CONFIGURING="正在配置环境变量..."
TR_zh_BACKUP_CREATED="已创建备份: %s"
TR_zh_ENV_ADDED="环境变量已添加到 %s"
TR_zh_ENV_EXISTS="JDK 环境变量已存在于 %s"
TR_zh_UPDATING_CONFIG="正在更新现有配置..."
TR_zh_CONFIG_UPDATED="配置已更新"
TR_zh_CONFIG_ERROR="检测到 %s 存在语法错误!"
TR_zh_RESTORING_BACKUP="正在从备份恢复..."
TR_zh_BACKUP_RESTORED="备份恢复成功"
TR_zh_VERIFYING="正在验证安装..."
TR_zh_INSTALL_SUCCESS="JDK 安装成功!"
TR_zh_VERIFY_FAIL="安装验证失败"
TR_zh_SOURCE_TIP="请手动运行: source %s"
TR_zh_INSTALL_COMPLETE="安装完成成功!"
TR_zh_CONFIG_DONE="JDK 已配置完成"
TR_zh_SOURCE_CURRENT="在当前终端使用 JDK，请运行:"
TR_zh_AUTO_NEW="新开终端会自动生效 JDK 命令!"
TR_zh_VERIFY_CMD="验证安装请运行:"
TR_zh_CLEANING="正在清理临时文件..."
TR_zh_CLEANUP_DONE="清理完成"
TR_zh_UNINSTALL_TITLE="开始卸载 JDK..."
TR_zh_FINDING_JDK="正在搜索已安装的 JDK..."
TR_zh_JDK_NOT_FOUND="未找到已安装的 JDK"
TR_zh_JDK_FOUND="在以下位置找到 JDK: %s"
TR_zh_UNINSTALL_CONFIRM="确认要卸载 JDK 吗？这将删除 JDK 安装并清理环境变量。(y/n): "
TR_zh_UNINSTALL_CANCEL="卸载已取消"
TR_zh_REMOVING_JDK="正在删除 JDK 安装目录..."
TR_zh_REMOVING_JDK_DONE="JDK 安装目录已删除"
TR_zh_REMOVING_ENV="正在从配置文件中移除 JDK 环境变量..."
TR_zh_ENV_REMOVED="JDK 环境变量已移除"
TR_zh_UNINSTALL_SUCCESS="JDK 卸载成功!"
TR_zh_UNINSTALL_DONE="卸载完成"
TR_zh_BACKUP_NOTE="配置文件的备份已创建，扩展名是 .bak"
TR_zh_UNINSTALL_FINISH="卸载完成，请重启终端或运行: source %s"
TR_zh_JDK_NOT_INSTALLED="JDK 未安装"
TR_zh_JDK_INSTALLED="JDK 已安装"
TR_zh_PRESS_ENTER="按回车键返回菜单..."
TR_zh_SELECT_VERSION="选择 JDK 版本:"
TR_zh_LATEST_VERSION_OPTION="安装最新 LTS 版本 (推荐)"
TR_zh_CHOOSE_LTS="从版本列表中选择"
TR_zh_CHOOSE_FROM_LIST="从可用版本中选择"
TR_zh_ENTER_MANUALLY="手动输入版本号"
TR_zh_AVAILABLE_VERSIONS="可用的 JDK LTS 版本:"
TR_zh_SELECT_FROM_LIST="选择版本 (1-%d): "
TR_zh_ENTER_VERSION="输入 JDK 版本号 (例如 21): "
TR_zh_INVALID_VERSION="版本无效。可用版本: 8, 11, 17, 21, 22, 23, 24, 25"
TR_zh_FETCHING_VERSIONS="正在获取可用的 JDK 版本..."
TR_zh_SELECT_LTS="选择版本:"
TR_zh_LTS_VERSIONS="可用的版本:"

# Print functions (output to stderr to avoid capture in command substitution)
print_info() {
    printf "${BLUE}[INFO]${NC} %s${NC}\n" "$1" >&2
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s${NC}\n" "$1" >&2
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s${NC}\n" "$1" >&2
}

print_error() {
    printf "${RED}[ERROR]${NC} %s${NC}\n" "$1" >&2
}

# Translation function
tr() {
    local key=$1
    local var_name="TR_${LANG_SELECTION}_${key}"
    echo -n "${!var_name}"
}

# Select language
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
        1)
            LANG_SELECTION="en"
            ;;
        2)
            LANG_SELECTION="zh"
            ;;
        *)
            echo "Invalid choice, defaulting to English"
            LANG_SELECTION="en"
            ;;
    esac
}

# Detect system architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "x64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        armv7l|armhf)
            echo "arm"
            ;;
        s390x)
            echo "s390x"
            ;;
        ppc64le)
            echo "ppc64le"
            ;;
        *)
            print_error "$(printf "$(tr UNSUPPORTED_ARCH)" "$arch")"
            exit 1
            ;;
    esac
}

# Select operation
select_operation() {
    echo
    echo "================================================"
    echo "$(tr TITLE)"
    echo "================================================"
    echo
    echo "$(tr SELECT_OP)"
    echo
    echo "1) $(tr CHECK)"
    echo "2) $(tr INSTALL)"
    echo "3) $(tr UNINSTALL)"
    echo "4) $(tr EXIT)"
    echo
    read -p "$(tr ENTER_CHOICE)" -r < /dev/tty
    echo
    case $REPLY in
        1)
            OPERATION="check"
            ;;
        2)
            OPERATION="install"
            ;;
        3)
            OPERATION="uninstall"
            ;;
        4)
            exit 0
            ;;
        *)
            print_error "$(tr INVALID_CHOICE)"
            exit 1
            ;;
    esac
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "$(printf "$(tr NOT_ROOT_WARNING)")"
        print_info "$(printf "$(tr SUDO_TIP)")"
        read -p "$(printf "$(tr CONTINUE_PROMPT)")" -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        if [[ $INSTALL_DIR == "/usr/local" && ! -w "/usr/local" ]]; then
            INSTALL_DIR="$HOME/.local"
            mkdir -p "$INSTALL_DIR"
        fi
    fi
}

# Get latest version from Adoptium API
get_latest_lts_version() {
    print_info "$(tr FETCHING)"
    # Get the latest version (25, 24, 23, 22, 21, 17, 11, 8)
    local version=$(curl -s "https://api.adoptium.net/v3/info/release_versions?release_type=ga&sort_method=DEFAULT&sort_order=DESC&vendor=eclipse" | grep -oP '"semver":\s*"\K[0-9]+' | head -1)
    if [[ -z "$version" ]]; then
        # Fallback to a known good version
        version="21"
        print_warning "Could not fetch latest version, using default: $version"
    fi
    echo "$version"
}

# List available versions
list_available_versions() {
    print_info "$(tr FETCHING_VERSIONS)"
    # Available versions (LTS + recent releases)
    local versions="25
24
23
22
21
17
11
8"
    echo "$versions"
}

# Select JDK version interactively
select_jdk_version() {
    echo
    echo "================================================"
    echo "$(tr SELECT_VERSION)"
    echo "================================================"
    echo
    echo "1) $(tr LATEST_VERSION_OPTION)"
    echo "2) $(tr CHOOSE_LTS)"
    echo "3) $(tr ENTER_MANUALLY)"
    echo
    read -p "$(tr ENTER_CHOICE)" -r < /dev/tty
    echo

    local version=""
    case $REPLY in
        1)
            version=$(get_latest_lts_version)
            ;;
        2)
            local versions=$(list_available_versions)
            echo
            echo "$(tr AVAILABLE_VERSIONS)"
            echo
            local i=1
            while IFS= read -r ver; do
                echo "  $i) JDK $ver"
                i=$((i + 1))
            done <<< "$versions"
            echo
            local count=$((i - 1))
            read -p "$(printf "$(tr SELECT_FROM_LIST)" "$count")" -r < /dev/tty
            echo
            if [[ $REPLY -ge 1 && $REPLY -le $count ]]; then
                version=$(echo "$versions" | sed -n "${REPLY}p")
            else
                print_error "$(tr INVALID_CHOICE)"
                return 1
            fi
            ;;
        3)
            read -p "$(tr ENTER_VERSION)" -r < /dev/tty
            echo
            # Validate version (must be 8, 11, 17, 21, 22, 23, 24, or 25)
            if [[ "$REPLY" =~ ^(8|11|17|21|22|23|24|25)$ ]]; then
                version="$REPLY"
            else
                print_error "$(tr INVALID_VERSION)"
                return 1
            fi
            ;;
        *)
            print_error "$(tr INVALID_CHOICE)"
            return 1
            ;;
    esac

    echo "$version"
}

# Check if JDK is already installed
check_existing_jdk() {
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local java_home=$(java -XshowSettings:properties -version 2>&1 | grep "java.home" | awk '{print $3}')
        if [[ -z "$java_home" ]]; then
            java_home=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
        fi
        echo "$java_version|$java_home"
        return 0
    else
        # Check common locations
        if [[ -d "${INSTALL_DIR}/${JDK_DIR_NAME}" ]]; then
            local java_bin="${INSTALL_DIR}/${JDK_DIR_NAME}/bin/java"
            if [[ -x "$java_bin" ]]; then
                local java_version=$("$java_bin" -version 2>&1 | head -n 1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                echo "$java_version|${INSTALL_DIR}/${JDK_DIR_NAME}"
                return 0
            fi
        fi
        echo ""
        return 1
    fi
}

# Find JDK installation location
find_jdk_installation() {
    local found_loc=""
    if command -v java &> /dev/null; then
        found_loc=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
    else
        # Check common locations
        if [[ -d "${INSTALL_DIR}/${JDK_DIR_NAME}" && -x "${INSTALL_DIR}/${JDK_DIR_NAME}/bin/java" ]]; then
            found_loc="${INSTALL_DIR}/${JDK_DIR_NAME}"
        elif [[ -d "$HOME/.local/${JDK_DIR_NAME}" && -x "$HOME/.local/${JDK_DIR_NAME}/bin/java" ]]; then
            found_loc="$HOME/.local/${JDK_DIR_NAME}"
        fi
    fi
    echo "$found_loc"
}

# Download JDK from Adoptium
download_jdk() {
    local version=$1
    local arch=$2
    local os="linux"
    local image_type="jdk"
    local release_type="ga"
    local vendor="eclipse"

    # Construct download URL using Adoptium API
    local download_url="https://api.adoptium.net/v3/binary/latest/${version}/${release_type}/${os}/${arch}/${image_type}/hotspot/normal/${vendor}"

    print_info "$(printf "$(tr DOWNLOADING)" "$version" "$arch")"
    echo >&2

    local temp_file="/tmp/temurin-jdk-${version}-${os}-${arch}.tar.gz"

    # Track temp file for cleanup
    TEMP_FILES+=("$temp_file")

    # Use curl with progress bar and follow redirects
    if ! curl -L --progress-bar -o "$temp_file" "$download_url"; then
        print_error "$(tr DOWNLOAD_FAIL)"
        exit 1
    fi

    # Check if the downloaded file is valid
    if [[ ! -s "$temp_file" ]]; then
        print_error "$(tr DOWNLOAD_FAIL)"
        exit 1
    fi

    echo >&2
    print_success "$(tr DOWNLOAD_COMPLETE)"

    echo "$temp_file"
}

# Install JDK
install_jdk() {
    local archive=$1

    print_info "$(printf "$(tr INSTALLING)" "$INSTALL_DIR")"

    # Remove old installation if exists
    local jdk_install_dir="${INSTALL_DIR}/${JDK_DIR_NAME}"
    if [[ -d "$jdk_install_dir" ]]; then
        print_info "$(tr REMOVING_OLD)"
        rm -rf "$jdk_install_dir"
    fi

    # Extract archive
    print_info "$(tr EXTRACTING)"
    mkdir -p "$INSTALL_DIR"
    tar -C "$INSTALL_DIR" -xzf "$archive"

    # Find the extracted directory (Temurin-jdk-XX.XX.XX-X)
    local extracted_dir=$(find "$INSTALL_DIR" -maxdepth 1 -name "jdk-*" -type d | head -1)
    if [[ -z "$extracted_dir" || ! -d "$extracted_dir" ]]; then
        print_error "$(tr EXTRACT_FAIL)"
        exit 1
    fi

    # Rename to standard name
    mv "$extracted_dir" "$jdk_install_dir"

    print_success "$(tr EXTRACT_SUCCESS)"

    echo "$jdk_install_dir"
}

# Configure environment variables
configure_environment() {
    local jdk_home=$1
    print_info "$(tr CONFIGURING)"

    # Configuration files to update (system and user)
    local config_files=()
    if [[ $EUID -eq 0 ]]; then
        if [[ -f "/etc/profile" ]]; then
            config_files+=("/etc/profile")
        fi
        if [[ -f "/etc/bash.bashrc" ]]; then
            config_files+=("/etc/bash.bashrc")
        fi
    fi
    if [[ -f "$HOME/.bashrc" ]]; then
        config_files+=("$HOME/.bashrc")
    fi
    if [[ -f "$HOME/.zshrc" ]]; then
        config_files+=("$HOME/.zshrc")
    fi
    if [[ -f "$HOME/.profile" ]]; then
        config_files+=("$HOME/.profile")
    fi

    # Function to add to config file
    add_to_config() {
        local config_file=$1
        if [[ ! -f "$config_file" ]]; then
            return
        fi
        # Create backup before modifying
        local backup_file="${config_file}.bak.$(date +%s)"
        cp "$config_file" "$backup_file"
        print_info "$(printf "$(tr BACKUP_CREATED)" "$backup_file")"

        # Remove existing JDK configuration
        sed -i '/# Java JDK Environment/d' "$config_file" 2>/dev/null || true
        sed -i '/export JAVA_HOME/d' "$config_file" 2>/dev/null || true
        sed -i '/jdk\/bin/d' "$config_file" 2>/dev/null || true

        # Add new configuration
        cat >> "$config_file" <<EOF

# Java JDK Environment
export JAVA_HOME=${jdk_home}
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
    }

    # Add to all config files that exist
    for config_file in "${config_files[@]}"; do
        add_to_config "$config_file"
        print_success "$(printf "$(tr ENV_ADDED)" "$config_file")"
    done

    # Verify configuration files are still valid
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            if ! bash -n "$config_file" 2>/dev/null; then
                print_error "$(printf "$(tr CONFIG_ERROR)" "$config_file")"
                print_info "$(tr RESTORING_BACKUP)"
                local latest_backup=$(ls -t "${config_file}.bak."* 2>/dev/null | head -1)
                if [[ -f "$latest_backup" ]]; then
                    mv "$latest_backup" "$config_file"
                    print_success "$(tr BACKUP_RESTORED)"
                fi
                exit 1
            fi
        fi
    done

    # Clean up old backups (keep only the last 5) for each config file
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            ls -t "${config_file}.bak."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
        fi
    done
}

# Verify installation
verify_installation() {
    print_info "$(tr VERIFYING)"

    # Load environment for verification
    local jdk_home="${INSTALL_DIR}/${JDK_DIR_NAME}"
    export JAVA_HOME="$jdk_home"
    export PATH="$PATH:$JAVA_HOME/bin"

    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1)
        print_success "$(tr INSTALL_SUCCESS)"
        print_success "$(printf "$(tr VERSION_INFO)" "$java_version")"
        print_info "$(printf "$(tr JAVA_HOME)" "$JAVA_HOME")"
    else
        # Try the direct path
        if [[ -x "${JAVA_HOME}/bin/java" ]]; then
            local java_version=$("${JAVA_HOME}/bin/java" -version 2>&1 | head -n 1)
            print_success "$(tr INSTALL_SUCCESS)"
            print_success "$(printf "$(tr VERSION_INFO)" "$java_version")"
            print_info "$(printf "$(tr JAVA_HOME)" "$JAVA_HOME")"
        else
            print_error "$(tr VERIFY_FAIL)"
            print_info "$(printf "$(tr SOURCE_TIP)" "$HOME/.bashrc")"
            exit 1
        fi
    fi
}

# Uninstall JDK
uninstall_jdk() {
    print_info "$(tr UNINSTALL_TITLE)"
    print_info "$(tr FINDING_JDK)"

    local jdk_location=$(find_jdk_installation)

    if [[ -z "$jdk_location" || ! -d "$jdk_location" ]]; then
        print_warning "$(tr JDK_NOT_FOUND)"
        return
    fi

    print_success "$(printf "$(tr JDK_FOUND)" "$jdk_location")"

    # Show version
    if [[ -x "$jdk_location/bin/java" ]]; then
        local version=$("$jdk_location/bin/java" -version 2>&1 | head -n 1)
        print_info "$(printf "$(tr VERSION_INFO)" "$version")"
    fi

    # Confirm uninstall
    echo
    read -p "$(printf "$(tr UNINSTALL_CONFIRM)")" -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "$(tr UNINSTALL_CANCEL)"
        return
    fi

    # Remove JDK installation directory
    print_info "$(tr REMOVING_JDK)"
    if [[ -d "$jdk_location" ]]; then
        rm -rf "$jdk_location"
        print_success "$(tr REMOVING_JDK_DONE)"
    fi

    # Remove environment variables from config files
    print_info "$(tr REMOVING_ENV)"
    # Check all common config files
    local config_files=()
    if [[ -f "/etc/profile" ]]; then
        config_files+=("/etc/profile")
    fi
    if [[ -f "/etc/bash.bashrc" ]]; then
        config_files+=("/etc/bash.bashrc")
    fi
    if [[ -f "$HOME/.bashrc" ]]; then
        config_files+=("$HOME/.bashrc")
    fi
    if [[ -f "$HOME/.zshrc" ]]; then
        config_files+=("$HOME/.zshrc")
    fi
    if [[ -f "$HOME/.profile" ]]; then
        config_files+=("$HOME/.profile")
    fi

    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" && -w "$config_file" ]]; then
            # Create backup
            local backup_file="${config_file}.bak.$(date +%s)"
            cp "$config_file" "$backup_file"
            # Remove JDK configuration
            sed -i '/# Java JDK Environment/d' "$config_file" 2>/dev/null || true
            sed -i '/export JAVA_HOME/d' "$config_file" 2>/dev/null || true
            sed -i '/jdk\/bin/d' "$config_file" 2>/dev/null || true
        fi
    done
    print_success "$(tr ENV_REMOVED)"

    echo
    print_success "$(tr UNINSTALL_SUCCESS)"
    echo "================================================"
    print_success "$(tr UNINSTALL_DONE)"
    echo "================================================"
    echo
    print_info "$(tr BACKUP_NOTE)"
    echo
    print_info "$(printf "$(tr UNINSTALL_FINISH)" "$HOME/.bashrc")"
    echo
}

# Check JDK status
check_status() {
    echo
    if check_existing_jdk; then
        IFS='|' read -r java_version java_home <<< "$(check_existing_jdk)"
        print_success "$(tr JDK_INSTALLED)"
        print_info "$(printf "$(tr VERSION_INFO)" "$java_version")"
        print_info "$(printf "$(tr JAVA_HOME)" "$java_home")"
    else
        print_warning "$(tr JDK_NOT_INSTALLED)"
    fi
    echo
}

# Cleanup function - called automatically on exit
cleanup() {
    local exit_code=$?

    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        print_info "$(tr CLEANING)"
        for file in "${TEMP_FILES[@]}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
            fi
        done
        print_success "$(tr CLEANUP_DONE)"
    fi

    return $exit_code
}

# Set trap to ensure cleanup on exit (success or failure)
trap cleanup EXIT INT TERM

# Main installation process
main_install() {
    echo
    echo "================================================"
    echo "$(tr WELCOME)"
    echo "================================================"
    echo

    check_root

    local arch=$(detect_arch)
    print_info "Detected architecture: $arch"

    local existing_info=$(check_existing_jdk)
    if [[ -n "$existing_info" ]]; then
        IFS='|' read -r existing_version existing_home <<< "$existing_info"
        print_warning "$(printf "$(tr ALREADY_INSTALLED) %s" "$existing_version")"
        print_info "$(printf "$(tr JAVA_HOME)" "$existing_home")"
        read -p "$(printf "$(tr REINSTALL_PROMPT)")" -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "$(tr INSTALL_CANCEL)"
            return
        fi
    fi

    local version=$(select_jdk_version)
    if [[ $? -ne 0 || -z "$version" ]]; then
        print_error "$(tr INSTALL_CANCEL)"
        return
    fi
    print_success "$(printf "$(tr LATEST_VERSION)" "$version")"

    # Check if already at this version
    if [[ -n "$existing_info" ]]; then
        IFS='|' read -r existing_version existing_home <<< "$existing_info"
        local existing_major=$(echo "$existing_version" | grep -oP '^[0-9]+')
        if [[ "$existing_major" == "$version" ]]; then
            print_info "$(tr ALREADY_LATEST)"
            return
        fi
    fi

    local archive=$(download_jdk "$version" "$arch")
    local jdk_home=$(install_jdk "$archive")
    configure_environment "$jdk_home"
    verify_installation

    echo
    echo "================================================"
    print_success "$(tr INSTALL_COMPLETE)"
    echo "================================================"
    echo
    print_success "$(tr CONFIG_DONE)"
    echo
    print_info "$(tr SOURCE_CURRENT)"
    echo -e "  ${GREEN}source ~/.bashrc${NC}"
    echo
    print_info "$(tr AUTO_NEW)"
    echo
    print_info "$(tr VERIFY_CMD)"
    echo -e "  ${GREEN}java -version${NC}"
    echo
}

# Main loop
main() {
    clear
    select_language

    while true; do
        clear
        select_operation

        case $OPERATION in
            check)
                check_status
                ;;
            install)
                main_install
                ;;
            uninstall)
                uninstall_jdk
                ;;
            exit)
                exit 0
                ;;
        esac

        echo
        read -p "$(tr PRESS_ENTER)" -r < /dev/tty
    done
}

# Start the script
main
