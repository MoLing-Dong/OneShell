#!/bin/bash

##############################################################################
# Go Language Installation Script
# Description: Automatically download and install the latest version of Go
# Usage: sudo bash golang_install.sh
##############################################################################

set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/usr/local"
BASHRC_FILE="$HOME/.bashrc"

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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "This script is not running as root. Installation to /usr/local requires root privileges."
        print_info "You can run: sudo bash $0"
        read -p "Continue with current user privileges? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        INSTALL_DIR="$HOME/.local"
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
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Get latest Go version
get_latest_version() {
    print_info "Fetching latest Go version..."
    local version=$(curl -s https://go.dev/dl/?mode=json | grep -oP '"version": ?"go[0-9.]+[^"]*' | head -1 | cut -d'"' -f4)
    if [[ -z "$version" ]]; then
        print_error "Failed to fetch the latest Go version"
        exit 1
    fi
    echo "$version"
}

# Check if Go is already installed
check_existing_go() {
    if command -v go &> /dev/null; then
        local current_version=$(go version | awk '{print $3}')
        echo "$current_version"
    else
        echo ""
    fi
}

# Download Go
download_go() {
    local version=$1
    local arch=$2
    local os="linux"
    local filename="${version}.${os}-${arch}.tar.gz"
    local download_url="https://go.dev/dl/${filename}"
    
    print_info "Downloading Go ${version} for ${os}-${arch}..."
    echo >&2
    
    # Use curl with progress bar (--progress-bar shows a cleaner single progress bar)
    if ! curl --progress-bar -L -o "/tmp/${filename}" "${download_url}"; then
        print_error "Failed to download Go"
        exit 1
    fi
    
    echo >&2
    print_success "Download completed"
    
    echo "/tmp/${filename}"
}

# Install Go
install_go() {
    local archive=$1
    
    print_info "Installing Go to ${INSTALL_DIR}..."
    
    # Remove old installation
    if [[ -d "${INSTALL_DIR}/go" ]]; then
        print_info "Removing old Go installation..."
        rm -rf "${INSTALL_DIR}/go"
    fi
    
    # Extract archive with progress indicator
    print_info "Extracting archive (this may take a moment)..."
    
    # Show a simple spinner while extracting
    {
        tar -C "${INSTALL_DIR}" -xzf "${archive}" &
        local pid=$!
        local spin='-\|/'
        local i=0
        while kill -0 $pid 2>/dev/null; do
            i=$(( (i+1) %4 ))
            printf "\r${BLUE}[INFO]${NC} Extracting... ${spin:$i:1}"
            sleep .1
        done
        wait $pid
        printf "\r"
    }
    
    if [[ ! -d "${INSTALL_DIR}/go" ]]; then
        print_error "Installation failed: Go directory not found"
        exit 1
    fi
    
    print_success "Go extracted successfully"
}

# Configure environment variables
configure_environment() {
    print_info "Configuring environment variables..."
    
    # Create backup before modifying
    local backup_file="${BASHRC_FILE}.bak.$(date +%s)"
    if [[ -f "$BASHRC_FILE" ]]; then
        cp "$BASHRC_FILE" "$backup_file"
        print_info "Created backup: $backup_file"
    fi
    
    # Always write to ~/.bashrc for automatic loading in all terminal sessions
    if ! grep -q "# Go Lang Environment" "$BASHRC_FILE" 2>/dev/null; then
        cat >> "$BASHRC_FILE" <<'EOF'

# Go Lang Environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
        # Update GOROOT based on actual installation directory
        sed -i "s|^export GOROOT=.*|export GOROOT=${INSTALL_DIR}/go|" "$BASHRC_FILE"
        print_success "Environment variables added to $BASHRC_FILE"
    else
        print_warning "Go environment variables already exist in $BASHRC_FILE"
        print_info "Updating existing configuration..."
        # Remove old configuration safely
        sed -i '/# Go Lang Environment/,/export PATH=\$PATH:\$GOROOT\/bin:\$GOPATH\/bin/d' "$BASHRC_FILE"
        # Add new configuration
        cat >> "$BASHRC_FILE" <<'EOF'

# Go Lang Environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
        # Update GOROOT based on actual installation directory
        sed -i "s|^export GOROOT=.*|export GOROOT=${INSTALL_DIR}/go|" "$BASHRC_FILE"
        print_success "Configuration updated"
    fi
    
    # Verify bashrc is still valid
    if ! bash -n "$BASHRC_FILE" 2>/dev/null; then
        print_error "Syntax error detected in $BASHRC_FILE!"
        print_info "Restoring from backup..."
        if [[ -f "$backup_file" ]]; then
            mv "$backup_file" "$BASHRC_FILE"
            print_success "Backup restored successfully"
        fi
        exit 1
    fi
    
    # Clean up old backups (keep only the last 5)
    ls -t "${BASHRC_FILE}.bak."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
}

# Verify installation
verify_installation() {
    print_info "Verifying installation..."
    
    # Load environment for verification
    export GOROOT="${INSTALL_DIR}/go"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
    
    if command -v go &> /dev/null; then
        local installed_version=$(go version)
        print_success "Go installed successfully!"
        print_success "Version: ${installed_version}"
        print_info "GOROOT: $(go env GOROOT)"
        print_info "GOPATH: $(go env GOPATH)"
    else
        print_error "Installation verification failed"
        print_info "Please manually run: source $BASHRC_FILE"
        exit 1
    fi
}

# Cleanup
cleanup() {
    print_info "Cleaning up temporary files..."
    rm -f /tmp/go*.tar.gz
    print_success "Cleanup completed"
}

# Main installation process
main() {
    echo "================================================"
    echo "       Go Language Installation Script"
    echo "================================================"
    echo
    
    check_root
    
    local arch=$(detect_arch)
    print_info "Detected architecture: $arch"
    
    local existing_version=$(check_existing_go)
    if [[ -n "$existing_version" ]]; then
        print_warning "Go is already installed: $existing_version"
        read -p "Do you want to reinstall/update? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    local latest_version=$(get_latest_version)
    print_success "Latest version available: $latest_version"
    
    if [[ "$existing_version" == "$latest_version" ]]; then
        print_info "You already have the latest version installed"
        exit 0
    fi
    
    local archive=$(download_go "$latest_version" "$arch")
    install_go "$archive"
    configure_environment
    verify_installation
    cleanup
    
    echo
    echo "================================================"
    print_success "Installation completed successfully!"
    echo "================================================"
    echo
    print_success "Go is now configured in $BASHRC_FILE"
    echo
    print_info "To use Go in your CURRENT terminal, run:"
    echo -e "  ${GREEN}source ~/.bashrc${NC}"
    echo
    print_info "For NEW terminals, Go will work automatically!"
    echo
    print_info "Verify installation with:"
    echo -e "  ${GREEN}go version${NC}"
}

# Run main function
main