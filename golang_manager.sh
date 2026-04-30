#!/bin/bash

##############################################################################
# Go Language Installation & Uninstallation Manager
# Description: Automatically install the latest version of Go or uninstall
#              existing Go installation. Supports multiple languages.
# Usage: sudo bash golang_manager.sh
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
BASHRC_FILE="$HOME/.bashrc"
ZSHRC_FILE="$HOME/.zshrc"
PROFILE_FILE="$HOME/.profile"

# Language settings (default: English)
LANG_SELECTION="en"

# Translations
# English
TR_en_TITLE="Go Language Installation & Uninstallation Manager"
TR_en_WELCOME="Welcome to Go Language Manager"
TR_en_SELECT_LANG="Please select your language / 请选择你的语言:"
TR_en_SELECT_OP="Please select operation:"
TR_en_INSTALL="Install Go"
TR_en_UNINSTALL="Uninstall Go"
TR_en_EXIT="Exit"
TR_en_ENTER_CHOICE="Enter your choice (1-3): "
TR_en_INVALID_CHOICE="Invalid choice, exiting..."
TR_en_NOT_ROOT_WARNING="This script is not running as root. Installation to /usr/local requires root privileges."
TR_en_SUDO_TIP="You can run: sudo bash $0"
TR_en_CONTINUE_PROMPT="Continue with current user privileges? (y/n): "
TR_en_UNSUPPORTED_ARCH="Unsupported architecture: %s"
TR_en_FETCH_FAIL="Failed to fetch the latest Go version"
TR_en_FETCHING="Fetching latest Go version..."
TR_en_LATEST_VERSION="Latest version available: %s"
TR_en_ALREADY_INSTALLED="Go is already installed: %s"
TR_en_REINSTALL_PROMPT="Do you want to reinstall/update? (y/n): "
TR_en_INSTALL_CANCEL="Installation cancelled"
TR_en_ALREADY_LATEST="You already have the latest version installed"
TR_en_DOWNLOADING="Downloading Go %s for %s-%s..."
TR_en_DOWNLOAD_COMPLETE="Download completed"
TR_en_DOWNLOAD_FAIL="Failed to download Go"
TR_en_INSTALLING="Installing Go to %s..."
TR_en_REMOVING_OLD="Removing old Go installation..."
TR_en_EXTRACTING="Extracting archive (this may take a moment)..."
TR_en_EXTRACT_FAIL="Installation failed: Go directory not found"
TR_en_EXTRACT_SUCCESS="Go extracted successfully"
TR_en_CONFIGURING="Configuring environment variables..."
TR_en_BACKUP_CREATED="Created backup: %s"
TR_en_ENV_ADDED="Environment variables added to %s"
TR_en_ENV_EXISTS="Go environment variables already exist in %s"
TR_en_UPDATING_CONFIG="Updating existing configuration..."
TR_en_CONFIG_UPDATED="Configuration updated"
TR_en_CONFIG_ERROR="Syntax error detected in %s!"
TR_en_RESTORING_BACKUP="Restoring from backup..."
TR_en_BACKUP_RESTORED="Backup restored successfully"
TR_en_VERIFYING="Verifying installation..."
TR_en_INSTALL_SUCCESS="Go installed successfully!"
TR_en_VERSION_INFO="Version: %s"
TR_en_GOROOT_INFO="GOROOT: %s"
TR_en_GOPATH_INFO="GOPATH: %s"
TR_en_VERIFY_FAIL="Installation verification failed"
TR_en_SOURCE_TIP="Please manually run: source %s"
TR_en_INSTALL_COMPLETE="Installation completed successfully!"
TR_en_CONFIG_DONE="Go is now configured in %s"
TR_en_SOURCE_CURRENT="To use Go in your CURRENT terminal, run:"
TR_en_AUTO_NEW="For NEW terminals, Go will work automatically!"
TR_en_VERIFY_CMD="Verify installation with:"
TR_en_CLEANING="Cleaning up temporary files..."
TR_en_CLEANUP_DONE="Cleanup completed"
TR_en_UNINSTALL_TITLE="Starting Go uninstallation..."
TR_en_FINDING_GO="Searching for existing Go installation..."
TR_en_GO_NOT_FOUND="No existing Go installation found"
TR_en_GO_FOUND_FOUND="Found Go installation at: %s"
TR_en_GO_FOUND_IN_PATH="Found Go in PATH: %s"
TR_en_UNINSTALL_CONFIRM="Are you sure you want to uninstall Go? This will remove the Go installation and clean up environment variables. (y/n): "
TR_en_UNINSTALL_CANCEL="Uninstallation cancelled"
TR_en_REMOVING_GO="Removing Go installation directory..."
TR_en_REMOVING_GO_DONE="Go installation directory removed"
TR_en_REMOVING_ENV="Removing Go environment variables from configuration files..."
TR_en_ENV_REMOVED="Go environment variables removed"
TR_en_UNINSTALL_SUCCESS="Go uninstalled successfully!"
TR_en_UNINSTALL_DONE="Uninstallation completed"
TR_en_REMOVE_GOPATH="Do you want to remove GOPATH directory (%s) including all your Go projects and modules? This cannot be undone! (y/n): "
TR_en_REMOVING_GOPATH="Removing GOPATH directory..."
TR_en_GOPATH_REMOVED="GOPATH directory removed"
TR_en_BACKUP_NOTE="A backup of your configuration files has been created with .bak extension"
TR_en_UNINSTALL_FINISH="Uninstallation completed. Please restart your terminal or run: source %s"

