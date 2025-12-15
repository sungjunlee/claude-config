# AI Model Integration Commands

Multi-model AI integration commands for cost optimization and specialized tasks.

## 🎯 Overview

Access multiple AI models directly from Claude Code to:
- 💰 **Save 50% on AI costs** (free tier first)
- 🎯 **Save 70% on tokens** (smart routing)
- ⚡ **Use specialized models** for specific tasks
- 🆓 **No API keys needed** (CLI-based auth)

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
/ai:gemini "analyze this architecture"
/ai:route "optimize this algorithm"
/ai:try-free "format this code"
```

## 🚀 Available Commands

### Core Commands

| Command | Purpose | Cost | Best For |
|---------|---------|------|----------|
| `/ai:gemini` | Large analysis | 🆓 Free | 1000+ line files, architecture |
| `/ai:codex` | Code optimization | 💳 Paid | Algorithms, debugging |
| `/ai:try-free` | Cost optimization | 🆓→💳 | Any task (tries free first) |
| `/ai:route` | Smart routing | 🆓→💳 | Auto-select best model |
| `/ai:consensus` | Multi-AI opinions | 🆓+💳 | Critical decisions |
| `/ai:pipeline` | Multi-stage analysis | 🆓+💳 | Complex projects |

### Usage Examples

```bash
# Large file analysis (Free!)
/ai:gemini "analyze entire auth system architecture"

# Algorithm optimization (ChatGPT Plus/Pro)
/ai:codex "optimize this sorting algorithm"

# Cost-optimized (tries free models first)
/ai:try-free "explain this regex pattern"

# Auto-routing (smart model selection)
/ai:route "debug authentication errors"
/ai:route "analyze large_file.py for performance"

# Critical decisions (multiple perspectives)
/ai:consensus "PostgreSQL vs MongoDB for this use case?"

# Complex projects (multi-stage pipeline)
/ai:pipeline auth.py "security audit"
/ai:pipeline api/ "performance optimization"
```

## 💡 Smart Routing Strategy

### Task-Based Routing

The `/ai:route` command automatically selects the best model:

```bash
# Large files → Gemini (huge context)
/ai:route "analyze entire codebase"

# Optimization → Codex (coding specialist)
/ai:route "optimize database queries"

# Debugging → Codex (detailed analysis)
/ai:route "debug IndexError in algorithm.py"

# Quick questions → Gemini (free tier)
/ai:route "explain this function"

# General tasks → Claude (balanced)
/ai:route "review this code"
```

### Cost Optimization

The `/ai:try-free` command minimizes costs:

```bash
# Tries in order: Gemini (free) → Qwen (free) → Codex (paid) → Claude (paid)
/ai:try-free "format this JSON file"
/ai:try-free "explain this code snippet"
```

**Result:** ~50% cost reduction per month

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
/ai:gemini "analyze legacy_system/ for modernization opportunities"

# Step 2: Specific optimization (Paid)
/ai:codex "optimize database access patterns in models.py"

# Step 3: Final synthesis (Claude)
"Create migration roadmap based on above analyses"
```

**Savings:** ~70% tokens vs Claude-only

### Scenario 2: Critical Architecture Decision

```bash
# Get multiple AI perspectives
/ai:consensus "Should we use microservices or monolith for 10-person team?"

# Returns:
# - Gemini's perspective (free)
# - Codex's perspective (paid)
# - Claude's synthesis
```

**Benefit:** Diverse expert opinions

### Scenario 3: Performance Crisis

```bash
# Multi-stage pipeline
/ai:pipeline api_server.py "performance bottlenecks"

# Executes:
# 1. Gemini: Broad analysis
# 2. Codex: Technical optimization
# 3. Claude: Action plan
```

**Result:** Comprehensive solution

## ⚙️ Advanced Workflows

### Pipeline for Security Audit

```bash
/ai:pipeline auth_system.py "security vulnerabilities"
```

**Stages:**
1. Gemini explores entire system
2. Codex identifies specific vulnerabilities
3. Claude creates prioritized fix plan

### Consensus for Tech Stack

```bash
/ai:consensus "React vs Vue for our team's skillset and project requirements?"
```

**Output:**
- Gemini: Broad ecosystem analysis
- Codex: Technical implementation view
- Claude: Balanced recommendation

## 🔍 Command Details

### `/ai:gemini`
- Direct access to Gemini models
- Free with Google account
- Best for large context needs

### `/ai:codex`
- Direct access to OpenAI Codex
- Requires ChatGPT subscription
- Best for code optimization

### `/ai:try-free` ⭐
- Tries free models before paid ones
- Automatic fallback chain
- ~50% cost savings

### `/ai:route` ⭐
- Analyzes task type
- Auto-selects best model
- ~70% token savings

### `/ai:consensus`
- Gathers multiple AI opinions
- Shows diverse perspectives
- Best for critical decisions

### `/ai:pipeline`
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

### Cost Optimization Strategy

1. **Always try `/ai:try-free` first** for routine tasks
2. **Use `/ai:route`** for automatic optimization
3. **Reserve Claude** for synthesis and decisions
4. **Use `/ai:consensus`** only for critical choices

### Token Management

**High token tasks → Gemini:**
- Large file analysis
- Full codebase review
- Multi-file refactoring

**Medium tasks → Auto-route:**
- Single file optimization
- Bug fixes
- Code explanations

**Low tasks → Try-free:**
- Formatting
- Documentation
- Simple queries

## 📈 Expected Results

Based on real-world usage:

- **70% token savings** on routine tasks
- **50% cost reduction** per month
- **Zero downtime** (model switching)
- **Specialized capabilities** for each task

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
ls ~/.claude/commands/ai/

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

**Start saving today:** Install Gemini CLI (free) and use `/ai:try-free` for all tasks!
