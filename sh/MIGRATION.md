# Installation System Migration Guide

## Overview

The new installation system in `sh/` provides a modernized, well-documented approach to installing development tools on Unix-based systems. It replaces the original `install` + `installs/` structure with a more maintainable and user-friendly system.

## Key Improvements

### 1. **Better Organization**
- **Old**: Individual files per tool in category subdirectories
- **New**: Grouped by category in single, well-organized scripts

### 2. **Modern Installation Methods**
- Prefers official curl-based installers (platform-agnostic)
- Falls back to native package managers (brew, apt, pacman, etc.)
- Examples:
  - Rust: `curl https://sh.rustup.rs | sh`
  - NVM: `curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`
  - Zoxide: `curl https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh`

### 3. **Enhanced Features**
- ✅ Interactive category selection
- ✅ Dry-run mode (`--dry-run`)
- ✅ Flexible filtering (include/exclude)
- ✅ Comprehensive help (`--help`)
- ✅ Category listing (`--list`)
- ✅ Non-interactive mode for automation
- ✅ Colored output with status indicators
- ✅ Smart OS detection

### 4. **Better User Experience**
```bash
# Old system
DEV_ENV=$(pwd) ./install          # Install everything
DEV_ENV=$(pwd) ./install git      # Install matching tools
DEV_ENV=$(pwd) ./install --ignore docker  # Exclude tools

# New system
./sh/install.sh                   # Interactive mode
./sh/install.sh cli langs         # Install specific categories
./sh/install.sh --all -e docker   # Install all except docker
./sh/install.sh --dry-run cli     # Preview changes
```

## Side-by-Side Comparison

| Feature | Old System | New System |
|---------|-----------|------------|
| Organization | `installs/category/tool` | `sh/category.sh` |
| Documentation | Minimal comments | Comprehensive README + inline docs |
| Help text | None | `--help` flag with examples |
| Dry-run | None | `--dry-run` flag |
| Interactive | No | Yes (default) |
| Filtering | Basic grep | Include/exclude patterns |
| Installation | Package manager only | Curl installers + package managers |
| Logging | Basic echo | Colored status indicators |
| OS Detection | Repeated in each file | Centralized in `common.sh` |

## Migration Path

### For Users

**Option 1: Keep using old system**
```bash
# Old system still works
DEV_ENV=$(pwd) ./install
```

**Option 2: Try new system**
```bash
# New system - more flexible
./sh/install.sh
```

Both systems can coexist. The old system remains untouched.

### For Maintainers

To update or add tools:

**Old system**: Edit individual files in `installs/category/tool`

**New system**: Edit category scripts in `sh/category.sh`
```bash
# Example: Add a new tool to CLI category
vim sh/cli.sh

# Add installation function
install_newtool() {
  if is_installed newtool; then return 0; fi
  if ! confirm_install "newtool"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install newtool ;;
    ubuntu|arch) pkg_install newtool ;;
    *) curl -fsSL https://newtool.com/install.sh | bash ;;
  esac
  
  log_success "newtool installed"
}

# Add to tools list in main()
tools_to_install+=(
  "newtool"
)
```

## Tool Coverage

All tools from the old system are included in the new system:

### CLI Tools (cli.sh)
- ripgrep, fzf, fd, bat, eza, jq, zoxide, atuin, tldr, stow, tree-sitter, lazygit, television, sesh, worktrunk, awk, curl

### Languages (langs.sh)
- Rust, Go, Node.js (via nvm), Zig, Python, GCC, G++, LLVM

### Editors (editors.sh)
- Neovim, Emacs, Zed

### Shells (shells.sh)
- Fish, Zsh, Oh My Zsh, Starship

### Terminals (terminals.sh)
- WezTerm, Kitty, Ghostty, Alacritty

### Terminal Tools (terminal-tools.sh)
- tmux, lazygit, lazydocker, yazi, gh-dash, gtop, carapace, GitHub CLI

### DevOps (devops.sh)
- Docker, Docker Compose, Colima, kubectl, Helm, k9s

### Build Tools (build.sh)
- CMake, Make, Ninja, Meson

### Shell Utils (shell-utils.sh)
- direnv, doppler, fastfetch, pass, neofetch, thefuck

### AI Tools (ai.sh)
- GitHub Copilot CLI, Claude CLI, aichat, Ollama

## Best Practices

### For New Installations

1. **Start with dry-run**
   ```bash
   ./sh/install.sh --dry-run cli langs
   ```

2. **Use interactive mode** for first-time setup
   ```bash
   ./sh/install.sh
   ```

3. **Install categories incrementally**
   ```bash
   ./sh/install.sh cli        # Start with CLI tools
   ./sh/install.sh langs      # Then languages
   ./sh/install.sh editors    # Then editors
   ```

### For CI/CD

Use non-interactive mode:
```bash
export INSTALL_NONINTERACTIVE=1
./sh/install.sh --yes cli langs devops
```

### For Development

Test changes with dry-run:
```bash
./sh/install.sh --dry-run --all
```

## Future Enhancements

Potential improvements for the new system:

1. **Version management**: Specify tool versions
2. **Update command**: Update all installed tools
3. **Uninstall support**: Remove installed tools
4. **Config file**: Define desired tools in YAML/TOML
5. **Rollback**: Undo installations
6. **Parallel installation**: Install multiple tools simultaneously
7. **Progress indicators**: Show installation progress
8. **Logging**: Write installation logs to file

## Conclusion

The new `sh/` system provides:
- ✅ Better maintainability
- ✅ More flexibility
- ✅ Superior user experience
- ✅ Modern installation methods
- ✅ Comprehensive documentation

While maintaining backward compatibility with the old system.

Choose the system that works best for you!
