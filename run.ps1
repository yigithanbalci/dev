# Get the directory of the current script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scoopScript = Join-Path $scriptDir "scoop.ps1"

# Check if scoop.ps1 exists
if (-not (Test-Path $scoopScript)) {
    Write-Host "Error: scoop.ps1 not found in $scriptDir"
    exit 1
}

# Run scoop.ps1
Write-Host "Running scoop.ps1..."
& $scoopScript
