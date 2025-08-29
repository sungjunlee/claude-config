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