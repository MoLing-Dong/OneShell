#!/bin/bash

##############################################################################
# Go Language Uninstallation Script
# Description: Remove Go installation and clean environment variables
# Usage: sudo bash golang_uninstall.sh
##############################################################################

set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if Go is installed
check_go_installed() {
    if ! command -v go &> /dev/null; then
        print_warning "Go is not installed or not in PATH"
        return 1
    fi
    return 0
}

# Remove Go installation
remove_go() {
    local install_dirs=("/usr/local/go" "$HOME/.local/go")
    local removed=0
    
    for dir in "${install_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_info "Removing Go installation from: $dir"
            if [[ "$dir" == "/usr/local/go" ]] && [[ $EUID -ne 0 ]]; then
                print_error "Root privileges required to remove $dir"
                print_info "Please run: sudo bash $0"
                exit 1
            fi
            rm -rf "$dir"
            print_success "Removed: $dir"
            removed=1
        fi
    done
    
    if [[ $removed -eq 0 ]]; then
        print_warning "No Go installation directory found"
    fi
}

# Remove environment variables
remove_env_vars() {
    print_info "Cleaning environment variables..."
    
    # Remove from /etc/profile.d/golang.sh
    if [[ -f "/etc/profile.d/golang.sh" ]]; then
        if [[ $EUID -ne 0 ]]; then
            print_warning "Root privileges required to remove /etc/profile.d/golang.sh"
            print_info "Please run: sudo rm /etc/profile.d/golang.sh"
        else
            rm -f "/etc/profile.d/golang.sh"
            print_success "Removed: /etc/profile.d/golang.sh"
        fi
    fi
    
    # Remove from user's .bashrc
    if [[ -f "$HOME/.bashrc" ]]; then
        if grep -q "# Go Lang Environment" "$HOME/.bashrc"; then
            print_info "Removing Go environment variables from ~/.bashrc"
            # Create a temporary file without Go environment section
            sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$HOME/.bashrc"
            print_success "Cleaned ~/.bashrc"
        fi
    fi
    
    # Remove from user's .bash_profile
    if [[ -f "$HOME/.bash_profile" ]]; then
        if grep -q "# Go Lang Environment" "$HOME/.bash_profile"; then
            print_info "Removing Go environment variables from ~/.bash_profile"
            sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$HOME/.bash_profile"
            print_success "Cleaned ~/.bash_profile"
        fi
    fi
    
    # Remove from user's .profile
    if [[ -f "$HOME/.profile" ]]; then
        if grep -q "# Go Lang Environment" "$HOME/.profile"; then
            print_info "Removing Go environment variables from ~/.profile"
            sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$HOME/.profile"
            print_success "Cleaned ~/.profile"
        fi
    fi
}

# Remove GOPATH directory (optional)
remove_gopath() {
    local gopath_dir="$HOME/go"
    
    if [[ -d "$gopath_dir" ]]; then
        print_warning "Found GOPATH directory: $gopath_dir"
        read -p "Do you want to remove it? This will delete all your Go projects! (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$gopath_dir"
            print_success "Removed: $gopath_dir"
        else
            print_info "Keeping GOPATH directory"
        fi
    fi
}

# Main uninstallation process
main() {
    echo "================================================"
    echo "     Go Language Uninstallation Script"
    echo "================================================"
    echo
    
    if check_go_installed; then
        local go_version=$(go version)
        print_info "Current Go installation: $go_version"
        print_info "GOROOT: $(go env GOROOT 2>/dev/null || echo 'Not set')"
        print_info "GOPATH: $(go env GOPATH 2>/dev/null || echo 'Not set')"
        echo
    fi
    
    print_warning "This will remove Go from your system"
    read -p "Are you sure you want to continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
    
    remove_go
    remove_env_vars
    remove_gopath
    
    echo
    echo "================================================"
    print_success "Uninstallation completed!"
    echo "================================================"
    echo
    print_info "Please restart your terminal or run:"
    echo "  source ~/.bashrc"
}

# Run main function
main

