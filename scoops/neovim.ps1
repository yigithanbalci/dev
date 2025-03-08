# Check if Neovim is already installed
if (scoop list neovim -ErrorAction SilentlyContinue) {
    Write-Host "Neovim is already installed."
} else {
    Write-Host "Installing Neovim..."
    
    # Install Neovim using Scoop
    scoop install neovim
}

# Verify installation
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Write-Host "Neovim installed successfully!"
} else {
    Write-Host "Neovim installation failed."
}
