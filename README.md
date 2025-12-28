# Claude Config - Skills-Based Development Environment

🚀 **Unified configuration system for Claude Code** - Leveraging Skills architecture with integrated commands and agents.

## 📋 Overview

Claude Config provides a modern Skills-based system for enhancing Claude Code:

- **Skills Architecture**: Modular capabilities with SKILL.md, workflows/, and context/
- **Account-Level Settings**: Global configuration applied to all projects (~/.claude)
- **Plugin Integration**: Works with official plugins (pr-review-toolkit, document-skills)
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

### Skills (Modular Capabilities)
- **Workflow Skill**: `/flow:handoff`, `/flow:resume`, `/flow:plan`, `/flow:fix-errors`
- **Worktree Skill**: `/worktree:distribute`, `/worktree:plan`, `/worktree:status`, `/worktree:sync`
- **Testing Skill**: `/dev:test` with language-specific context (Python, JavaScript, Rust)
- **Linting Skill**: `/dev:lint` with language-specific context (ruff, ESLint, Clippy)
- **Frameworks Skill**: FastAPI patterns and async SQLAlchemy guides

### Commands (Standalone Operations)
- **Development** (`dev/`): `/commit`, `/refactor`, `/optimize`, `/explain`, `/epct`, `/cr`
- **GitHub** (`gh/`): `/pr`
- **AI Models** (`ai/`): `/gemini`, `/codex`, `/try-free`, `/route`, `/consensus`, `/pipeline`

### Agents
- **time-aware**: Automatic datetime context injection

### Plugin Integration
Works seamlessly with official Claude Code plugins:
- **pr-review-toolkit**: Comprehensive code review
- **document-skills**: Documentation generation
- **silent-failure-hunter**: Error detection

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

## 🗂️ Directory Structure

```
claude-config/
├── profiles/
│   └── account/              # Account-level configuration (~/.claude/)
│       ├── skills/           # Skills architecture (NEW!)
│       │   ├── workflow/     # Handoff, resume, plan, fix-errors
│       │   ├── worktree/     # Parallel worktree management
│       │   ├── testing/      # Language-aware testing
│       │   ├── linting/      # Language-aware linting
│       │   └── frameworks/
│       │       └── fastapi/  # FastAPI patterns
│       ├── commands/         # Standalone commands
│       │   ├── dev/          # commit, refactor, optimize, explain, epct, cr
│       │   ├── gh/           # pr
│       │   └── ai/           # Multi-model AI integration
│       ├── agents/           # time-aware agent
│       ├── scripts/          # Supporting scripts
│       └── CLAUDE.md         # Global preferences
├── lib/                      # Common libraries
├── ccfg                      # Unified CLI
└── install.sh                # Installation script
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

## 🎯 Key Commands & Skills

### Skills (Invoke with `/skill:workflow`)
| Skill | Commands | Description |
|-------|----------|-------------|
| `workflow` | `/flow:handoff`, `/flow:resume`, `/flow:plan`, `/flow:fix-errors` | Session management |
| `worktree` | `/worktree:distribute`, `/worktree:plan`, `/worktree:status`, `/worktree:sync` | Parallel development |
| `testing` | `/dev:test` | Language-aware testing |
| `linting` | `/dev:lint` | Language-aware linting |
| `fastapi` | Automatic context | FastAPI patterns |

### Standalone Commands
| Command | Description |
|---------|-------------|
| `/dev:commit` | Smart conventional commits |
| `/dev:refactor` | Code refactoring |
| `/dev:optimize` | Performance optimization |
| `/dev:explain` | Code explanation |
| `/dev:epct` | Explore-Plan-Code-Test workflow |
| `/dev:cr` | CodeRabbit integration hub |
| `/gh:pr` | Pull request creation |

### Plugin Commands (Official)
| Plugin | Description |
|--------|-------------|
| `/pr-review-toolkit:review-pr` | Comprehensive PR review |
| `/document-skills:pdf` | PDF manipulation |
| `/document-skills:docx` | Word document handling |

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

### 🎨 Skills Architecture

Each skill follows a consistent structure:
```
skill-name/
├── SKILL.md           # Skill definition and metadata
├── workflows/         # Executable workflows
│   └── action.md      # Individual workflow files
└── context/           # Domain knowledge
    └── guide.md       # Reference documentation
```

Skills are invoked using the pattern: `/skill-name:workflow`

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
├── skills/           # 5 skills (workflow, worktree, testing, linting, frameworks)
├── commands/         # Standalone commands (dev, gh, ai)
├── agents/           # time-aware agent
├── scripts/          # Supporting scripts
├── CLAUDE.md         # Global preferences
└── settings.json     # Configuration
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