# Chinese
TR_zh_TITLE="Go 语言安装卸载管理器"
TR_zh_WELCOME="欢迎使用 Go 语言管理器"
TR_zh_SELECT_LANG="请选择你的语言 / Please select your language:"
TR_zh_SELECT_OP="请选择操作:"
TR_zh_INSTALL="安装 Go"
TR_zh_UNINSTALL="卸载 Go"
TR_zh_EXIT="退出"
TR_zh_ENTER_CHOICE="请输入你的选择 (1-3): "
TR_zh_INVALID_CHOICE="无效选择，退出..."
TR_zh_NOT_ROOT_WARNING="当前不是 root 用户，安装到 /usr/local 需要 root 权限"
TR_zh_SUDO_TIP="你可以使用: sudo bash $0"
TR_zh_CONTINUE_PROMPT="是否继续使用当前用户权限安装？(y/n): "
TR_zh_UNSUPPORTED_ARCH="不支持的架构: %s"
TR_zh_FETCH_FAIL="获取最新 Go 版本失败"
TR_zh_FETCHING="正在获取最新 Go 版本..."
TR_zh_LATEST_VERSION="最新可用版本: %s"
TR_zh_ALREADY_INSTALLED="Go 已经安装: %s"
TR_zh_REINSTALL_PROMPT="是否重新安装/更新？(y/n): "
TR_zh_INSTALL_CANCEL="安装已取消"
TR_zh_ALREADY_LATEST="你已经安装了最新版本"
TR_zh_DOWNLOADING="正在下载 Go %s 对应 %s-%s..."
TR_zh_DOWNLOAD_COMPLETE="下载完成"
TR_zh_DOWNLOAD_FAIL="下载 Go 失败"
TR_zh_INSTALLING="正在安装 Go 到 %s..."
TR_zh_REMOVING_OLD="正在移除旧的 Go 安装..."
TR_zh_EXTRACTING="正在解压压缩包 (可能需要一点时间)..."
TR_zh_EXTRACT_FAIL="安装失败: 未找到 Go 目录"
TR_zh_EXTRACT_SUCCESS="Go 解压成功"
TR_zh_CONFIGURING="正在配置环境变量..."
TR_zh_BACKUP_CREATED="已创建备份: %s"
TR_zh_ENV_ADDED="环境变量已添加到 %s"
TR_zh_ENV_EXISTS="Go 环境变量已存在于 %s"
TR_zh_UPDATING_CONFIG="正在更新现有配置..."
TR_zh_CONFIG_UPDATED="配置已更新"
TR_zh_CONFIG_ERROR="检测到 %s 存在语法错误!"
TR_zh_RESTORING_BACKUP="正在从备份恢复..."
TR_zh_BACKUP_RESTORED="备份恢复成功"
TR_zh_VERIFYING="正在验证安装..."
TR_zh_INSTALL_SUCCESS="Go 安装成功!"
TR_zh_VERSION_INFO="版本: %s"
TR_zh_GOROOT_INFO="GOROOT: %s"
TR_zh_GOPATH_INFO="GOPATH: %s"
TR_zh_VERIFY_FAIL="安装验证失败"
TR_zh_SOURCE_TIP="请手动运行: source %s"
TR_zh_INSTALL_COMPLETE="安装完成成功!"
TR_zh_CONFIG_DONE="Go 已在 %s 中配置完成"
TR_zh_SOURCE_CURRENT="在当前终端使用 Go，请运行:"
TR_zh_AUTO_NEW="新开终端会自动生效 Go 命令!"
TR_zh_VERIFY_CMD="验证安装请运行:"
TR_zh_CLEANING="正在清理临时文件..."
TR_zh_CLEANUP_DONE="清理完成"
TR_zh_UNINSTALL_TITLE="开始卸载 Go..."
TR_zh_FINDING_GO="正在搜索已安装的 Go..."
TR_zh_GO_NOT_FOUND="未找到已安装的 Go"
TR_zh_GO_FOUND_FOUND="在以下位置找到 Go: %s"
TR_zh_GO_FOUND_IN_PATH="在 PATH 中找到 Go: %s"
TR_zh_UNINSTALL_CONFIRM="确认要卸载 Go 吗？这将删除 Go 安装并清理环境变量。(y/n): "
TR_zh_UNINSTALL_CANCEL="卸载已取消"
TR_zh_REMOVING_GO="正在删除 Go 安装目录..."
TR_zh_REMOVING_GO_DONE="Go 安装目录已删除"
TR_zh_REMOVING_ENV="正在从配置文件中移除 Go 环境变量..."
TR_zh_ENV_REMOVED="Go 环境变量已移除"
TR_zh_UNINSTALL_SUCCESS="Go 卸载成功!"
TR_zh_UNINSTALL_DONE="卸载完成"
TR_zh_REMOVE_GOPATH="是否要删除 GOPATH 目录 (%s) 包括所有你的 Go 项目和模块？此操作不可撤销! (y/n): "
TR_zh_REMOVING_GOPATH="正在删除 GOPATH 目录..."
TR_zh_GOPATH_REMOVED="GOPATH 目录已删除"
TR_zh_BACKUP_NOTE="配置文件的备份已创建，扩展名是 .bak"
TR_zh_UNINSTALL_FINISH="卸载完成，请重启终端或运行: source %s"

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

