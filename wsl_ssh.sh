#!/bin/bash

##############################################################################
# OpenSSH Server Installation & Configuration Script
# Description: Automatically install and configure OpenSSH Server with root login
# Usage: sudo bash wsl_ssh.sh
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

# Print functions (output to stderr to avoid capture in command substitution)
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if SSH port is already in use
check_ssh_port() {
    print_info "Checking port 22 availability..."
    
    if sudo netstat -tlnp 2>/dev/null | grep -q ":22 " || sudo ss -tlnp 2>/dev/null | grep -q ":22 "; then
        print_warning "Port 22 is already in use, SSH service may be running"
        print_info "This script will reconfigure and restart the SSH service"
        return 0
    fi
    
    print_success "Port 22 is available"
}

# Install required packages
install_packages() {
    print_info "Updating package sources..."
    sudo apt update -y > /dev/null 2>&1
    print_success "Package sources updated"
    
    print_info "Installing OpenSSH Server..."
    sudo apt install -y openssh-server net-tools > /dev/null 2>&1
    print_success "OpenSSH Server installed"
}

# Backup SSH configuration
backup_config() {
    print_info "Backing up SSH configuration..."
    
    if [ ! -f "${SSHD_CONFIG}.bak.original" ]; then
        sudo cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.original"
        print_success "Original configuration backed up"
    else
        print_info "Original backup already exists, creating timestamped backup"
        local backup_file="${SSHD_CONFIG}.bak.$(date +%s)"
        sudo cp "$SSHD_CONFIG" "$backup_file"
        TEMP_FILES+=("$backup_file")
    fi
    
    # Clean up old backups (keep only the last 5 timestamped backups)
    ls -t "${SSHD_CONFIG}.bak."[0-9]* 2>/dev/null | tail -n +6 | xargs sudo rm -f 2>/dev/null || true
}

# Configure SSH settings
configure_ssh() {
    print_info "Configuring SSH settings..."
    
    # Basic authentication settings
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
    sudo sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
    sudo sed -i 's/^#*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"
    
    print_success "Basic authentication configured"
}

# Apply performance optimizations
apply_optimizations() {
    print_info "Applying performance optimizations..."
    
    # UseDNS - Speed up connection
    sudo sed -i 's/^#*UseDNS.*/UseDNS no/' "$SSHD_CONFIG"
    if ! grep -q "^UseDNS" "$SSHD_CONFIG"; then
        echo "UseDNS no" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
    
    # GSSAPIAuthentication - Avoid GSSAPI timeout
    sudo sed -i 's/^#*GSSAPIAuthentication.*/GSSAPIAuthentication no/' "$SSHD_CONFIG"
    if ! grep -q "^GSSAPIAuthentication" "$SSHD_CONFIG"; then
        echo "GSSAPIAuthentication no" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
    
    # ClientAliveInterval - Keep connection alive
    sudo sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 60/' "$SSHD_CONFIG"
    if ! grep -q "^ClientAliveInterval" "$SSHD_CONFIG"; then
        echo "ClientAliveInterval 60" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
    
    # ClientAliveCountMax
    sudo sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 3/' "$SSHD_CONFIG"
    if ! grep -q "^ClientAliveCountMax" "$SSHD_CONFIG"; then
        echo "ClientAliveCountMax 3" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
    
    print_success "Performance optimizations applied"
}

# Verify SSH configuration syntax
verify_config() {
    print_info "Verifying SSH configuration syntax..."
    
    if sudo sshd -t 2>/dev/null; then
        print_success "Configuration syntax is valid"
    else
        print_error "Configuration syntax error detected!"
        print_info "Restoring from backup..."
        if [ -f "${SSHD_CONFIG}.bak.original" ]; then
            sudo cp "${SSHD_CONFIG}.bak.original" "$SSHD_CONFIG"
            print_success "Configuration restored from backup"
        fi
        exit 1
    fi
}

