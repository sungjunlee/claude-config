# Claude Code Configuration Installer for Windows
# https://github.com/sungjunlee/claude-config
#
# Usage: 
#   irm https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | iex
#   or
#   Invoke-WebRequest -Uri https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | Invoke-Expression

$ErrorActionPreference = "Stop"

# Configuration
$CLAUDE_CONFIG_DIR = "$env:USERPROFILE\.claude"
$REPO_URL = "https://github.com/sungjunlee/claude-config.git"
$BACKUP_DIR = "$env:USERPROFILE\.claude-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Colors for output
$Host.UI.RawUI.ForegroundColor = "White"

function Write-Success {
    param($Message)
    Write-Host "[+] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param($Message)
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Error {
    param($Message)
    Write-Host "[✗] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Info {
    param($Message)
    Write-Host "[i] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

# Check if running as Administrator (optional for some operations)
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check Claude installation
function Test-ClaudeInstallation {
    Write-Info "Checking Claude Code installation..."
    
    # Check if claude command exists
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if ($claude) {
        try {
            $version = & claude --version 2>$null
            Write-Success "Claude Code is already installed ($version)"
            return $true
        } catch {
            Write-Success "Claude Code is already installed (version unknown)"
            return $true
        }
    }
    
    # Check npm global installation
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $npmList = npm list -g --depth=0 2>$null | Select-String "@anthropic/claude-code"
        if ($npmList) {
            Write-Success "Claude Code is installed via npm"
            return $true
        }
    }
    
    Write-Warning "Claude Code is not installed"
    Write-Info "Please install Claude Code first:"
    Write-Info "  Option 1: npm install -g @anthropic/claude-code"
    Write-Info "  Option 2: Use WSL and follow Linux installation"
    Write-Info "  Option 3: Visit https://claude.ai/download for Windows installer"
    
    $response = Read-Host "Continue without Claude Code? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        exit 1
    }
    return $false
}

# Check if Git is installed
function Test-GitInstallation {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed"
        Write-Info "Please install Git for Windows from https://git-scm.com/download/win"
        exit 1
    }
    Write-Success "Git is installed"
}

# Backup existing configuration
function Backup-Configuration {
    if (Test-Path $CLAUDE_CONFIG_DIR) {
        Write-Success "Backing up existing configuration to $BACKUP_DIR"
        Copy-Item -Path $CLAUDE_CONFIG_DIR -Destination $BACKUP_DIR -Recurse -Force
        Write-Info "Backup created at: $BACKUP_DIR"
    }
}

