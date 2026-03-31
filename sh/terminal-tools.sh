#!/usr/bin/env bash
#
# Terminal Programs Installation
# Installs: tmux, lazygit, lazydocker, yazi, gh-dash, gtop, carapace

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Terminal Programs..."

install_tmux() {
  if is_installed tmux; then return 0; fi
  if ! confirm_install "tmux"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install tmux ;;
    ubuntu|arch) pkg_install tmux ;;
    *) return 1 ;;
  esac
  
  # Install TPM (Tmux Plugin Manager)
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  
  log_success "tmux installed"
}

install_lazygit() {
  if is_installed lazygit; then return 0; fi
  if ! confirm_install "lazygit"; then return 0; fi
  
  case "$OS" in
    macos) 
      pkg_install lazygit
      ;;
    ubuntu)
      # Use official PPA
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin
      rm -f /tmp/lazygit /tmp/lazygit.tar.gz
      ;;
    arch) 
      pkg_install lazygit
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "lazygit installed"
}

install_lazydocker() {
  if is_installed lazydocker; then return 0; fi
  if ! confirm_install "lazydocker"; then return 0; fi
  
  case "$OS" in
    macos) 
      pkg_install lazydocker
      ;;
    ubuntu|arch)
      # Platform-agnostic installer
      curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "lazydocker installed"
}

install_yazi() {
  if is_installed yazi; then return 0; fi
  if ! confirm_install "yazi"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install yazi
      # Install optional dependencies
      pkg_install ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick font-symbols-only-nerd-font || true
      ;;
    arch)
      pkg_install yazi
      # Install optional dependencies
      pkg_install ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick ttf-nerd-fonts-symbols || true
      ;;
    ubuntu)
      # Build from source or use cargo
      if command_exists cargo; then
        cargo install --locked yazi-fm yazi-cli
      else
        log_warning "Yazi on Ubuntu requires cargo or manual build. Install Rust first."
        return 1
      fi
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "yazi installed"
}

install_gh_dash() {
  if is_installed gh-dash; then return 0; fi
  if ! confirm_install "gh-dash (GitHub CLI Dashboard)"; then return 0; fi
  
  # Ensure gh (GitHub CLI) is installed
  if ! command_exists gh; then
    log_info "Installing GitHub CLI first..."
    install_gh
  fi
  
  # Install as gh extension
  gh extension install dlvhdr/gh-dash
  
  log_success "gh-dash installed"
}

install_gh() {
  if is_installed gh; then return 0; fi
  if ! confirm_install "GitHub CLI"; then return 0; fi
  
  case "$OS" in
    macos) 
      pkg_install gh
      ;;
    ubuntu)
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y gh
      ;;
    arch)
      pkg_install github-cli
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "GitHub CLI installed"
}

install_gtop() {
  if is_installed gtop; then return 0; fi
  if ! confirm_install "gtop"; then return 0; fi
  
  # gtop requires Node.js
  if ! command_exists npm; then
    log_warning "gtop requires Node.js. Install Node.js first."
    return 1
  fi
  
  npm install -g gtop
  log_success "gtop installed"
}

install_carapace() {
  if is_installed carapace; then return 0; fi
  if ! confirm_install "carapace (shell completions)"; then return 0; fi
  
  case "$OS" in
    macos) 
      brew install carapace
      ;;
    ubuntu|arch)
      # Install from GitHub releases
      local version="v1.0.7"
      local arch="amd64"
      if [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]; then
        arch="arm64"
      fi
      
      curl -L "https://github.com/carapace-sh/carapace-bin/releases/download/${version}/carapace-bin_linux_${arch}.tar.gz" -o /tmp/carapace.tar.gz
      sudo tar -xzf /tmp/carapace.tar.gz -C /usr/local/bin carapace
      rm /tmp/carapace.tar.gz
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "carapace installed"
}

# Main installation
main() {
  local programs=(
    "tmux"
    "lazygit"
    "lazydocker"
    "yazi"
    "gh"
    "gh_dash"
    "gtop"
    "carapace"
  )
  
  for program in "${programs[@]}"; do
    "install_$program" || log_warning "Failed to install $program"
  done
  
  log_success "Terminal programs installation complete!"
}

main
