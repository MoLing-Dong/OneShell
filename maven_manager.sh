#!/bin/bash

##############################################################################
# Apache Maven Installation & Uninstallation Manager
# Description: Automatically download and install Maven from official website,
#              or uninstall existing Maven installation. Supports multiple languages.
# Usage: sudo bash maven_manager.sh
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

# Language settings (default: English)
LANG_SELECTION="en"

# Translations
# English
TR_en_TITLE="Apache Maven Installation & Uninstallation Manager"
TR_en_WELCOME="Welcome to Maven Manager"
TR_en_SELECT_LANG="Please select your language / 请选择你的语言:"
TR_en_SELECT_OP="Please select operation:"
TR_en_INSTALL="Install Maven"
TR_en_UNINSTALL="Uninstall Maven"
TR_en_CHECK="Check Maven Status"
TR_en_EXIT="Exit"
TR_en_ENTER_CHOICE="Enter your choice (1-4): "
TR_en_INVALID_CHOICE="Invalid choice, exiting..."
TR_en_NOT_ROOT_WARNING="This script is not running as root. Installation to /usr/local requires root privileges."
TR_en_SUDO_TIP="You can run: sudo bash $0"
TR_en_CONTINUE_PROMPT="Continue with current user privileges? (y/n): "
TR_en_UNSUPPORTED_OS="Unsupported operating system"
TR_en_DETECTED_OS="Detected operating system: %s"
TR_en_FETCH_FAIL="Failed to fetch the latest Maven version information"
TR_en_FETCHING="Fetching latest Maven version..."
TR_en_LATEST_VERSION="Latest version available: %s"
TR_en_ALREADY_INSTALLED="Maven is already installed:"
TR_en_VERSION_INFO="Version: %s"
TR_en_MAVEN_HOME="Maven home: %s"
TR_en_REINSTALL_PROMPT="Do you want to reinstall/update Maven? (y/n): "
TR_en_INSTALL_CANCEL="Installation cancelled"
TR_en_ALREADY_LATEST="You already have the latest version installed"
TR_en_CHECK_JDK="Checking for Java installation..."
TR_en_JDK_NOT_FOUND="Java (JDK) is not installed. Maven requires Java to run."
TR_en_JDK_FOUND="Java found:"
TR_en_JDK_VERSION="Java version: %s"
TR_en_DOWNLOADING="Downloading Maven %s..."
TR_en_DOWNLOAD_COMPLETE="Download completed"
TR_en_DOWNLOAD_FAIL="Failed to download Maven"
TR_en_INSTALLING="Installing Maven to %s..."
TR_en_REMOVING_OLD="Removing old Maven installation..."
TR_en_EXTRACTING="Extracting archive..."
TR_en_EXTRACT_FAIL="Installation failed: Maven directory not found"
TR_en_EXTRACT_SUCCESS="Maven extracted successfully"
TR_en_CONFIGURING="Configuring environment variables..."
TR_en_BACKUP_CREATED="Created backup: %s"
TR_en_ENV_ADDED="Environment variables added to %s"
TR_en_ENV_EXISTS="Maven environment variables already exist in %s"
TR_en_UPDATING_CONFIG="Updating existing configuration..."
TR_en_CONFIG_UPDATED="Configuration updated"
TR_en_CONFIG_ERROR="Syntax error detected in %s!"
TR_en_RESTORING_BACKUP="Restoring from backup..."
TR_en_BACKUP_RESTORED="Backup restored successfully"
TR_en_VERIFYING="Verifying installation..."
TR_en_INSTALL_SUCCESS="Maven installed successfully!"
TR_en_VERIFY_FAIL="Installation verification failed"
TR_en_SOURCE_TIP="Please manually run: source %s"
TR_en_INSTALL_COMPLETE="Installation completed successfully!"
TR_en_CONFIG_DONE="Maven is now configured"
TR_en_SOURCE_CURRENT="To use Maven in your CURRENT terminal, run:"
TR_en_AUTO_NEW="For NEW terminals, Maven will work automatically!"
TR_en_VERIFY_CMD="Verify installation with:"
TR_en_CLEANING="Cleaning up temporary files..."
TR_en_CLEANUP_DONE="Cleanup completed"
TR_en_UNINSTALL_TITLE="Starting Maven uninstallation..."
TR_en_FINDING_MAVEN="Searching for existing Maven installation..."
TR_en_MAVEN_NOT_FOUND="No existing Maven installation found"
TR_en_MAVEN_FOUND="Found Maven installation at: %s"
TR_en_UNINSTALL_CONFIRM="Are you sure you want to uninstall Maven? This will remove the Maven installation and clean up environment variables. (y/n): "
TR_en_UNINSTALL_CANCEL="Uninstallation cancelled"
TR_en_REMOVING_MAVEN="Removing Maven installation directory..."
TR_en_REMOVING_MAVEN_DONE="Maven installation directory removed"
TR_en_REMOVING_ENV="Removing Maven environment variables from configuration files..."
TR_en_ENV_REMOVED="Maven environment variables removed"
TR_en_UNINSTALL_SUCCESS="Maven uninstalled successfully!"
TR_en_UNINSTALL_DONE="Uninstallation completed"
TR_en_BACKUP_NOTE="A backup of your configuration files has been created with .bak extension"
TR_en_UNINSTALL_FINISH="Uninstallation completed. Please restart your terminal or run: source %s"
TR_en_MAVEN_NOT_INSTALLED="Maven is not installed"
TR_en_MAVEN_INSTALLED="Maven is installed"
TR_en_PRESS_ENTER="Press Enter to return to menu..."

