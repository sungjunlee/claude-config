# Claude Config

Personal Claude Code configuration for efficient AI-assisted development.

## 🚀 One-line Installation

### Linux/macOS
```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | iex
```

## ✨ What You Get

- **4 Core Agents**: Code reviewer, test runner, debugger, time-aware
- **10 Essential Commands**: `/commit`, `/test`, `/debug`, `/review`, etc.
- **Minimal Global Config**: Lean CLAUDE.md for all projects
- **Automatic DateTime Context**: Injects current time into every prompt
- **Headless Ready**: Works on remote Linux servers

## 🎯 Key Commands

| Command | Description |
|---------|-------------|
| `/commit` | Smart conventional commits |
| `/test` | Auto-fix test failures |
| `/debug` | Systematic debugging |
| `/review` | Security & quality review |
| `/plan` | Task planning |

## 📁 What Gets Installed

```
~/.claude/                     # Linux/macOS
%USERPROFILE%\.claude\         # Windows
├── agents/           # 4 specialized agents
├── commands/         # 10 workflow commands
├── CLAUDE.md         # Global preferences
└── settings.json     # Configuration
```

## ⚙️ Alternative Installation

### Linux/macOS
```bash
# Clone and review first
git clone https://github.com/sungjunlee/claude-config.git
cd claude-config
./install.sh

# For servers via SSH
ssh user@server "bash -s" < install.sh
```

### Windows
```powershell
# Clone and review first
git clone https://github.com/sungjunlee/claude-config.git
cd claude-config
.\install.ps1

# Or download and run
Invoke-WebRequest -Uri https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 -OutFile install.ps1
.\install.ps1
```

## 🕐 Automatic DateTime Context

Claude Code automatically injects current datetime into every prompt via the UserPromptSubmit hook. This prevents Claude from defaulting to outdated dates in searches and ensures time-aware responses.

### Features
- Auto-detects system timezone across Linux, macOS, and WSL
- Provides multiple time formats (ISO 8601, Unix timestamp, UTC reference)
- Zero configuration - works immediately after installation
- Customizable via environment variables

### Customization
```bash
# Override timezone detection
export TZ='Europe/London'

# Show additional timezones
export CLAUDE_EXTRA_TZ='America/New_York,Asia/Tokyo,Europe/Berlin'
```

## 🔍 Viewing Conversation History

### claude-code-log Tool
View and search your Claude Code conversations with HTML output:

```bash
# Install
pip install claude-code-log

# View current project
claude-code-log ~/.claude/projects/$(basename $(pwd) | sed 's/\//-/g') --open-browser

# View all projects
claude-code-log --all-projects --open-browser

# Interactive TUI mode
claude-code-log --tui

# Filter by date
claude-code-log ~/.claude/projects/your-project --from-date "yesterday" --to-date "today"
```

Generated HTML files are saved in `.cache/` directory within each project folder.

## 🔄 Updates

### Linux/macOS
```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

### Windows
```powershell
irm https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | iex
```

Your existing settings are automatically backed up.

---

**License**: MIT