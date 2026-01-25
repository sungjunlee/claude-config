# AI Model Integration Commands

Multi-model AI integration commands for specialized tasks.

## 🎯 Overview

Access multiple AI models directly from Claude Code to:
- ⚡ **Use specialized models** for specific tasks
- 🆓 **No API keys needed** (CLI-based auth)
- 🧠 **Get multiple perspectives** on critical decisions

Based on [this proven workflow](https://lgallardo.com/2025/09/06/claude-code-supercharged-mcp-integration/).

## 📦 Quick Start

### 1. Install Free Models (Recommended!)

```bash
# Gemini (Free with Google account)
npm install -g @google/gemini-cli
gemini login  # Opens browser for Google auth
```

### 2. Install Paid Models (Optional)

```bash
# OpenAI Codex (ChatGPT Plus/Pro subscribers)
npm install -g @openai/codex@latest
codex auth login  # Sign in with ChatGPT
```

### 3. Test Commands

```bash
# In Claude Code
/my:gemini "analyze this architecture"
/my:codex "optimize this algorithm"
/my:consensus "PostgreSQL vs MongoDB?"
```

## 🚀 Available Commands

| Command | Purpose | Cost | Best For |
|---------|---------|------|----------|
| `/my:gemini` | Large analysis | 🆓 Free | 1000+ line files, architecture |
| `/my:codex` | Code optimization | 💳 Paid | Algorithms, debugging |
| `/my:consensus` | Multi-AI opinions | 🆓+💳 | Critical decisions |
| `/my:pipeline` | Multi-stage analysis | 🆓+💳 | Complex projects |

### Usage Examples

```bash
# Large file analysis (Free!)
/my:gemini "analyze entire auth system architecture"

# Algorithm optimization (ChatGPT Plus/Pro)
/my:codex "optimize this sorting algorithm"

# Critical decisions (multiple perspectives)
/my:consensus "PostgreSQL vs MongoDB for this use case?"

# Complex projects (multi-stage pipeline)
/my:pipeline auth.py "security audit"
/my:pipeline api/ "performance optimization"
```

## 🔧 Model Capabilities

### Gemini (Free!)

**Strengths:**
- Massive context window (2M tokens)
- Free with Google account
- 60 requests/min, 1,000 requests/day

**Best For:**
- Large codebase analysis
- Architecture review
- Creative brainstorming
- Complex system design

**Setup:**
```bash
npm install -g @google/gemini-cli
gemini login
```

### OpenAI Codex (Paid)

**Strengths:**
- Coding-specialized models
- Deep reasoning (gpt-5-high)
- Debugging expertise

**Best For:**
- Algorithm optimization
- Complex debugging
- Performance tuning
- Precise code generation

**Requirements:**
- ChatGPT Plus ($20/mo) → $5 bonus credits
- ChatGPT Pro ($200/mo) → $50 bonus credits

**Setup:**
```bash
npm install -g @openai/codex@latest
codex auth login  # Select 'Sign in with ChatGPT'
```

## 📊 Real-World Scenarios

### Scenario 1: Large Legacy Refactoring

```bash
# Step 1: Broad analysis (Free)
/my:gemini "analyze legacy_system/ for modernization opportunities"

# Step 2: Specific optimization (Paid)
/my:codex "optimize database access patterns in models.py"

# Step 3: Final synthesis (Claude)
"Create migration roadmap based on above analyses"
```

### Scenario 2: Critical Architecture Decision

```bash
# Get multiple AI perspectives
/my:consensus "Should we use microservices or monolith for 10-person team?"

# Returns:
# - Gemini's perspective (free)
# - Codex's perspective (paid)
# - Claude's synthesis
```

**Benefit:** Diverse expert opinions

### Scenario 3: Performance Crisis

```bash
# Multi-stage pipeline
/my:pipeline api_server.py "performance bottlenecks"

# Executes:
# 1. Gemini: Broad analysis
# 2. Codex: Technical optimization
# 3. Claude: Action plan
```

**Result:** Comprehensive solution

## ⚙️ Advanced Workflows

### Pipeline for Security Audit

```bash
/my:pipeline auth_system.py "security vulnerabilities"
```

**Stages:**
1. Gemini explores entire system
2. Codex identifies specific vulnerabilities
3. Claude creates prioritized fix plan

### Consensus for Tech Stack

```bash
/my:consensus "React vs Vue for our team's skillset and project requirements?"
```

**Output:**
- Gemini: Broad ecosystem analysis
- Codex: Technical implementation view
- Claude: Balanced recommendation

## 🔍 Command Details

### `/my:gemini`
- Direct access to Gemini models
- Free with Google account
- Best for large context needs

### `/my:codex`
- Direct access to OpenAI Codex
- Requires ChatGPT subscription
- Best for code optimization

### `/my:consensus`
- Gathers multiple AI opinions
- Shows diverse perspectives
- Best for critical decisions

### `/my:pipeline`
- Multi-stage analysis workflow
- Combines model strengths
- Best for complex projects

## 🎓 Tips & Best Practices

### When to Use Each Model

**Use Gemini (Free) for:**
- Files > 1000 lines
- Architecture discussions
- Brainstorming sessions
- Educational queries

**Use Codex (Paid) for:**
- Algorithm complexity analysis
- Performance-critical code
- Security-sensitive debugging
- Production code generation

**Use Claude for:**
- General development tasks
- Final decision-making
- Team collaboration
- Balanced analysis

## 🆘 Troubleshooting

### Gemini Issues

```bash
# Not authenticated
gemini login

# Using API key by mistake (should use free tier)
unset GEMINI_API_KEY
gemini /auth  # Verify free tier

# Check status
gemini --version
```

### Codex Issues

```bash
# Authentication failed
codex logout
codex auth login  # Select 'Sign in with ChatGPT'

# Check auth status
codex auth status

# Model selection
codex /model  # Choose gpt-5 variant
```

### Command Not Found

```bash
# Verify installation
ls ~/.claude/commands/

# Reinstall if needed
cd /path/to/claude-config
./install.sh
```

## 🔗 Resources

- [Blog Post](https://lgallardo.com/2025/09/06/claude-code-supercharged-mcp-integration/) - Original workflow
- [Gemini CLI](https://www.npmjs.com/package/@google/gemini-cli) - Free tier
- [OpenAI Codex](https://www.npmjs.com/package/@openai/codex) - ChatGPT integration
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code/slash-commands) - Slash commands

---

**Start using:** Install Gemini CLI (free) and use `/my:gemini` for large file analysis!