# Chinese
TR_zh_TITLE="Apache Maven 安装卸载管理器"
TR_zh_WELCOME="欢迎使用 Maven 管理器"
TR_zh_SELECT_LANG="请选择你的语言 / Please select your language:"
TR_zh_SELECT_OP="请选择操作:"
TR_zh_INSTALL="安装 Maven"
TR_zh_UNINSTALL="卸载 Maven"
TR_zh_CHECK="检查 Maven 状态"
TR_zh_EXIT="退出"
TR_zh_ENTER_CHOICE="请输入你的选择 (1-4): "
TR_zh_INVALID_CHOICE="无效选择，退出..."
TR_zh_NOT_ROOT_WARNING="当前不是 root 用户，安装到 /usr/local 需要 root 权限"
TR_zh_SUDO_TIP="你可以使用: sudo bash $0"
TR_zh_CONTINUE_PROMPT="是否继续使用当前用户权限安装？(y/n): "
TR_zh_UNSUPPORTED_OS="不支持的操作系统"
TR_zh_DETECTED_OS="检测到操作系统: %s"
TR_zh_FETCH_FAIL="获取最新 Maven 版本信息失败"
TR_zh_FETCHING="正在获取最新 Maven 版本..."
TR_zh_LATEST_VERSION="最新可用版本: %s"
TR_zh_ALREADY_INSTALLED="Maven 已经安装:"
TR_zh_VERSION_INFO="版本: %s"
TR_zh_MAVEN_HOME="Maven 目录: %s"
TR_zh_REINSTALL_PROMPT="是否重新安装/更新 Maven？(y/n): "
TR_zh_INSTALL_CANCEL="安装已取消"
TR_zh_ALREADY_LATEST="你已经安装了最新版本"
TR_zh_CHECK_JDK="正在检查 Java 安装..."
TR_zh_JDK_NOT_FOUND="未找到 Java (JDK)。Maven 需要 Java 才能运行。"
TR_zh_JDK_FOUND="Java 已找到:"
TR_zh_JDK_VERSION="Java 版本: %s"
TR_zh_DOWNLOADING="正在下载 Maven %s..."
TR_zh_DOWNLOAD_COMPLETE="下载完成"
TR_zh_DOWNLOAD_FAIL="下载 Maven 失败"
TR_zh_INSTALLING="正在安装 Maven 到 %s..."
TR_zh_REMOVING_OLD="正在移除旧的 Maven 安装..."
TR_zh_EXTRACTING="正在解压压缩包..."
TR_zh_EXTRACT_FAIL="安装失败: 未找到 Maven 目录"
TR_zh_EXTRACT_SUCCESS="Maven 解压成功"
TR_zh_CONFIGURING="正在配置环境变量..."
TR_zh_BACKUP_CREATED="已创建备份: %s"
TR_zh_ENV_ADDED="环境变量已添加到 %s"
TR_zh_ENV_EXISTS="Maven 环境变量已存在于 %s"
TR_zh_UPDATING_CONFIG="正在更新现有配置..."
TR_zh_CONFIG_UPDATED="配置已更新"
TR_zh_CONFIG_ERROR="检测到 %s 存在语法错误!"
TR_zh_RESTORING_BACKUP="正在从备份恢复..."
TR_zh_BACKUP_RESTORED="备份恢复成功"
TR_zh_VERIFYING="正在验证安装..."
TR_zh_INSTALL_SUCCESS="Maven 安装成功!"
TR_zh_VERIFY_FAIL="安装验证失败"
TR_zh_SOURCE_TIP="请手动运行: source %s"
TR_zh_INSTALL_COMPLETE="安装完成成功!"
TR_zh_CONFIG_DONE="Maven 已配置完成"
TR_zh_SOURCE_CURRENT="在当前终端使用 Maven，请运行:"
TR_zh_AUTO_NEW="新开终端会自动生效 Maven 命令!"
TR_zh_VERIFY_CMD="验证安装请运行:"
TR_zh_CLEANING="正在清理临时文件..."
TR_zh_CLEANUP_DONE="清理完成"
TR_zh_UNINSTALL_TITLE="开始卸载 Maven..."
TR_zh_FINDING_MAVEN="正在搜索已安装的 Maven..."
TR_zh_MAVEN_NOT_FOUND="未找到已安装的 Maven"
TR_zh_MAVEN_FOUND="在以下位置找到 Maven: %s"
TR_zh_UNINSTALL_CONFIRM="确认要卸载 Maven 吗？这将删除 Maven 安装并清理环境变量。(y/n): "
TR_zh_UNINSTALL_CANCEL="卸载已取消"
TR_zh_REMOVING_MAVEN="正在删除 Maven 安装目录..."
TR_zh_REMOVING_MAVEN_DONE="Maven 安装目录已删除"
TR_zh_REMOVING_ENV="正在从配置文件中移除 Maven 环境变量..."
TR_zh_ENV_REMOVED="Maven 环境变量已移除"
TR_zh_UNINSTALL_SUCCESS="Maven 卸载成功!"
TR_zh_UNINSTALL_DONE="卸载完成"
TR_zh_BACKUP_NOTE="配置文件的备份已创建，扩展名是 .bak"
TR_zh_UNINSTALL_FINISH="卸载完成，请重启终端或运行: source %s"
TR_zh_MAVEN_NOT_INSTALLED="Maven 未安装"
TR_zh_MAVEN_INSTALLED="Maven 已安装"
TR_zh_PRESS_ENTER="按回车键返回菜单..."

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

