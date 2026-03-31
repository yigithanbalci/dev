#!/usr/bin/env bash
#
# Common utilities for installation scripts
# Source this file in your installation scripts: source "$(dirname "$0")/common.sh"

set -euo pipefail

# Color output
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
fi

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[✓]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*"; }
log_skip() { echo -e "${CYAN}[SKIP]${NC} $*"; }

# Detect OS and distribution
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "$ID" in
        ubuntu|debian) echo "ubuntu" ;;
        arch|manjaro) echo "arch" ;;
        fedora|rhel|centos) echo "fedora" ;;
        *) echo "linux-unknown" ;;
      esac
    else
      echo "linux-unknown"
    fi
  else
    echo "unknown"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if program is already installed
is_installed() {
  local program="$1"
  if command_exists "$program"; then
    log_skip "$program is already installed"
    return 0
  fi
  return 1
}

# Install using package manager based on OS
pkg_install() {
  local package="$1"
  local os=$(detect_os)
  
  case "$os" in
    macos)
      if command_exists brew; then
        log_info "Installing $package via Homebrew..."
        brew install "$package"
      else
        log_error "Homebrew not found. Please install Homebrew first."
        return 1
      fi
      ;;
    ubuntu)
      log_info "Installing $package via apt..."
      sudo apt-get update -qq
      sudo apt-get install -y "$package"
      ;;
    arch)
      log_info "Installing $package via pacman..."
      sudo pacman -Syu --noconfirm "$package"
      ;;
    fedora)
      log_info "Installing $package via dnf..."
      sudo dnf install -y "$package"
      ;;
    *)
      log_error "Unsupported OS: $os"
      return 1
      ;;
  esac
}

# Install from curl script (platform-agnostic installers)
curl_install() {
  local url="$1"
  local program_name="$2"
  
  log_info "Installing $program_name from $url..."
  if curl -fsSL "$url" | bash; then
    log_success "$program_name installed successfully"
    return 0
  else
    log_error "Failed to install $program_name"
    return 1
  fi
}

# Install from curl script with custom arguments
curl_install_with_args() {
  local url="$1"
  local program_name="$2"
  shift 2
  local args="$*"
  
  log_info "Installing $program_name from $url with args: $args..."
  if curl -fsSL "$url" | bash -s -- $args; then
    log_success "$program_name installed successfully"
    return 0
  else
    log_error "Failed to install $program_name"
    return 1
  fi
}

# Confirm before installation (respects INSTALL_NONINTERACTIVE)
confirm_install() {
  local program="$1"
  
  if [[ "${INSTALL_NONINTERACTIVE:-0}" == "1" ]]; then
    return 0
  fi
  
  read -p "Install $program? (Y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    log_skip "Skipped $program"
    return 1
  fi
  return 0
}

# Try multiple installation methods
try_install() {
  local program="$1"
  shift
  
  # Check if already installed
  if is_installed "$program"; then
    return 0
  fi
  
  # Ask for confirmation
  if ! confirm_install "$program"; then
    return 0
  fi
  
  # Try each installation method until one succeeds
  for method in "$@"; do
    log_info "Trying: $method"
    if eval "$method"; then
      log_success "$program installed successfully"
      return 0
    else
      log_warning "Method failed: $method"
    fi
  done
  
  log_error "All installation methods failed for $program"
  return 1
}

# Export OS detection for scripts
export OS=$(detect_os)
log_info "Detected OS: $OS"
