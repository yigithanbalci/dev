#!/usr/bin/env bash
#
# AI Tools Installation
# Installs: GitHub Copilot CLI, Claude CLI, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing AI Tools..."

install_copilot_cli() {
  if is_installed github-copilot-cli; then return 0; fi
  if ! confirm_install "GitHub Copilot CLI"; then return 0; fi
  
  case "$OS" in
    macos)
      # Official installer
      curl -fsSL https://gh.io/copilot-install | bash || {
        # Fallback to npm
        if command_exists npm; then
          npm install -g @githubnext/github-copilot-cli
        else
          log_error "Failed to install Copilot CLI"
          return 1
        fi
      }
      ;;
    ubuntu|arch)
      # Use official installer if available
      curl -fsSL https://gh.io/copilot-install | bash || {
        log_warning "Platform-agnostic installer not available for Linux yet"
        
        # Try npm method
        if command_exists npm; then
          npm install -g @githubnext/github-copilot-cli
        else
          log_error "Copilot CLI requires npm. Install Node.js first."
          return 1
        fi
      }
      ;;
    *)
      log_error "Unsupported OS for Copilot CLI"
      return 1
      ;;
  esac
  
  log_success "GitHub Copilot CLI installed"
  log_info "Authenticate with: gh auth login"
}

install_claude_cli() {
  if is_installed claude; then return 0; fi
  if ! confirm_install "Claude CLI"; then return 0; fi
  
  # Claude CLI is typically installed via npm or pip
  if command_exists npm; then
    log_info "Installing Claude CLI via npm..."
    npm install -g claude-cli
  elif command_exists pip3; then
    log_info "Installing Claude CLI via pip..."
    pip3 install --user claude-cli
  else
    log_error "Claude CLI requires npm or pip"
    return 1
  fi
  
  log_success "Claude CLI installed"
}

install_aichat() {
  if is_installed aichat; then return 0; fi
  if ! confirm_install "aichat (multi-model CLI)"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install aichat
      ;;
    ubuntu|arch)
      # Install via cargo if available
      if command_exists cargo; then
        cargo install aichat
      else
        log_warning "aichat requires cargo. Install Rust first."
        return 1
      fi
      ;;
    *)
      log_error "Unsupported OS for aichat"
      return 1
      ;;
  esac
  
  log_success "aichat installed"
}

install_ollama() {
  if is_installed ollama; then return 0; fi
  if ! confirm_install "Ollama (local LLM runner)"; then return 0; fi
  
  case "$OS" in
    macos)
      # Download and install Ollama app
      curl -fsSL https://ollama.com/install.sh | sh
      ;;
    ubuntu|arch)
      # Platform-agnostic installer
      curl -fsSL https://ollama.com/install.sh | sh
      ;;
    *)
      log_error "Unsupported OS for Ollama"
      return 1
      ;;
  esac
  
  log_success "Ollama installed"
  log_info "Start Ollama with: ollama serve"
}

# Main installation
main() {
  local tools=(
    "copilot_cli"
    "claude_cli"
    "aichat"
    "ollama"
  )
  
  for tool in "${tools[@]}"; do
    "install_$tool" || log_warning "Failed to install $tool"
  done
  
  log_success "AI tools installation complete!"
}

main
