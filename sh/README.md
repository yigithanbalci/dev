# Modern Unix Installation Scripts

A modern, well-documented, and configurable installation system for Unix-based operating systems (macOS, Ubuntu, Arch Linux, etc.).

## Features

- **Platform-Agnostic Installers**: Uses official curl-based installers when available
- **Configurable**: Install only what you need with flexible filtering
- **Well-Documented**: Clear descriptions and help messages
- **Interactive & Non-Interactive**: Supports both modes
- **Modular**: Organized by category for easy maintenance
- **Smart**: Detects OS and uses appropriate package managers
- **Safe**: Dry-run mode to preview changes

## Quick Start

```bash
# Interactive mode - select categories
./sh/install.sh

# Install specific categories
./sh/install.sh cli langs editors

# Install everything
./sh/install.sh --all

# Exclude specific tools
./sh/install.sh --all -e docker -e kubernetes

# Preview what would be installed
./sh/install.sh --dry-run cli
```

## Available Categories

| Category | Description | Key Tools |
|----------|-------------|-----------|
| **cli** | Modern CLI tools | ripgrep, fzf, fd, bat, eza, jq, zoxide, atuin |
| **langs** | Programming languages | Rust, Go, Node.js (nvm), Python, Zig, GCC, LLVM |
| **editors** | Text editors | Neovim, Emacs, Zed |
| **shells** | Shell environments | Fish, Zsh, Oh My Zsh, Starship |
| **terminals** | Terminal emulators | WezTerm, Kitty, Ghostty, Alacritty |
| **terminal-tools** | Terminal programs | tmux, lazygit, lazydocker, yazi, gh-dash |
| **devops** | DevOps tools | Docker, Kubernetes, Colima, Helm, k9s |
| **build** | Build tools | CMake, Make, Ninja, Meson |
| **shell-utils** | Shell utilities | direnv, doppler, fastfetch, pass |
| **ai** | AI tools | GitHub Copilot CLI, Claude CLI, Ollama |

## Usage Examples

### Interactive Installation
```bash
# Run without arguments to get an interactive prompt
./sh/install.sh
```

### Install Specific Categories
```bash
# Install CLI tools and programming languages
./sh/install.sh cli langs

# Install just editors
./sh/install.sh editors
```

### Install Everything
```bash
# Install all categories
./sh/install.sh --all
```

### Exclude Specific Tools
```bash
# Install everything except Docker and Kubernetes
./sh/install.sh --all --exclude docker --exclude kubernetes

# Multiple excludes
./sh/install.sh -e docker -e rust -e emacs
```

### Dry Run (Preview)
```bash
# See what would be installed without actually installing
./sh/install.sh --dry-run cli langs

# Preview full installation
./sh/install.sh --dry-run --all
```

### Non-Interactive Mode
```bash
# Skip all prompts (useful for CI/CD)
export INSTALL_NONINTERACTIVE=1
./sh/install.sh cli langs

# Or use the flag
./sh/install.sh --yes cli langs
```

## Installation Methods

The scripts prefer platform-agnostic installation methods when available:

### Official Installers (curl-based)
Many tools provide official installers that work across platforms:
- **Rust**: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **NVM**: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`
- **Zoxide**: `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh`
- **Ollama**: `curl -fsSL https://ollama.com/install.sh | sh`

### Package Managers
Falls back to native package managers:
- **macOS**: Homebrew
- **Ubuntu/Debian**: apt
- **Arch Linux**: pacman
- **Fedora**: dnf

## Individual Category Scripts

You can also run category scripts directly:

```bash
# Install just CLI tools
./sh/cli.sh

# Install programming languages
./sh/langs.sh

# Install editors
./sh/editors.sh
```

Each script sources `common.sh` which provides shared utilities like OS detection, logging, and installation helpers.

## Environment Variables

- `DEV_ENV` - Path to devenv repository (auto-detected)
- `INSTALL_NONINTERACTIVE=1` - Skip all prompts

## Command-Line Options

```
Options:
  -h, --help           Show help message
  -l, --list          List all available categories
  -a, --all           Install all categories
  -e, --exclude       Exclude categories/scripts (can be used multiple times)
  -d, --dry-run       Preview installation without making changes
  -i, --interactive   Enable interactive mode (default)
  -y, --yes           Non-interactive mode, use defaults
```

## Supported Operating Systems

- **macOS** (tested on macOS 10.15+)
- **Ubuntu** (20.04, 22.04, 24.04)
- **Debian** (via Ubuntu scripts)
- **Arch Linux** (and derivatives like Manjaro)
- Other Linux distributions may work with platform-agnostic installers

## Architecture

```
sh/
├── install.sh           # Main orchestrator
├── common.sh            # Shared utilities
├── cli.sh              # CLI tools
├── langs.sh            # Programming languages
├── editors.sh          # Text editors
├── shells.sh           # Shell environments
├── terminals.sh        # Terminal emulators
├── terminal-tools.sh   # Terminal programs
├── devops.sh           # DevOps tools
├── build.sh            # Build tools
├── shell-utils.sh      # Shell utilities
└── ai.sh               # AI tools
```

## Comparison with Old System

### Old System (`install` + `installs/`)
- One file per tool
- Less documented
- No dry-run mode
- Basic filtering
- Harder to maintain

### New System (`sh/`)
- Grouped by category
- Well-documented with help text
- Dry-run support
- Flexible filtering (include/exclude)
- Interactive mode
- Platform-agnostic installers preferred
- Consistent logging and error handling
- Easy to extend

## Adding New Tools

To add a new tool, edit the appropriate category script:

```bash
install_newtool() {
  if is_installed newtool; then return 0; fi
  if ! confirm_install "newtool"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install newtool ;;
    ubuntu|arch) pkg_install newtool ;;
    *)
      # Platform-agnostic method
      curl -fsSL https://example.com/install.sh | bash
      ;;
  esac
  
  log_success "newtool installed"
}

# Add to main() function
tools_to_install+=(
  "newtool"
)
```

## Contributing

Feel free to add more tools or improve installation methods:

1. Prefer official curl-based installers when available
2. Add OS detection for platform-specific packages
3. Include helpful post-installation messages
4. Test on multiple platforms

## License

MIT

## Credits

Built to modernize and improve upon the original `install` and `installs/` system.
