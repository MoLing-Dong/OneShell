#!/bin/bash

##############################################################################
# OpenSSH Server Installation & Management Script
# Description: Install, configure, or uninstall OpenSSH Server
#              Supports multiple languages, for WSL Ubuntu/Debian-based systems
# Usage: sudo bash ssh_setup.sh
# Platform: WSL Ubuntu / Debian-based systems
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
SSHD_CONFIG="/etc/ssh/sshd_config"
PASSWORD_FILE="/root/.ssh_password"

# Language settings (default: English)
LANG_SELECTION="en"

# Translations
# English
TR_en_TITLE="OpenSSH Server Installation & Management"
TR_en_WELCOME="Welcome to OpenSSH Server Manager"
TR_en_SELECT_LANG="Please select your language / 请选择你的语言:"
TR_en_SELECT_OP="Please select operation:"
TR_en_INSTALL="Install & Configure OpenSSH Server"
TR_en_UNINSTALL="Uninstall OpenSSH Server"
TR_en_CHECK="Check SSH Status"
TR_en_UNINSTALL_CONFIRM="Are you sure you want to uninstall OpenSSH Server? This will:
- Remove openssh-server package
- Keep backup of configuration
- Disable SSH service will be stopped
This cannot be undone! (y/n): "
TR_en_EXIT="Exit"
TR_en_ENTER_CHOICE="Enter your choice (1-4): "
TR_en_INVALID_CHOICE="Invalid choice, exiting..."
TR_en_NOT_ROOT_ERROR="This script must be run as root (with sudo)"
TR_en_PLEASE_RUN_SUDO="Please run: sudo bash $0"
TR_en_NOT_DEBIAN="This script is designed for Debian/Ubuntu based systems"
TR_en_CHECKING_PORT="Checking port 22 availability..."
TR_en_PORT_IN_USE="Port 22 is already in use, SSH service may be running"
TR_en_RECONFIGURE="This script will reconfigure and restart the SSH service"
TR_en_PORT_AVAIL="Port 22 is available"
TR_en_UPDATING_PACKAGES="Updating package sources..."
TR_en_PACKAGES_UPDATED="Package sources updated"
TR_en_INSTALLING_SSH="Installing OpenSSH Server..."
TR_en_SSH_INSTALLED="OpenSSH Server installed"
TR_en_BACKING_UP="Backing up SSH configuration..."
TR_en_BACKUP_DONE="Original configuration backed up"
TR_en_NEW_BACKUP="Original backup already exists, creating timestamped backup"
TR_en_CONFIGURING_SSH="Configuring SSH settings..."
TR_en_BASIC_CONFIG="Basic authentication configured"
TR_en_APPLY_OPTIMIZE="Applying performance optimizations..."
TR_en_OPTIMIZE_DONE="Performance optimizations applied"
TR_en_VERIFYING_CONFIG="Verifying SSH configuration syntax..."
TR_en_CONFIG_VALID="Configuration syntax is valid"
TR_en_CONFIG_ERROR="Configuration syntax error detected!"
TR_en_RESTORING_BACKUP="Restoring from backup..."
TR_en_CONFIG_RESTORED="Configuration restored from backup"
TR_en_CHECKING_ROOT_PASSWORD="Checking root password status..."
TR_en_ROOT_NO_PASSWORD="Root has no password, generating random password..."
TR_en_RANDOM_PASS_SAVED="Random password generated and saved to: %s"
TR_en_PASSWORD="Password: %s"
TR_en_ROOT_PASSWORD_EXISTS="Root password already set, skipping"
TR_en_RESTARTING_SSH="Restarting SSH service..."
TR_en_SSH_RESTARTED="SSH service restarted (%s)"
TR_en_VERIFYING_INSTALL="Verifying installation..."
TR_en_INSTALL_VERIFIED="Installation verified successfully"
TR_en_CONNECTION_INFO="Connection Information:"
TR_en_FROM_WINDOWS="From Windows:"
TR_en_LOCAL="Local:"
TR_en_PASSWORD_SAVED="Password saved to:"
TR_en_VIEW_PASSWORD="View password:"
TR_en_USE_EXISTING_PASS="Use existing root password to login"
TR_en_TEST_CONNECTION="To test connection:"
TR_en_INSTALL_SUCCESS="SSH Server configured successfully!"
TR_en_CLEANUP_FAILED="Installation failed, cleaning up temporary files..."
TR_en_CLEANUP_DONE="Cleanup completed"
TR_en_UNINSTALL_START="Starting OpenSSH Server uninstallation"
TR_en_FINDING_SSH="Checking if OpenSSH Server is installed..."
TR_en_SSH_NOT_FOUND="OpenSSH Server is not installed"
TR_en_SSH_FOUND="OpenSSH Server is installed at: %s"
TR_en_UNINSTALL_CANCEL="Uninstallation cancelled"
TR_en_STOPPING_SSH="Stopping SSH service..."
TR_en_SSH_STOPPED="SSH service stopped"
TR_en_REMOVING_PACKAGE="Removing openssh-server package..."
TR_en_PACKAGE_REMOVED="openssh-server package removed"
TR_en_KEEP_BACKUP="Keeping configuration backup is kept at: %s"
TR_en_UNINSTALL_SUCCESS="OpenSSH Server uninstalled successfully"
TR_en_UNINSTALL_DONE="Uninstallation completed"
TR_en_SSH_STATUS="OpenSSH Server Status"
TR_en_SSH_RUNNING="OpenSSH Server is installed and running"
TR_en_SSH_NOT_RUNNING="OpenSSH Server is installed but not running"
TR_en_SSH_NOT_INSTALLED="OpenSSH Server is not installed"
TR_en_LISTENING_PORT="Listening on port:"
TR_en_CURRENT_CONFIG="Active configuration:"
TR_en_PRESS_ENTER="Press Enter to return to menu..."