# Detect operating system
detect_os() {
    local os_name=""
    case "$(uname -s)" in
        Linux)
            os_name="Linux"
            ;;
        Darwin)
            os_name="macOS"
            ;;
        *)
            print_error "$(tr UNSUPPORTED_OS): $(uname -s)"
            exit 1
            ;;
    esac
    print_info "$(printf "$(tr DETECTED_OS)" "$os_name")"
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

# Get latest Maven version from official Apache website
get_latest_version() {
    print_info "$(tr FETCHING)"
    # Use Maven official archive to get the latest version
    local version=$(curl -s https://maven.apache.org/download.cgi | grep -o 'apache-maven-[0-9][0-9.]*-bin.tar.gz' | head -1 | sed -E 's/apache-maven-(.*)-bin\.tar\.gz/\1/')
    if [[ -z "$version" ]]; then
        # Fallback to a known good version if fetch fails
        version="3.9.9"
        print_warning "Could not fetch latest version, using default: $version"
    fi
    echo "$version"
}

# Check if Maven is already installed
check_existing_maven() {
    if command -v mvn &> /dev/null; then
        local mvn_version=$(mvn -v | head -n1 | awk '{print $3}')
        local mvn_home=$(mvn -v | grep "Maven home" | awk '{print $3}')
        if [[ -z "$mvn_home" ]]; then
            mvn_home=$(which mvn | xargs dirname | xargs dirname)
        fi
        echo "$mvn_version|$mvn_home"
        return 0
    else
        # Check common locations
        if [[ -d "/usr/local/maven/bin/mvn" ]]; then
            local mvn_version=$(/usr/local/maven/bin/mvn -v | head -n1 | awk '{print $3}')
            echo "$mvn_version|/usr/local/maven"
            return 0
        elif [[ -d "/usr/local/apache-maven"*"/bin/mvn" ]]; then
            local mvn_dir=$(echo /usr/local/apache-maven-*)
            local mvn_version=$($mvn_dir/bin/mvn -v | head -n1 | awk '{print $3}')
            echo "$mvn_version|$mvn_dir"
            return 0
        elif [[ -d "$HOME/.local/maven/bin/mvn" ]]; then
            local mvn_version=$($HOME/.local/maven/bin/mvn -v | head -n1 | awk '{print $3}')
            echo "$mvn_version|$HOME/.local/maven"
            return 0
        fi
        echo ""
        return 1
    fi
}

# Find Maven installation location
find_maven_installation() {
    local found_loc=""
    local mvn_version=""
    if command -v mvn &> /dev/null; then
        mvn_version=$(mvn -v | head -n1 | awk '{print $3}')
        found_loc=$(mvn -v | grep "Maven home" | awk '{print $3}')
        if [[ -z "$found_loc" ]]; then
            found_loc=$(dirname "$(dirname "$(which mvn)")")
        fi
    else
        # Check common locations
        if [[ -d "/usr/local/maven" ]]; then
            found_loc="/usr/local/maven"
        elif [[ -d "/usr/local/apache-maven"* ]]; then
            found_loc=$(echo /usr/local/apache-maven-* | head -n1)
        elif [[ -d "$HOME/.local/maven" ]]; then
            found_loc="$HOME/.local/maven"
        elif [[ -d "$HOME/.local/apache-maven"* ]]; then
            found_loc=$(echo "$HOME/.local/apache-maven-"* | head -n1)
        fi
    fi
    echo "$found_loc"
}

# Check for Java (just check and warn, don't install)
check_java() {
    print_info "$(tr CHECK_JDK)"
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1)
        print_success "$(tr JDK_FOUND)"
        print_info "$(printf "$(tr JDK_VERSION)" "$java_version")"
        return 0
    else
        print_warning "$(tr JDK_NOT_FOUND)"
        return 1
    fi
}

