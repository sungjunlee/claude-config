# Claude Config - Profile-Based Development Environment

🚀 **Unified configuration system for Claude Code** - Supporting both account-level and project-specific settings.

## 📋 Overview

Claude Config provides a flexible profile-based system for managing Claude Code configurations:

- **Account Profile**: Global settings applied to all projects (~/.claude)
- **Project Profiles**: Language-specific configurations for individual projects
- **Extensible**: Easy to add new languages and tools
- **Backward Compatible**: Existing installations continue to work

## 🚀 Quick Start

### One-line Installation (Account-level)

#### Linux/macOS
```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

#### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | iex
```

### Initialize Project (NEW!)

```bash
# Auto-detect project type
ccfg init auto

# Or specify explicitly
ccfg init python
ccfg init javascript
ccfg init rust
```

## ✨ What You Get

### Account-level Configuration
- **6 Core Agents**: code-reviewer, test-runner, debugger, plan-agent, time-aware, worktree-coordinator
- **20+ Commands** organized by purpose:
  - **Development** (`dev/`): `/commit`, `/test`, `/debug`, `/review`, `/refactor`, `/optimize`, `/explain`
  - **Workflow** (`flow/`): `/plan`, `/handoff`, `/resume`, `/scaffold`, `/fix-errors`, `/reflection`
  - **GitHub** (`gh/`): `/pr`, `/docs`
  - **Worktree** (`worktree/`): `/distribute`, `/status`, `/sync`
  - **AI Models** (`ai/`) 🆕: `/gemini`, `/codex`, `/try-free`, `/route`, `/consensus`, `/pipeline`
- **Multi-Model Integration**: Access Gemini (free) and Codex for specialized tasks
- **Context Management**: Session continuity with handoff/resume system
- **Automatic DateTime Context**: Injects current time into every prompt
- **Headless Ready**: Works on remote Linux servers

### Project Profiles (NEW!)
- **Python**: Ruff, mypy, pytest, pre-commit hooks + custom commands
  - `/optimize` - Python-specific performance optimization
  - `/pytest` - Smart pytest runner with coverage
  - `/venv` - Virtual environment management
- **JavaScript**: ESLint, Prettier, testing frameworks + custom commands
  - `/test` - Smart test runner (Jest, Vitest, Mocha)
  - `/lint` - Intelligent linting and formatting
  - `/bundle` - Build and bundle optimization
- **Rust**: Cargo, Clippy, rustfmt + custom commands
  - `/clippy` - Rust linting with clippy
  - `/bench` - Benchmarking with cargo bench
  - `/cargo-test` - Comprehensive testing
- **Base**: Universal smart commands for any project
  - `/smart-test` - Auto-detects and runs appropriate test framework
  - `/smart-lint` - Auto-detects and runs appropriate linters
  - `/smart-build` - Auto-detects and runs appropriate build system

## 🗂️ New Profile System Structure

```
claude-config/
├── profiles/
│   ├── account/         # Account-level configuration
│   │   ├── agents/      # AI agents
│   │   ├── commands/    # Commands organized by purpose
│   │   │   ├── dev/     # Development tasks
│   │   │   ├── flow/    # Workflow management
│   │   │   ├── gh/      # GitHub operations
│   │   │   ├── worktree/# Git worktree management
│   │   │   └── ai/      # Multi-model AI integration (NEW!)
│   │   ├── scripts/     # Supporting scripts
│   │   └── CLAUDE.md    # Global preferences
│   └── projects/        # Project-specific profiles
│       ├── _base/       # Base configuration
│       ├── python/      # Python environment
│       ├── javascript/  # JS/Node environment
│       └── rust/        # Rust environment
├── lib/                 # Common libraries
├── scripts/             # Management scripts
├── ccfg                # Unified CLI (NEW!)
└── install.sh          # Backward compatible installer
```

## 🔧 Installing the CLI

```bash
# Download and install ccfg CLI
curl -LO https://raw.githubusercontent.com/sungjunlee/claude-config/main/ccfg
chmod +x ccfg

# Option 1: Move to PATH
sudo mv ccfg /usr/local/bin/

# Option 2: Add current directory to PATH
export PATH="$PATH:$(pwd)"
```

## 🛠️ CLI Commands

### `ccfg install`
Install or update account-level configuration (same as running `install.sh`).

### `ccfg init <language>` (NEW!)
Initialize a project with language-specific profile.

```bash
ccfg init python           # Python project
ccfg init auto            # Auto-detect project type
ccfg init javascript --force  # Force overwrite
```

### `ccfg inject <profiles>` (NEW!)
Inject specific profiles into current project.