# Chinese
TR_zh_TITLE="OpenSSH 服务器安装管理器"
TR_zh_WELCOME="欢迎使用 OpenSSH 服务器管理器"
TR_zh_SELECT_LANG="请选择你的语言 / Please select your language:"
TR_zh_SELECT_OP="请选择操作:"
TR_zh_INSTALL="安装并配置 OpenSSH 服务器"
TR_zh_UNINSTALL="卸载 OpenSSH 服务器"
TR_zh_CHECK="检查 SSH 状态"
TR_zh_UNINSTALL_CONFIRM="确认要卸载 OpenSSH 服务器吗？这将：
- 移除 openssh-server 软件包
- 保留配置文件备份
- SSH 服务会被停止
此操作不可撤销！(y/n): "
TR_zh_EXIT="退出"
TR_zh_ENTER_CHOICE="请输入你的选择 (1-4): "
TR_zh_INVALID_CHOICE="无效选择，退出..."
TR_zh_NOT_ROOT_ERROR="此脚本必须以 root 身份运行 (使用 sudo)"
TR_zh_PLEASE_RUN_SUDO="请运行: sudo bash $0"
TR_zh_NOT_DEBIAN="此脚本仅适用于 Debian/Ubuntu 系列系统"
TR_zh_CHECKING_PORT="正在检查端口 22 是否可用..."
TR_zh_PORT_IN_USE="端口 22 已被占用，SSH 服务可能已经在运行"
TR_zh_RECONFIGURE="脚本将重新配置并重启 SSH 服务"
TR_zh_PORT_AVAIL="端口 22 可用"
TR_zh_UPDATING_PACKAGES="正在更新软件源..."
TR_zh_PACKAGES_UPDATED="软件源更新完成"
TR_zh_INSTALLING_SSH="正在安装 OpenSSH 服务器..."
TR_zh_SSH_INSTALLED="OpenSSH 服务器安装完成"
TR_zh_BACKING_UP="正在备份 SSH 配置..."
TR_zh_BACKUP_DONE="原始配置已备份"
TR_zh_NEW_BACKUP="原始备份已存在，创建带时间戳的备份"
TR_zh_CONFIGURING_SSH="正在配置 SSH 设置..."
TR_zh_BASIC_CONFIG="基础认证配置完成"
TR_zh_APPLY_OPTIMIZE="正在应用性能优化..."
TR_zh_OPTIMIZE_DONE="性能优化应用完成"
TR_zh_VERIFYING_CONFIG="正在验证 SSH 配置语法..."
TR_zh_CONFIG_VALID="配置语法有效"
TR_zh_CONFIG_ERROR="检测到配置语法错误!"
TR_zh_RESTORING_BACKUP="正在从备份恢复..."
TR_zh_CONFIG_RESTORED="配置已从备份恢复"
TR_zh_CHECKING_ROOT_PASSWORD="正在检查 root 密码状态..."
TR_zh_ROOT_NO_PASSWORD="Root 没有密码，正在生成随机密码..."
TR_zh_RANDOM_PASS_SAVED="随机密码已生成并保存到: %s"
TR_zh_PASSWORD="密码: %s"
TR_zh_ROOT_PASSWORD_EXISTS="Root 密码已设置，跳过"
TR_zh_RESTARTING_SSH="正在重启 SSH 服务..."
TR_zh_SSH_RESTARTED="SSH 服务已重启 (%s)"
TR_zh_VERIFYING_INSTALL="正在验证安装..."
TR_zh_INSTALL_VERIFIED="安装验证成功"
TR_zh_CONNECTION_INFO="连接信息:"
TR_zh_FROM_WINDOWS="Windows 连接:"
TR_zh_LOCAL="本地连接:"
TR_zh_PASSWORD_SAVED="密码保存在:"
TR_zh_VIEW_PASSWORD="查看密码:"
TR_zh_USE_EXISTING_PASS="使用现有 root 密码登录"
TR_zh_TEST_CONNECTION="测试连接:"
TR_zh_INSTALL_SUCCESS="SSH 服务器配置成功!"
TR_zh_CLEANUP_FAILED="安装失败，正在清理临时文件..."
TR_zh_CLEANUP_DONE="清理完成"
TR_zh_UNINSTALL_START="开始卸载 OpenSSH 服务器"
TR_zh_FINDING_SSH="正在检查 OpenSSH 是否已安装..."
TR_zh_SSH_NOT_FOUND="OpenSSH 服务器未安装"
TR_zh_SSH_FOUND="OpenSSH 服务器已安装在: %s"
TR_zh_UNINSTALL_CANCEL="卸载已取消"
TR_zh_STOPPING_SSH="正在停止 SSH 服务..."
TR_zh_SSH_STOPPED="SSH 服务已停止"
TR_zh_REMOVING_PACKAGE="正在移除 openssh-server 软件包..."
TR_zh_PACKAGE_REMOVED="openssh-server 软件包已移除"
TR_zh_KEEP_BACKUP="配置已备份保留在: %s"
TR_zh_UNINSTALL_SUCCESS="OpenSSH 服务器卸载成功"
TR_zh_UNINSTALL_DONE="卸载完成"
TR_zh_SSH_STATUS="OpenSSH 服务器状态"
TR_zh_SSH_RUNNING="OpenSSH 服务器已安装并正在运行"
TR_zh_SSH_NOT_RUNNING="OpenSSH 服务器已安装但未运行"
TR_zh_SSH_NOT_INSTALLED="OpenSSH 服务器未安装"
TR_zh_LISTENING_PORT="监听端口:"
TR_zh_CURRENT_CONFIG="当前配置:"
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

