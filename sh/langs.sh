#!/usr/bin/env bash
#
# Programming Languages Installation
# Installs: Rust, Go, Node.js (via nvm), Zig, GCC, G++, LLVM, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Programming Languages..."

install_rust() {
  if is_installed rustc; then return 0; fi
  if ! confirm_install "Rust"; then return 0; fi
  
  log_info "Installing Rust via rustup (platform-agnostic)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  
  # Source cargo env
  if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
  fi
  
  log_success "Rust installed. Run 'source \$HOME/.cargo/env' to use it in this session."
}

install_go() {
  if is_installed go; then return 0; fi
  if ! confirm_install "Go"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install go ;;
    ubuntu|arch) pkg_install golang ;;
    *)
      # Platform-agnostic: download from official site
      local version="1.23.3"
      local os_type="linux"
      local arch="amd64"
      
      if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="darwin"
      fi
      
      if [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]; then
        arch="arm64"
      fi
      
      local url="https://go.dev/dl/go${version}.${os_type}-${arch}.tar.gz"
      log_info "Downloading Go from $url..."
      
      curl -L "$url" -o /tmp/go.tar.gz
      sudo rm -rf /usr/local/go
      sudo tar -C /usr/local -xzf /tmp/go.tar.gz
      rm /tmp/go.tar.gz
      
      log_success "Go installed. Add 'export PATH=\$PATH:/usr/local/go/bin' to your shell profile."
      ;;
  esac
}

install_node() {
  if is_installed node; then
    log_skip "Node.js is already installed"
    return 0
  fi
  
  # Check if nvm is installed first
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
    if ! confirm_install "Node.js (via nvm)"; then return 0; fi
    nvm install --lts
    nvm use --lts
    log_success "Node.js installed via nvm"
  else
    log_warning "nvm not found. Installing nvm first..."
    install_nvm
    source "$HOME/.nvm/nvm.sh"
    nvm install --lts
    nvm use --lts
  fi
}

install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    log_skip "nvm is already installed"
    return 0
  fi
  
  if ! confirm_install "nvm (Node Version Manager)"; then return 0; fi
  
  log_info "Installing nvm (platform-agnostic)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  
  log_success "nvm installed. Run 'source \$HOME/.nvm/nvm.sh' to use it."
}

install_zig() {
  if is_installed zig; then return 0; fi
  if ! confirm_install "Zig"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install zig ;;
    ubuntu|arch) pkg_install zig ;;
    *)
      log_warning "Zig installation may require manual download from https://ziglang.org/download/"
      return 1
      ;;
  esac
}

install_gcc() {
  if is_installed gcc; then return 0; fi
  if ! confirm_install "GCC"; then return 0; fi
  
  case "$OS" in
    macos) 
      log_info "On macOS, gcc is provided by Xcode Command Line Tools"
      xcode-select --install || log_skip "Xcode tools already installed"
      ;;
    ubuntu) pkg_install build-essential ;;
    arch) pkg_install gcc ;;
    *) return 1 ;;
  esac
}

install_gpp() {
  if is_installed g++; then return 0; fi
  if ! confirm_install "G++"; then return 0; fi
  
  case "$OS" in
    macos) 
      log_info "On macOS, g++ is provided by Xcode Command Line Tools"
      xcode-select --install || log_skip "Xcode tools already installed"
      ;;
    ubuntu) pkg_install build-essential ;;
    arch) pkg_install gcc ;;
    *) return 1 ;;
  esac
}

install_llvm() {
  if is_installed llvm-config; then return 0; fi
  if ! confirm_install "LLVM"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install llvm ;;
    ubuntu) pkg_install llvm ;;
    arch) pkg_install llvm ;;
    *) return 1 ;;
  esac
}

install_python() {
  if is_installed python3; then return 0; fi
  if ! confirm_install "Python3"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install python3 ;;
    ubuntu) pkg_install python3 python3-pip ;;
    arch) pkg_install python python-pip ;;
    *) return 1 ;;
  esac
}

# Main installation
main() {
  local langs=(
    "rust"
    "go"
    "nvm"
    "node"
    "zig"
    "python"
    "gcc"
    "gpp"
    "llvm"
  )
  
  for lang in "${langs[@]}"; do
    "install_$lang" || log_warning "Failed to install $lang"
  done
  
  log_success "Programming languages installation complete!"
}

main
