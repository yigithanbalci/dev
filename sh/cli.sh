#!/usr/bin/env bash
#
# Modern CLI Tools Installation
# Installs: ripgrep, fzf, fd, bat, eza, jq, tldr, zoxide, atuin, tree-sitter, stow, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Modern CLI Tools..."

# Define tools to install
declare -A TOOLS=(
  # Search and find tools
  ["ripgrep"]="rg"
  ["fzf"]="fzf"
  ["fd"]="fd"
  
  # File viewers and processors
  ["bat"]="bat"
  ["eza"]="eza"
  ["jq"]="jq"
  ["tree-sitter"]="tree-sitter"
  
  # Navigation and history
  ["zoxide"]="zoxide"
  ["atuin"]="atuin"
  
  # Documentation and utilities
  ["tldr"]="tldr"
  ["stow"]="stow"
  
  # Modern replacements
  ["awk"]="awk"
  ["curl"]="curl"
)

# Special installations that need custom handling
install_ripgrep() {
  case "$OS" in
    macos) pkg_install ripgrep ;;
    ubuntu) pkg_install ripgrep ;;
    arch) pkg_install ripgrep ;;
    *) return 1 ;;
  esac
}

install_fzf() {
  if is_installed fzf; then return 0; fi
  
  case "$OS" in
    macos) pkg_install fzf ;;
    ubuntu|arch) pkg_install fzf ;;
    *) 
      # Platform-agnostic git install
      if [[ ! -d ~/.fzf ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
      fi
      ;;
  esac
}

install_fd() {
  case "$OS" in
    macos) pkg_install fd ;;
    ubuntu) pkg_install fd-find ;;
    arch) pkg_install fd ;;
    *) return 1 ;;
  esac
}

install_bat() {
  if is_installed bat; then return 0; fi
  
  case "$OS" in
    macos) 
      pkg_install bat
      pkg_install bat-extras || true
      ;;
    ubuntu) pkg_install bat ;;
    arch) 
      pkg_install bat
      pkg_install bat-extras || true
      ;;
    *) return 1 ;;
  esac
}

install_eza() {
  if is_installed eza; then return 0; fi
  
  case "$OS" in
    macos) pkg_install eza ;;
    arch) pkg_install eza ;;
    ubuntu)
      # Use official installation script
      curl_install "https://raw.githubusercontent.com/eza-community/eza/main/deb.sh" "eza" || \
      pkg_install eza
      ;;
    *) return 1 ;;
  esac
}

install_jq() {
  pkg_install jq
}

install_zoxide() {
  if is_installed zoxide; then return 0; fi
  
  # Try official installer first (platform-agnostic)
  if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
    return 0
  fi
  
  # Fallback to package manager
  pkg_install zoxide
}

install_atuin() {
  if is_installed atuin; then return 0; fi
  
  # Try official installer first (platform-agnostic)
  if curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh; then
    return 0
  fi
  
  # Fallback to package manager
  pkg_install atuin
}

install_tldr() {
  pkg_install tldr
}

install_stow() {
  pkg_install stow
}

install_tree_sitter() {
  case "$OS" in
    macos) pkg_install tree-sitter ;;
    ubuntu|arch) pkg_install tree-sitter ;;
    *) return 1 ;;
  esac
}

install_awk() {
  case "$OS" in
    macos) pkg_install gawk ;;
    ubuntu|arch) pkg_install gawk ;;
    *) return 1 ;;
  esac
}

install_curl() {
  if is_installed curl; then return 0; fi
  pkg_install curl
}

# Additional tools
install_television() {
  if is_installed tv; then return 0; fi
  
  case "$OS" in
    macos) 
      brew tap alexpasmantier/television
      brew install television
      ;;
    *)
      # Use cargo if available
      if command_exists cargo; then
        cargo install television
      else
        log_warning "television requires cargo. Install Rust first."
        return 1
      fi
      ;;
  esac
}

install_lazygit() {
  if is_installed lazygit; then return 0; fi
  
  case "$OS" in
    macos) pkg_install lazygit ;;
    ubuntu)
      # Use official PPA
      sudo add-apt-repository -y ppa:lazygit-team/release
      sudo apt-get update
      sudo apt-get install -y lazygit
      ;;
    arch) pkg_install lazygit ;;
    *) return 1 ;;
  esac
}

install_sesh() {
  if is_installed sesh; then return 0; fi
  
  case "$OS" in
    macos) 
      brew tap joshmedeski/sesh
      brew install sesh
      ;;
    *)
      # Install from GitHub releases
      local url="https://github.com/joshmedeski/sesh/releases/latest/download/sesh_Linux_x86_64.tar.gz"
      local tmpdir=$(mktemp -d)
      curl -L "$url" | tar -xz -C "$tmpdir"
      sudo mv "$tmpdir/sesh" /usr/local/bin/
      rm -rf "$tmpdir"
      ;;
  esac
}

install_worktrunk() {
  if is_installed worktrunk; then return 0; fi
  
  # worktrunk uses Go install
  if command_exists go; then
    go install github.com/user/worktrunk@latest
  else
    log_warning "worktrunk requires Go. Skipping."
    return 1
  fi
}

# Main installation loop
main() {
  local tools_to_install=(
    "ripgrep"
    "fzf"
    "fd"
    "bat"
    "eza"
    "jq"
    "zoxide"
    "atuin"
    "tldr"
    "stow"
    "tree-sitter"
    "lazygit"
    "television"
    "sesh"
  )
  
  for tool in "${tools_to_install[@]}"; do
    if confirm_install "$tool"; then
      if "install_$tool"; then
        log_success "$tool installed"
      else
        log_error "Failed to install $tool"
      fi
    fi
  done
  
  log_success "CLI tools installation complete!"
}

main