# Install configuration files
function Install-Configuration {
    Write-Success "Installing Claude Code configuration..."
    
    # Create config directory if it doesn't exist
    if (-not (Test-Path $CLAUDE_CONFIG_DIR)) {
        New-Item -ItemType Directory -Path $CLAUDE_CONFIG_DIR -Force | Out-Null
    }
    
    # Create temporary directory
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    
    try {
        # Clone the repository
        Write-Success "Downloading configuration from GitHub..."
        $gitOutput = git clone --depth 1 $REPO_URL $tempDir 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to download configuration files from GitHub"
            Write-Error "$gitOutput"
            exit 1
        }
        
        # Copy files from temp directory
        Write-Success "Installing agents..."
        Copy-Item -Path "$tempDir\profiles\account\agents" -Destination "$CLAUDE_CONFIG_DIR\" -Recurse -Force
        
        Write-Success "Installing commands..."
        Copy-Item -Path "$tempDir\profiles\account\commands" -Destination "$CLAUDE_CONFIG_DIR\" -Recurse -Force
        
        Write-Success "Installing scripts..."
        Copy-Item -Path "$tempDir\profiles\account\scripts" -Destination "$CLAUDE_CONFIG_DIR\" -Recurse -Force
        
        Write-Success "Installing CLAUDE.md..."
        Copy-Item -Path "$tempDir\profiles\account\CLAUDE.md" -Destination "$CLAUDE_CONFIG_DIR\" -Force
        
        Write-Success "Installing llm-models-latest.md..."
        Copy-Item -Path "$tempDir\profiles\account\llm-models-latest.md" -Destination "$CLAUDE_CONFIG_DIR\" -Force
        
        # Handle settings.json with merge logic
        if (Test-Path "$CLAUDE_CONFIG_DIR\settings.json") {
            Write-Warning "settings.json already exists, creating settings.json.new"
            Copy-Item -Path "$tempDir\profiles\account\settings.json" -Destination "$CLAUDE_CONFIG_DIR\settings.json.new" -Force
            Write-Info "Please manually merge settings.json.new with your existing settings.json"
        } else {
            Write-Success "Installing settings.json..."
            Copy-Item -Path "$tempDir\profiles\account\settings.json" -Destination "$CLAUDE_CONFIG_DIR\" -Force
        }
        
        # Create settings.local.json from example
        if (-not (Test-Path "$CLAUDE_CONFIG_DIR\settings.local.json")) {
            Write-Success "Creating settings.local.json from example..."
            Copy-Item -Path "$tempDir\profiles\account\settings.local.json.example" -Destination "$CLAUDE_CONFIG_DIR\settings.local.json" -Force
            Write-Warning "Please edit $CLAUDE_CONFIG_DIR\settings.local.json with your personal settings"
        }
        
        # Copy docs directory if it exists
        if (Test-Path "$tempDir\docs") {
            Write-Success "Installing documentation..."
            Copy-Item -Path "$tempDir\docs" -Destination "$CLAUDE_CONFIG_DIR\" -Recurse -Force
        }
        
    } finally {
        # Clean up temp directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

# Verify installation
function Test-Installation {
    Write-Success "Verifying installation..."
    
    $success = $true
    
    # Check if files were copied
    if (Test-Path "$CLAUDE_CONFIG_DIR\agents") {
        $agentCount = (Get-ChildItem "$CLAUDE_CONFIG_DIR\agents" -Filter "*.md").Count
        Write-Info "✓ Agents installed ($agentCount files)"
    } else {
        Write-Warning "✗ Agents not found"
        $success = $false
    }
    
    if (Test-Path "$CLAUDE_CONFIG_DIR\commands") {
        $commandCount = (Get-ChildItem "$CLAUDE_CONFIG_DIR\commands" -Filter "*.md" -Recurse).Count
        Write-Info "✓ Commands installed ($commandCount files)"
    } else {
        Write-Warning "✗ Commands not found"
        $success = $false
    }
    
    if (Test-Path "$CLAUDE_CONFIG_DIR\scripts") {
        $scriptCount = (Get-ChildItem "$CLAUDE_CONFIG_DIR\scripts").Count
        Write-Info "✓ Scripts installed ($scriptCount files)"
    } else {
        Write-Warning "✗ Scripts not found"
        $success = $false
    }
    
    if (Test-Path "$CLAUDE_CONFIG_DIR\CLAUDE.md") {
        Write-Info "✓ CLAUDE.md installed"
    } else {
        Write-Warning "✗ CLAUDE.md not found"
        $success = $false
    }
    
    if (-not $success) {
        Write-Warning "Some components may be missing"
    }
}

# Main installation function
function Install-ClaudeConfig {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host " Claude Code Configuration Setup " -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Info "Detected OS: Windows $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Version)"
    
    # Check prerequisites
    Test-GitInstallation
    Test-ClaudeInstallation
    
    # Confirmation prompt
    Write-Host ""
    Write-Warning "This will install Claude Code configuration files to $CLAUDE_CONFIG_DIR"
    $response = Read-Host "Continue? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-Info "Installation cancelled"
        exit 0
    }
    
    # Backup existing configuration
    Backup-Configuration
    
    # Install configuration
    Install-Configuration
    
    # Verify installation
    Test-Installation
    
    Write-Host ""
    Write-Success "Installation complete!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "1. Run 'claude' to start using Claude Code"
    Write-Info "2. Review your configuration in $CLAUDE_CONFIG_DIR"
    Write-Info "3. Customize settings.local.json for personal preferences"
    Write-Host ""
    
    # Add to PATH reminder if needed
    if ($env:CLAUDE_CONFIG_DIR -ne $CLAUDE_CONFIG_DIR) {
        Write-Info "Optional: Add CLAUDE_CONFIG_DIR to your environment variables:"
        Write-Info "  [System.Environment]::SetEnvironmentVariable('CLAUDE_CONFIG_DIR', '$CLAUDE_CONFIG_DIR', 'User')"
    }
}

# Run the installer
Install-ClaudeConfig