# Select operation
select_operation() {
    echo
    echo "================================================"
    echo "$(tr TITLE)"
    echo "================================================"
    echo
    echo "$(tr SELECT_OP)"
    echo
    echo "1) $(tr INSTALL)"
    echo "2) $(tr UNINSTALL)"
    echo "3) $(tr EXIT)"
    echo
    read -p "$(tr ENTER_CHOICE)" -r < /dev/tty
    echo
    case $REPLY in
        1)
            OPERATION="install"
            ;;
        2)
            OPERATION="uninstall"
            ;;
        3)
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

# Detect system architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv6l)
            echo "armv6l"
            ;;
        armv7l)
            echo "armv6l"
            ;;
        i386|i686)
            echo "386"
            ;;
        *)
            print_error "$(printf "$(tr UNSUPPORTED_ARCH)" "$arch")"
            exit 1
            ;;
    esac
}

# Get latest Go version
get_latest_version() {
    print_info "$(tr FETCHING)"
    local version=$(curl -s https://go.dev/dl/?mode=json | grep -oP '"version": ?"go[0-9.]+[^"]*' | head -1 | cut -d'"' -f4)
    if [[ -z "$version" ]]; then
        print_error "$(tr FETCH_FAIL)"
        exit 1
    fi
    echo "$version"
}

# Check if Go is already installed
check_existing_go() {
    if command -v go &> /dev/null; then
        local current_version=$(go version | awk '{print $3}')
        echo "$current_version"
        return 0
    else
        # Check common locations
        if [[ -d "/usr/local/go" ]]; then
            if [[ -x "/usr/local/go/bin/go" ]]; then
                local current_version=$(/usr/local/go/bin/go version | awk '{print $3}')
                echo "$current_version"
                return 0
            fi
        fi
        if [[ -d "$HOME/.local/go" ]]; then
            if [[ -x "$HOME/.local/go/bin/go" ]]; then
                local current_version=$("$HOME/.local/go/bin/go" version | awk '{print $3}')
                echo "$current_version"
                return 0
            fi
        fi
        echo ""
        return 1
    fi
}

# Find Go installation location
find_go_installation() {
    # Check common locations
    local found_loc=""
    if [[ -d "/usr/local/go" && -x "/usr/local/go/bin/go" ]]; then
        found_loc="/usr/local/go"
    elif [[ -d "$HOME/.local/go" && -x "$HOME/.local/go/bin/go" ]]; then
        found_loc="$HOME/.local/go"
    elif command -v go &> /dev/null; then
        local go_bin=$(which go)
        local go_root=$(go env GOROOT 2>/dev/null)
        if [[ -n "$go_root" && -d "$go_root" ]]; then
            found_loc="$go_root"
        else
            # Try to resolve from binary path
            local go_dir=$(dirname "$(dirname "$go_bin")")
            if [[ -d "$go_dir" && -x "$go_dir/bin/go" ]]; then
                found_loc="$go_dir"
            fi
        fi
    fi
    echo "$found_loc"
}

# Download Go
download_go() {
    local version=$1
    local arch=$2
    local os="linux"
    local filename="${version}.${os}-${arch}.tar.gz"
    local download_url="https://go.dev/dl/${filename}"

    print_info "$(printf "$(tr DOWNLOADING)" "$version" "$os" "$arch")"
    echo >&2

    local temp_file="/tmp/${filename}"

    # Use curl with progress bar
    if ! curl --progress-bar -L -o "$temp_file" "${download_url}"; then
        print_error "$(tr DOWNLOAD_FAIL)"
        exit 1
    fi

    # Track temp file for cleanup
    TEMP_FILES+=("$temp_file")

    echo >&2
    print_success "$(tr DOWNLOAD_COMPLETE)"

    echo "$temp_file"
}

# Install Go
install_go() {
    local archive=$1

    print_info "$(printf "$(tr INSTALLING)" "$INSTALL_DIR")"

    # Remove old installation if exists
    if [[ -d "${INSTALL_DIR}/go" ]]; then
        print_info "$(tr REMOVING_OLD)"
        rm -rf "${INSTALL_DIR}/go"
    fi

    # Extract archive with progress indicator
    print_info "$(tr EXTRACTING)"

    # Show a simple spinner while extracting
    {
        tar -C "${INSTALL_DIR}" -xzf "${archive}" &
        local pid=$!
        local spin='-\|/'
        local i=0
        while kill -0 $pid 2>/dev/null; do
            i=$(( (i+1) %4 ))
            printf "\r${BLUE}[INFO]${NC} %s ${spin:$i:1}" "$(tr EXTRACTING)" >&2
            sleep .1
        done
        wait $pid
        printf "\r" >&2
    }

    if [[ ! -d "${INSTALL_DIR}/go" ]]; then
        print_error "$(tr EXTRACT_FAIL)"
        exit 1
    fi

    print_success "$(tr EXTRACT_SUCCESS)"
}

# Configure environment variables
configure_environment() {
    print_info "$(tr CONFIGURING)"

    # GOROOT path
    local goroot="${INSTALL_DIR}/go"
    local gopath="$HOME/go"

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

        # Remove existing Go configuration
        sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$config_file" 2>/dev/null || true

        # Add new configuration
        cat >> "$config_file" <<EOF

# Go Lang Environment
export GOROOT=${goroot}
export GOPATH=${gopath}
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin
EOF
    }

    # Add to all common config files that exist
    local modified=0
    for config_file in "$BASHRC_FILE" "$ZSHRC_FILE" "$PROFILE_FILE"; do
        if [[ -f "$config_file" ]]; then
            add_to_config "$config_file"
            modified=$((modified + 1))
            print_success "$(printf "$(tr ENV_ADDED)" "$config_file")"
        fi
    done

    # Verify configuration files are still valid
    for config_file in "$BASHRC_FILE" "$ZSHRC_FILE" "$PROFILE_FILE"; do
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
    for config_file in "$BASHRC_FILE" "$ZSHRC_FILE" "$PROFILE_FILE"; do
        if [[ -f "$config_file" ]]; then
            ls -t "${config_file}.bak."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
        fi
    done
}