# Download Maven
download_maven() {
    local version=$1
    local filename="apache-maven-${version}-bin.tar.gz"
    local download_url="https://archive.apache.org/dist/maven/maven-3/${version}/binaries/${filename}"

    print_info "$(printf "$(tr DOWNLOADING)" "$version")"
    echo >&2

    local temp_file="/tmp/${filename}"

    # Track temp file for cleanup
    TEMP_FILES+=("$temp_file")

    # Try wget first, then curl
    if command -v wget &> /dev/null; then
        if ! wget --progress=bar -O "$temp_file" "$download_url"; then
            print_error "$(tr DOWNLOAD_FAIL)"
            exit 1
        fi
    elif command -v curl &> /dev/null; then
        if ! curl --progress-bar -L -o "$temp_file" "$download_url"; then
            print_error "$(tr DOWNLOAD_FAIL)"
            exit 1
        fi
    else
        print_error "Neither wget nor curl found"
        exit 1
    fi

    echo >&2
    print_success "$(tr DOWNLOAD_COMPLETE)"

    echo "$temp_file"
}

# Install Maven
install_maven() {
    local archive=$1
    local version=$2

    print_info "$(printf "$(tr INSTALLING)" "$INSTALL_DIR")"

    # Remove old installation if exists
    local maven_install_dir="${INSTALL_DIR}/maven"
    if [[ -d "$maven_install_dir" ]]; then
        print_info "$(tr REMOVING_OLD)"
        rm -rf "$maven_install_dir"
    fi

    # Extract archive
    print_info "$(tr EXTRACTING)"
    mkdir -p "$INSTALL_DIR"
    tar -C "$INSTALL_DIR" -xzf "$archive"

    # Rename extracted directory to standard name
    local extracted_dir="${INSTALL_DIR}/apache-maven-${version}"
    if [[ ! -d "$extracted_dir" ]]; then
        print_error "$(tr EXTRACT_FAIL)"
        exit 1
    fi
    mv "$extracted_dir" "$maven_install_dir"

    print_success "$(tr EXTRACT_SUCCESS)"

    echo "$maven_install_dir"
}