# Check if running on Debian-based system
check_debian() {
    if [[ ! -f /etc/debian_version ]]; then
        print_error "$(tr NOT_DEBIAN)"
        exit 1
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "$(tr NOT_ROOT_ERROR)"
        print_info "$(printf "$(tr PLEASE_RUN_SUDO)")"
        exit 1
    fi
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
    read -p "Enter your choice (1-2): " -n 1 -r
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
    clear
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
    read -p "$(tr ENTER_CHOICE)" -r
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

# Check if SSH port is already in use
check_ssh_port() {
    print_info "$(tr CHECKING_PORT)"

    if netstat -tlnp 2>/dev/null | grep -q ":22 " || ss -tlnp 2>/dev/null | grep -q ":22 "; then
        print_warning "$(tr PORT_IN_USE)"
        print_info "$(tr RECONFIGURE)"
        return 0
    fi

    print_success "$(tr PORT_AVAIL)"
}

# Check SSH is installed
is_ssh_installed() {
    if dpkg -l | grep -q "^ii.*openssh-server; then
        return 0
    else
        return 1
    fi
}

# Install required packages
install_packages() {
    print_info "$(tr UPDATING_PACKAGES)"
    apt update -y > /dev/null 2>&1
    print_success "$(tr PACKAGES_UPDATED)"

    print_info "$(tr INSTALLING_SSH)"
    apt install -y openssh-server net-tools > /dev/null 2>&1
    print_success "$(tr SSH_INSTALLED)"
}

# Backup SSH configuration
backup_config() {
    print_info "$(tr BACKING_UP)"

    if [[ -f "$SSHD_CONFIG" && ! -f "${SSHD_CONFIG}.bak.original" ]]; then
        cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.original"
        print_success "$(tr BACKUP_DONE)"
    elif [[ -f "$SSHD_CONFIG" ]]; then
        print_info "$(tr NEW_BACKUP)"
        local backup_file="${SSHD_CONFIG}.bak.$(date +%s)"
        cp "$SSHD_CONFIG" "$backup_file"
        TEMP_FILES+=("$backup_file")
    fi

    # Clean up old backups (keep only the last 5 timestamped backups)
    ls -t "${SSHD_CONFIG}.bak."[0-9]* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
}

# Configure SSH settings
configure_ssh() {
    print_info "$(tr CONFIGURING_SSH)"

    # Basic authentication settings
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
    sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
    sed -i 's/^#*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"

    print_success "$(tr BASIC_CONFIG)"
}

# Apply performance optimizations
apply_optimizations() {
    print_info "$(tr APPLY_OPTIMIZE)"

    # UseDNS - Speed up connection
    sed -i 's/^#*UseDNS.*/UseDNS no/' "$SSHD_CONFIG"
    if ! grep -q "^UseDNS" "$SSHD_CONFIG"; then
        echo "UseDNS no" | tee -a "$SSHD_CONFIG" > /dev/null
    fi

    # GSSAPIAuthentication - Avoid GSSAPI timeout
    sed -i 's/^#*GSSAPIAuthentication.*/GSSAPIAuthentication no/' "$SSHD_CONFIG"
    if ! grep -q "^GSSAPIAuthentication" "$SSHD_CONFIG"; then
        echo "GSSAPIAuthentication no" | tee -a "$SSHD_CONFIG" > /dev/null
    fi

    # ClientAliveInterval - Keep connection alive
    sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 60/' "$SSHD_CONFIG"
    if ! grep -q "^ClientAliveInterval" "$SSHD_CONFIG"; then
        echo "ClientAliveInterval 60" | tee -a "$SSHD_CONFIG" > /dev/null
    fi

    # ClientAliveCountMax
    sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 3/' "$SSHD_CONFIG"
    if ! grep -q "^ClientAliveCountMax" "$SSHD_CONFIG"; then
        echo "ClientAliveCountMax 3" | tee -a "$SSHD_CONFIG" > /dev/null
    fi

    print_success "$(tr OPTIMIZE_DONE)"
}

# Verify SSH configuration syntax
verify_config() {
    print_info "$(tr VERIFYING_CONFIG)"

    if sshd -t 2>/dev/null; then
        print_success "$(tr CONFIG_VALID)"
    else
        print_error "$(tr CONFIG_ERROR)"
        print_info "$(tr RESTORING_BACKUP)"
        if [[ -f "${SSHD_CONFIG}.bak.original" ]]; then
            cp "${SSHD_CONFIG}.bak.original" "$SSHD_CONFIG"
            print_success "$(tr CONFIG_RESTORED)"
        fi
        exit 1
    fi
}

# Configure root password
configure_root_password() {
    print_info "$(tr CHECKING_ROOT_PASSWORD)"

    if passwd -S root | grep -q "NP"; then
        # NP = no password
        if command -v openssl &> /dev/null; then
            local random_pass=$(openssl rand -base64 16)
        else
            local random_pass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
        fi
        print_warning "$(tr ROOT_NO_PASSWORD)"
        echo "root:$random_pass" | chpasswd

        # Save password to file
        echo "$random_pass" | tee "$PASSWORD_FILE" > /dev/null
        chmod 600 "$PASSWORD_FILE"

        print_success "$(printf "$(tr RANDOM_PASS_SAVED)" "$PASSWORD_FILE")"
        printf "${RED}$(printf "$(tr PASSWORD)" "$random_pass")${NC}\n" >&2

        # Track password file
        TEMP_FILES+=("$PASSWORD_FILE")
    else
        print_success "$(tr ROOT_PASSWORD_EXISTS)"
    fi
}

# Restart SSH service
restart_ssh_service() {
    print_info "$(tr RESTARTING_SSH)"

    # Detect systemd or service
    if ps -p 1 -o comm= | grep -q systemd; then
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        print_success "$(printf "$(tr SSH_RESTARTED)" "systemd")"
    else
        service ssh restart 2>/dev/null || service sshd restart 2>/dev/null
        print_success "$(printf "$(tr SSH_RESTARTED)" "sysvinit")"
    fi
}

# Verify installation
verify_installation() {
    print_info "$(tr VERIFYING_INSTALL)"

    # Check service status
    if ps -p 1 -o comm= | grep -q systemd; then
        systemctl status ssh --no-pager 2>/dev/null | grep "Active:" || \
        systemctl status sshd --no-pager 2>/dev/null | grep "Active:"
    else
        service ssh status 2>/dev/null | grep "Active:" || \
        service sshd status 2>/dev/null | grep "Active:"
    fi

    print_success "$(tr INSTALL_VERIFIED)"
}

# Display connection information
show_connection_info() {
    local wsl_ip=$(hostname -I | awk '{print $1}')

    echo >&2
    echo "================================================" >&2
    print_success "$(tr INSTALL_SUCCESS)"
    echo "================================================" >&2
    echo >&2
    print_info "$(tr CONNECTION_INFO):"
    echo -e "  ${GREEN}$(tr FROM_WINDOWS)${NC} ${YELLOW}ssh root@${wsl_ip}${NC}" >&2
    echo -e "  ${GREEN}$(tr LOCAL)${NC}        ${YELLOW}ssh root@localhost${NC}" >&2
    echo >&2

    if [[ -f "$PASSWORD_FILE" ]]; then
        print_info "$(tr PASSWORD_SAVED) ${RED}$PASSWORD_FILE${NC}"
        echo -e "  ${YELLOW}$(tr VIEW_PASSWORD) sudo cat $PASSWORD_FILE${NC}" >&2
    else
        print_info "$(tr USE_EXISTING_PASS)"
    fi

    echo >&2
    print_info "$(tr TEST_CONNECTION):"
    echo -e "  ${GREEN}ssh root@${wsl_ip}${NC}" >&2
    echo >&2
}

# Check SSH status
check_status() {
    echo
    echo "================================================"
    echo "$(tr SSH_STATUS)"
    echo "================================================"
    echo

    if is_ssh_installed; then
        print_success "$(tr SSH_FOUND)" "$(which sshd)"
        echo

        # Check if service is running
        if systemctl is-active ssh 2>/dev/null | grep -q "active" || systemctl is-active sshd 2>/dev/null | grep -q "active"; then
            print_success "$(tr SSH_RUNNING)"
            echo
            print_info "$(tr LISTENING_PORT)"
            netstat -tlnp 2>/dev/null | grep sshd || ss -tlnp | grep sshd
            echo
            print_info "$(tr CURRENT_CONFIG)"
            grep -E "^(PermitRootLogin|PasswordAuthentication|UseDNS|GSSAPIAuthentication|ClientAliveInterval)" "$SSHD_CONFIG" 2>/dev/null || true
        else
            print_warning "$(tr SSH_NOT_RUNNING)"
        fi
    else
        print_warning "$(tr SSH_NOT_INSTALLED)"
    fi
    echo
}

# Uninstall OpenSSH Server
uninstall_ssh() {
    print_info "$(tr UNINSTALL_START)"
    print_info "$(tr FINDING_SSH)"

    if ! is_ssh_installed; then
        print_warning "$(tr SSH_NOT_FOUND)"
        return
    fi

    local sshd_path=$(which sshd)
    print_success "$(printf "$(tr SSH_FOUND)" "$sshd_path")"

    # Backup current configuration before uninstall
    local backup_file="${SSHD_CONFIG}.pre-uninstall.$(date +%s)"
    if [[ -f "$SSHD_CONFIG" ]]; then
        cp "$SSHD_CONFIG" "$backup_file"
    fi

    echo
    read -p "$(printf "$(tr UNINSTALL_CONFIRM)")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "$(tr UNINSTALL_CANCEL)"
        return
    fi

    # Stop SSH service
    print_info "$(tr STOPPING_SSH)"
    if ps -p 1 -o comm= | grep -q systemd; then
        systemctl stop ssh 2>/dev/null || systemctl stop sshd 2>/dev/null
    else
        service ssh stop 2>/dev/null || service sshd stop 2>/dev/null
    fi
    print_success "$(tr STOPPING_SSH)"

    # Remove package
    print_info "$(tr REMOVING_PACKAGE)"
    apt remove -y openssh-server > /dev/null 2>&1
    apt autoremove -y > /dev/null 2>&1
    print_success "$(tr PACKAGE_REMOVED)"

    echo
    print_success "$(tr UNINSTALL_SUCCESS)"
    echo "================================================"
    print_success "$(tr UNINSTALL_DONE)"
    echo "================================================"
    echo
    print_info "$(printf "$(tr KEEP_BACKUP)" "$backup_file")"
    echo
}

# Cleanup function - called automatically on exit
cleanup() {
    local exit_code=$?

    # Note: We intentionally don't delete the password file or backups
    # Only clean up temporary files if installation failed
    if [[ $exit_code -ne 0 ]] && [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        print_warning "$(tr CLEANUP_FAILED)"
        for file in "${TEMP_FILES[@]}"; do
            if [[ -f "$file" ]] && [[ "$file" != "$PASSWORD_FILE" ]]; then
                rm -f "$file" 2>/dev/null || true
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
    check_debian
    check_ssh_port

    install_packages
    backup_config
    configure_ssh
    apply_optimizations
    verify_config
    configure_root_password
    restart_ssh_service
    verify_installation
    show_connection_info
}

# Main loop
main() {
    clear
    select_language

    while true; do
        select_operation

        case $OPERATION in
            check)
                check_status
                ;;
            install)
                main_install
                ;;
            uninstall)
                uninstall_ssh
                ;;
            exit)
                exit 0
                ;;
        esac

        echo
        read -p "$(tr PRESS_ENTER)" -r
        clear
    done
}

# Start the script
main