# Configure root password
configure_root_password() {
    print_info "Checking root password status..."
    
    if sudo passwd -S root | grep -q "NP"; then
        # NP = no password
        local random_pass=$(openssl rand -base64 16)
        print_warning "Root has no password, setting random password"
        echo "root:$random_pass" | sudo chpasswd
        
        # Save password to file
        echo "$random_pass" | sudo tee "$PASSWORD_FILE" > /dev/null
        sudo chmod 600 "$PASSWORD_FILE"
        
        print_success "Random password generated and saved to: $PASSWORD_FILE"
        echo -e "  ${RED}Password: $random_pass${NC}" >&2
        
        # Track password file
        TEMP_FILES+=("$PASSWORD_FILE")
    else
        print_success "Root password already set, skipping"
    fi
}

# Restart SSH service
restart_ssh_service() {
    print_info "Restarting SSH service..."
    
    # Detect systemd or service
    if ps -p 1 -o comm= | grep -q systemd; then
        sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
        print_success "SSH service restarted (systemd)"
    else
        sudo service ssh restart 2>/dev/null || sudo service sshd restart 2>/dev/null
        print_success "SSH service restarted (sysvinit)"
    fi
}

# Verify installation
verify_installation() {
    print_info "Verifying installation..."
    
    # Check service status
    if ps -p 1 -o comm= | grep -q systemd; then
        sudo systemctl status ssh --no-pager 2>/dev/null | grep "Active:" || \
        sudo systemctl status sshd --no-pager 2>/dev/null | grep "Active:"
    else
        sudo service ssh status 2>/dev/null | grep "Active:" || \
        sudo service sshd status 2>/dev/null | grep "Active:"
    fi
    
    # Check listening port
    print_info "Listening on port:"
    sudo netstat -tlnp 2>/dev/null | grep sshd || sudo ss -tlnp | grep sshd
    
    # Verify configuration
    print_info "Active configuration:"
    sudo grep -E "^(PermitRootLogin|PasswordAuthentication|UseDNS|GSSAPIAuthentication|ClientAliveInterval)" "$SSHD_CONFIG"
    
    print_success "Installation verified successfully"
}

# Display connection information
show_connection_info() {
    local wsl_ip=$(hostname -I | awk '{print $1}')
    
    echo >&2
    echo "================================================" >&2
    print_success "SSH Server configured successfully!"
    echo "================================================" >&2
    echo >&2
    print_info "Connection Information:"
    echo -e "  ${GREEN}From Windows:${NC} ${YELLOW}ssh root@${wsl_ip}${NC}" >&2
    echo -e "  ${GREEN}Local:${NC}        ${YELLOW}ssh root@localhost${NC}" >&2
    echo >&2
    
    if [ -f "$PASSWORD_FILE" ]; then
        print_info "Password saved to: ${RED}$PASSWORD_FILE${NC}"
        echo -e "  ${YELLOW}View password: sudo cat $PASSWORD_FILE${NC}" >&2
    else
        print_info "Use existing root password to login"
    fi
    
    echo >&2
    print_info "To test connection:"
    echo -e "  ${GREEN}ssh root@${wsl_ip}${NC}" >&2
}

# Cleanup function - called automatically on exit
cleanup() {
    local exit_code=$?
    
    # Note: We intentionally don't delete the password file or backups
    # Only clean up temporary files if installation failed
    if [[ $exit_code -ne 0 ]] && [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        print_warning "Installation failed, cleaning up temporary files..."
        for file in "${TEMP_FILES[@]}"; do
            if [[ -f "$file" ]] && [[ "$file" != "$PASSWORD_FILE" ]]; then
                sudo rm -f "$file" 2>/dev/null || true
            fi
        done
    fi
    
    return $exit_code
}

# Set trap to ensure cleanup on exit (success or failure)
trap cleanup EXIT INT TERM

# Main installation process
main() {
    echo "================================================"
    echo "   OpenSSH Server Configuration Script"
    echo "================================================"
    echo
    
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

# Run main function
main