# Configure environment variables
configure_environment() {
    local maven_home=$1
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

        # Remove existing Maven configuration
        sed -i '/# Maven Environment/d' "$config_file" 2>/dev/null || true
        sed -i '/export M2_HOME/d' "$config_file" 2>/dev/null || true
        sed -i '/maven\/bin/d' "$config_file" 2>/dev/null || true

        # Add new configuration
        cat >> "$config_file" <<EOF

# Maven Environment
export M2_HOME=${maven_home}
export PATH=\$PATH:\$M2_HOME/bin
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
    local maven_home="${INSTALL_DIR}/maven"
    export M2_HOME="$maven_home"
    export PATH="$PATH:$M2_HOME/bin"

    if command -v mvn &> /dev/null; then
        local mvn_version=$(mvn -v | head -n1)
        print_success "$(tr INSTALL_SUCCESS)"
        print_success "$(printf "$(tr VERSION_INFO)" "$mvn_version")"
        print_info "$(printf "$(tr MAVEN_HOME)" "$(mvn -v | grep "Maven home" | awk '{print $3}')")"
    else
        # Try the direct path
        if [[ -x "${M2_HOME}/bin/mvn" ]]; then
            local mvn_version=$(${M2_HOME}/bin/mvn -v | head -n1)
            print_success "$(tr INSTALL_SUCCESS)"
            print_success "$(printf "$(tr VERSION_INFO)" "$mvn_version")"
            print_info "$(printf "$(tr MAVEN_HOME)" "$M2_HOME")"
        else
            print_error "$(tr VERIFY_FAIL)"
            print_info "$(printf "$(tr SOURCE_TIP)" "$HOME/.bashrc")"
            exit 1
        fi
    fi
}

# Uninstall Maven
uninstall_maven() {
    print_info "$(tr UNINSTALL_TITLE)"
    print_info "$(tr FINDING_MAVEN)"

    local maven_location=$(find_maven_installation)

    if [[ -z "$maven_location" || ! -d "$maven_location" ]]; then
        print_warning "$(tr MAVEN_NOT_FOUND)"
        return
    fi

    print_success "$(printf "$(tr MAVEN_FOUND)" "$maven_location")"

    # Confirm uninstall
    echo
    read -p "$(printf "$(tr UNINSTALL_CONFIRM)")" -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "$(tr UNINSTALL_CANCEL)"
        return
    fi

    # Remove Maven installation directory
    print_info "$(tr REMOVING_MAVEN)"
    if [[ -d "$maven_location" ]]; then
        rm -rf "$maven_location"
        print_success "$(tr REMOVING_MAVEN_DONE)"
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
            # Remove Maven configuration
            sed -i '/# Maven Environment/d' "$config_file" 2>/dev/null || true
            sed -i '/export M2_HOME/d' "$config_file" 2>/dev/null || true
            sed -i '/maven\/bin/d' "$config_file" 2>/dev/null || true
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

# Check Maven status
check_status() {
    echo
    if check_existing_maven; then
        IFS='|' read -r mvn_version mvn_home <<< "$(check_existing_maven)"
        print_success "$(tr MAVEN_INSTALLED)"
        print_info "$(printf "$(tr VERSION_INFO)" "$mvn_version")"
        print_info "$(printf "$(tr MAVEN_HOME)" "$mvn_home")"
    else
        print_warning "$(tr MAVEN_NOT_INSTALLED)"
    fi
    echo
    check_java || true
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

    detect_os

    # Check Java but don't install it
    check_java || true

    local existing_info=$(check_existing_maven)
    if [[ -n "$existing_info" ]]; then
        IFS='|' read -r existing_version existing_home <<< "$existing_info"
        print_warning "$(printf "$(tr ALREADY_INSTALLED) %s" "$existing_version")"
        print_info "$(printf "$(tr MAVEN_HOME)" "$existing_home")"
        read -p "$(printf "$(tr REINSTALL_PROMPT)")" -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "$(tr INSTALL_CANCEL)"
            return
        fi
    fi

    local latest_version=$(get_latest_version)
    print_success "$(printf "$(tr LATEST_VERSION)" "$latest_version")"

    if [[ "$existing_version" == "$latest_version" ]]; then
        print_info "$(tr ALREADY_LATEST)"
        return
    fi

    local archive=$(download_maven "$latest_version")
    local maven_home=$(install_maven "$archive" "$latest_version")
    configure_environment "$maven_home"
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
    echo -e "  ${GREEN}mvn -v${NC}"
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
                uninstall_maven
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
