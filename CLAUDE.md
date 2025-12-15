# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Profile-based Claude Code configuration system with two-tier architecture:
- **Account Profile**: Global settings for all projects (~/.claude/)
- **Project Profiles**: Language-specific configs for individual projects (.claude/)

## Core Architecture

### Command Resolution Order
```text
Project (.claude/commands/) → Account (~/.claude/commands/) → Built-in
```

### Profile System Structure
```text
profiles/
├── account/                    # Global configuration
│   ├── agents/                # 7 AI agents (code-reviewer, test-runner, debugger, etc.)
│   ├── commands/              # 16+ workflow commands organized by namespace
│   │   ├── dev/               # Development: /commit, /test, /debug, /review, etc.
│   │   ├── flow/              # Workflow: /plan, /handoff, /resume, /scaffold
│   │   ├── gh/                # GitHub: /pr, /docs
│   │   └── worktree/          # Git worktree management
│   ├── scripts/               # Supporting automation scripts
│   ├── CLAUDE.md              # Global user preferences
│   └── settings.json          # Claude Code settings
│
└── projects/                   # Language-specific profiles
    ├── _base/                 # Universal smart commands
    ├── python/                # Python: ruff, mypy, pytest
    ├── javascript/            # JS/TS: eslint, prettier, testing
    ├── rust/                  # Rust: cargo, clippy
    └── flutter/               # Flutter: dart, flutter tools
```

## Development Commands

### Testing & Building
```bash
# Use language-specific profile installers for testing
cd profiles/projects/python && ./install.sh  # Test Python profile
cd profiles/projects/javascript && ./install.sh  # Test JS profile

# Test account-level installation
./install.sh --force  # From repo root

# The ccfg CLI is the unified interface
./ccfg install        # Install account profile
./ccfg init python    # Initialize project profile
./ccfg init auto      # Auto-detect project type
./ccfg list           # List available profiles
```

### Installation Flow (install.sh)
1. OS detection (macOS/Linux/Windows via Git Bash)
2. Prerequisites check (git, curl)
3. Optional Claude Code CLI installation
4. Backup existing ~/.claude/
5. Copy files with interactive settings.json merge
6. Set executable permissions on scripts
7. Verify installation

### Profile Application (ccfg init)
1. Detect or validate project type
2. Load profile.yaml configuration
3. Check dependencies (optional with prompt)
4. Copy .claude/agents and .claude/commands
5. Copy config files (pyproject.toml, ruff.toml, etc.)
6. Run profile-specific install.sh if present
7. Set up pre-commit hooks if configured

## Key Implementation Patterns

### Shell Script Standards
- Strict mode: `set -euo pipefail`
- TTY/non-TTY support for headless installs
- Color output with fallback for pipes
- Input validation against path traversal
- Proper error handling and exit codes

### Profile Configuration (profile.yaml)
```yaml
name: python
type: project
parent: _base  # Inheritance support
dependencies:
  - "git"
  - "python>=3.8"
features:
  - ruff
  - mypy
  - pytest
```

### Settings Merge Strategy (install.sh:handle_settings_merge)
Interactive prompts when settings.json conflicts:
- Keep existing (default)
- Replace with new
- Backup existing and install new
- Show diff
- Save as settings.json.new for manual merge

### Context-Aware Agents
Account-level agents automatically detect project context:
- Read project files (package.json, pyproject.toml, Cargo.toml)
- Apply language-specific conventions
- Maintain general best practices

## Library Functions

### lib/common.sh
- `detect_os()`: Returns "linux:distro:version" or "macos:version"
- `command_exists()`: Check command availability
- `check_prerequisites()`: Validate required commands
- `create_backup()`: Backup with timestamp
- `confirm()`: Interactive Y/N prompt with default
- `parse_yaml_value()`: YAML parser with yq fallback
- `get_project_root()`: Find project root via .git/package.json/pyproject.toml

### lib/profile.sh
- `detect_project_type()`: Auto-detect from project files
- `load_profile()`: Load profile with parent inheritance
- `check_profile_dependencies()`: Validate required tools
- `apply_profile()`: Copy files, run install.sh, setup hooks

## Design Philosophy (docs/DESIGN_PHILOSOPHY.md)

### Key Principles
1. **Override Hierarchy**: Project > Account > Built-in
2. **Progressive Enhancement**: Add capabilities without breaking existing workflows
3. **Language-Aware Context**: Agents adapt to project type
4. **Safe Rollback**: File-based, non-destructive, independently removable
5. **Gradual Adoption**: Commands → Agents → Hooks (each phase valuable independently)

### Anti-Patterns Avoided
- ❌ Replacing core Claude Code functionality
- ❌ Forcing specific workflows
- ❌ Complex configuration requirements
- ❌ Non-disableable features
- ❌ "Magic" that obscures behavior

## Security Considerations

- No telemetry or data collection
- All processing happens locally
- Path traversal validation in profile loading
- Install script validation before execution
- Explicit user consent for automation
- Audit logging for automated changes

## Adding New Features

### New Language Profile
1. Create `profiles/projects/[language]/`
2. Add `profile.yaml` with metadata and dependencies
3. Create `.claude/commands/` and `.claude/agents/`
4. Add config files (linter configs, etc.)
5. Optional: Add `install.sh` for setup automation
6. Test with `ccfg init [language]`

### New Account Command
1. Create `.md` file in `profiles/account/commands/[namespace]/`
2. Add frontmatter with description
3. Use `$ARGUMENTS` for parameter passing
4. Test by copying to ~/.claude/ or reinstalling

### New Agent
1. Create `.md` file in `profiles/account/agents/`
2. Define agent capabilities and context detection
3. Specify when to auto-invoke (optional)
4. Test in real project scenarios

## Important File Locations

- Account settings: `profiles/account/settings.json`
- Global preferences: `profiles/account/CLAUDE.md`
- LLM model guide: `profiles/account/llm-models-latest.md`
- Handoff system: `profiles/account/scripts/` (session continuity)
- DateTime injection: `profiles/account/scripts/inject_datetime.sh`
- Worktree management: `profiles/account/scripts/worktree-manager.sh`

## Testing New Changes

1. Test account installation:
   ```bash
   ./install.sh --force
   # Verify ~/.claude/ contents
   ```

2. Test project profile:
   ```bash
   # In a test project directory
   /path/to/claude-config/ccfg init python
   # Verify .claude/ contents
   ```

3. Test CLI functions:
   ```bash
   ./ccfg list
   ./ccfg init auto
   ```

4. Validate shell scripts:
   ```bash
   shellcheck install.sh lib/*.sh scripts/*.sh
   ```

## Migration & Updates

- System is 100% backward compatible
- Old installations work unchanged after update
- Settings merge handles conflicts interactively
- Backup created automatically before installation
- Documentation in MIGRATION.md for breaking changes
