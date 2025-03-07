param (
    [switch]$DryRun
)

if (-not ($DryRun)) {
  # Check if Scoop is installed
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
      Write-Host "Scoop is not installed. Installing Scoop..."
      
      # Run the Scoop installer
      Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  }
}

# Ensure Scoop is in the current session's path
$env:Path += ";$HOME\scoop\shims"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scoopsDir = Join-Path $scriptDir "scoops"

if (-not (Test-Path $scoopsDir)) {
    Write-Host "Directory 'scoops' not found in: $scriptDir"
    exit 1
}

$scripts = Get-ChildItem -Path $scoopsDir -Filter "*.ps1"

foreach ($script in $scripts) {
    if ($DryRun) {
        Write-Host "[DRY RUN] Would run: $script"
    } else {
        Write-Host "Running: $script"
        & $script.FullName
    }
}