# Verify installation
verify_installation() {
    print_info "$(tr VERIFYING)"

    # Load environment for verification
    export GOROOT="${INSTALL_DIR}/go"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

    if command -v go &> /dev/null; then
        local installed_version=$(go version)
        print_success "$(tr INSTALL_SUCCESS)"
        print_success "$(printf "$(tr VERSION_INFO)" "$installed_version")"
        print_info "$(printf "$(tr GOROOT_INFO)" "$(go env GOROOT)")"
        print_info "$(printf "$(tr GOPATH_INFO)" "$(go env GOPATH)")"
    else
        # Try the direct path
        if [[ -x "${GOROOT}/bin/go" ]]; then
            local installed_version="$(${GOROOT}/bin/go version)"
            print_success "$(tr INSTALL_SUCCESS)"
            print_success "$(printf "$(tr VERSION_INFO)" "$installed_version")"
            print_info "$(printf "$(tr GOROOT_INFO)" "${GOROOT}")"
            print_info "$(printf "$(tr GOPATH_INFO)" "$GOPATH")"
        else
            print_error "$(tr VERIFY_FAIL)"
            print_info "$(printf "$(tr SOURCE_TIP)" "$BASHRC_FILE")"
            exit 1
        fi
    fi
}

# Uninstall Go
uninstall_go() {
    print_info "$(tr UNINSTALL_TITLE)"
    print_info "$(tr FINDING_GO)"

    local go_location=$(find_go_installation)

    if [[ -z "$go_location" ]]; then
        print_warning "$(tr GO_NOT_FOUND)"
        exit 0
    fi

    print_success "$(printf "$(tr GO_FOUND_FOUND)" "$go_location")"

    # Show version
    if [[ -x "$go_location/bin/go" ]]; then
        local version=$("$go_location/bin/go" version)
        print_info "$(printf "$(tr GO_FOUND_IN_PATH)" "$version")"
    fi

    # Confirm uninstall
    echo
    read -p "$(printf "$(tr UNINSTALL_CONFIRM)")" -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "$(tr UNINSTALL_CANCEL)"
        exit 0
    fi

    # Remove Go installation directory
    print_info "$(tr REMOVING_GO)"
    if [[ -d "$go_location" ]]; then
        rm -rf "$go_location"
        print_success "$(tr REMOVING_GO_DONE)"
    fi

    # Remove environment variables from config files
    print_info "$(tr REMOVING_ENV)"
    for config_file in "$BASHRC_FILE" "$ZSHRC_FILE" "$PROFILE_FILE"; do
        if [[ -f "$config_file" ]]; then
            # Create backup
            local backup_file="${config_file}.bak.$(date +%s)"
            cp "$config_file" "$backup_file"
            # Remove Go block
            sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$config_file" 2>/dev/null || true
        fi
    done
    print_success "$(tr ENV_REMOVED)"

    # Ask about removing GOPATH
    local gopath="$HOME/go"
    if [[ -d "$gopath" ]]; then
        echo
        read -p "$(printf "$(tr REMOVE_GOPATH)" "$gopath")" -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "$(tr REMOVING_GOPATH)"
            rm -rf "$gopath"
            print_success "$(tr GOPATH_REMOVED)"
        fi
    fi

    echo
    print_success "$(tr UNINSTALL_SUCCESS)"
    echo "================================================"
    print_success "$(tr UNINSTALL_DONE)"
    echo "================================================"
    echo
    print_info "$(tr BACKUP_NOTE)"
    echo
    print_info "$(printf "$(tr UNINSTALL_FINISH)" "$BASHRC_FILE")"
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

    # Also clean up any other Go archives in /tmp
    rm -f /tmp/go*.tar.gz 2>/dev/null || true

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

    local existing_version=$(check_existing_go)
    if [[ -n "$existing_version" ]]; then
        print_warning "$(printf "$(tr ALREADY_INSTALLED)" "$existing_version")"
        read -p "$(printf "$(tr REINSTALL_PROMPT)")" -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "$(tr INSTALL_CANCEL)"
            exit 0
        fi
    fi

    local latest_version=$(get_latest_version)
    print_success "$(printf "$(tr LATEST_VERSION)" "$latest_version")"

    if [[ "$existing_version" == "$latest_version" ]]; then
        print_info "$(tr ALREADY_LATEST)"
        exit 0
    fi

    local archive=$(download_go "$latest_version" "$arch")
    install_go "$archive"
    configure_environment
    verify_installation

    echo
    echo "================================================"
    print_success "$(tr INSTALL_COMPLETE)"
    echo "================================================"
    echo
    print_success "$(printf "$(tr CONFIG_DONE)" "$BASHRC_FILE")"
    echo
    print_info "$(tr SOURCE_CURRENT)"
    echo -e "  ${GREEN}source ~/.bashrc${NC}"
    echo
    print_info "$(tr AUTO_NEW)"
    echo
    print_info "$(tr VERIFY_CMD)"
    echo -e "  ${GREEN}go version${NC}"
    echo
}

# Main function
main() {
    select_language
    select_operation

    if [[ "$OPERATION" == "install" ]]; then
        main_install
    elif [[ "$OPERATION" == "uninstall" ]]; then
        uninstall_go
    fi
}

# Run main function
main
