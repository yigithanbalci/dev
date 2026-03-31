#!/usr/bin/env bash
#
# Build Tools Installation
# Installs: CMake, Make, Ninja, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Build Tools..."

install_cmake() {
  if is_installed cmake; then return 0; fi
  if ! confirm_install "CMake"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install cmake ;;
    ubuntu) pkg_install cmake ;;
    arch) pkg_install cmake ;;
    *)
      log_error "Unsupported OS for CMake"
      return 1
      ;;
  esac
  
  log_success "CMake installed"
}

install_make() {
  if is_installed make; then return 0; fi
  if ! confirm_install "Make"; then return 0; fi
  
  case "$OS" in
    macos)
      # make is included with Xcode Command Line Tools
      xcode-select --install 2>/dev/null || log_skip "Xcode tools already installed"
      ;;
    ubuntu)
      pkg_install build-essential
      ;;
    arch)
      pkg_install base-devel
      ;;
    *)
      log_error "Unsupported OS for Make"
      return 1
      ;;
  esac
  
  log_success "Make installed"
}

install_ninja() {
  if is_installed ninja; then return 0; fi
  if ! confirm_install "Ninja"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install ninja ;;
    ubuntu) pkg_install ninja-build ;;
    arch) pkg_install ninja ;;
    *)
      log_error "Unsupported OS for Ninja"
      return 1
      ;;
  esac
  
  log_success "Ninja installed"
}

install_meson() {
  if is_installed meson; then return 0; fi
  if ! confirm_install "Meson"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install meson ;;
    ubuntu) pkg_install meson ;;
    arch) pkg_install meson ;;
    *)
      log_error "Unsupported OS for Meson"
      return 1
      ;;
  esac
  
  log_success "Meson installed"
}

# Main installation
main() {
  local tools=(
    "cmake"
    "make"
    "ninja"
    "meson"
  )
  
  for tool in "${tools[@]}"; do
    "install_$tool" || log_warning "Failed to install $tool"
  done
  
  log_success "Build tools installation complete!"
}

main
