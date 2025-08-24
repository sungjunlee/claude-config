# Claude Config

Personal Claude Code configuration for efficient AI-assisted development.

## 🚀 One-line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
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
~/.claude/
├── agents/           # 4 specialized agents
├── commands/         # 10 workflow commands
├── CLAUDE.md         # Global preferences
└── settings.json     # Configuration
```

## ⚙️ Alternative Installation

```bash
# Clone and review first
git clone https://github.com/sungjunlee/claude-config.git
cd claude-config
./install.sh

# For servers via SSH
ssh user@server "bash -s" < install.sh
```

## 🔄 Updates

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

Your existing settings are automatically backed up.

---

**License**: MIT