```bash
ccfg inject python         # Single profile
ccfg inject python+testing # Multiple profiles
```

### `ccfg list` (NEW!)
List all available profiles.

## 📦 Python Profile Features

When you run `ccfg init python`, you get:

- **Modern Linting**: Ruff (replaces Black, Flake8, isort, pyupgrade)
- **Type Checking**: mypy configuration
- **Testing**: pytest with coverage
- **Pre-commit Hooks**: Automated quality checks
- **Package Management**: Support for uv (Rust-based) and pip
- **Claude Integration**: Python-specific agents and commands

Example structure created:
```
your-project/
├── .claude/
│   ├── agents/
│   │   └── python-test-runner.md
│   └── commands/
│       └── pytest.md
├── pyproject.toml       # Modern Python configuration
├── ruff.toml           # Linter settings
├── .pre-commit-config.yaml  # Git hooks
└── .gitignore          # Python-specific ignores
```

## 🎯 Key Commands

| Command | Description |
|---------|-------------|
| `/commit` | Smart conventional commits |
| `/test` | Auto-fix test failures |
| `/debug` | Systematic debugging |
| `/review` | Security & quality review |
| `/handoff` | Save session state |
| `/resume` | Restore session |
| `/plan` | Task planning |
| `/pytest` | Python testing (with Python profile) |

### 🤖 Multi-Model AI Commands (NEW!)

Access specialized AI models for cost savings and task optimization:

| Command | Model | Cost | Best For |
|---------|-------|------|----------|
| `/ai:gemini` | Google Gemini | 🆓 Free | Large files, architecture (1000+ lines) |
| `/ai:codex` | OpenAI Codex | 💳 Paid | Algorithms, debugging (ChatGPT Plus/Pro) |
| `/ai:try-free` | Auto (free→paid) | 🆓→💳 | Cost optimization (~50% savings) |
| `/ai:route` | Auto (task-based) | 🆓→💳 | Smart routing (~70% token savings) |
| `/ai:consensus` | Multi-model | 🆓+💳 | Critical decisions (multiple perspectives) |
| `/ai:pipeline` | Sequential | 🆓+💳 | Complex projects (multi-stage analysis) |

**Quick Setup:**
```bash
# Install Gemini (Free!)
npm install -g @google/gemini-cli
gemini login

# Install Codex (ChatGPT Plus/Pro)
npm install -g @openai/codex@latest
codex auth login
```

📚 **[Full AI Commands Guide](profiles/account/commands/ai/README.md)**

## 🔄 Migration & Updates

The new profile system is **100% backward compatible**:

1. Existing installations continue to work unchanged
2. Run `install.sh` again to get the new features
3. Use `ccfg init` in projects to add language profiles

### Update Commands

#### Linux/macOS
```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

#### Windows
```powershell
irm https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.ps1 | iex
```

## 🕐 Automatic DateTime Context

Claude Code automatically injects current datetime into every prompt:

- Auto-detects system timezone
- Provides multiple formats (ISO 8601, Unix timestamp, UTC)
- Prevents outdated date references in searches
- Customizable via environment variables

```bash
# Override timezone
export TZ='Europe/London'

# Show additional timezones
export CLAUDE_EXTRA_TZ='America/New_York,Asia/Tokyo'
```

## 🔍 Viewing Conversation History

### claude-code-log Tool
```bash
# Install
pip install claude-code-log

# View current project
claude-code-log ~/.claude/projects/$(basename $(pwd)) --open-browser

# Interactive TUI
claude-code-log --tui
```

## 📁 What Gets Installed

### Account Level (~/.claude/)
```
~/.claude/                     # Linux/macOS
%USERPROFILE%\.claude\         # Windows
├── agents/           # 6 specialized agents
├── commands/         # 16 workflow commands
├── scripts/          # Supporting scripts
├── CLAUDE.md         # Global preferences
└── settings.json     # Configuration
```

### Project Level (.claude/)
```
project/.claude/
├── agents/           # Language-specific agents
└── commands/         # Language-specific commands
```

## 🎨 Creating Custom Profiles

Want to add your own language or tool profile? 

1. Create directory: `profiles/projects/myprofile/`
2. Add `profile.yaml` with metadata
3. Include configuration files
4. Submit a PR!

## 🤝 Contributing

Contributions welcome! Priority areas:
- JavaScript/TypeScript profile
- Rust profile
- Go profile
- Additional language profiles

## 📜 License

MIT - Use freely in your projects.

## 🔗 Links

- [Repository](https://github.com/sungjunlee/claude-config)
- [Issues](https://github.com/sungjunlee/claude-config/issues)

---

*Built for developers who value consistency and efficiency in their AI-assisted development.*