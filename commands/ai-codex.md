---
description: Use OpenAI Codex for specialized coding tasks (ChatGPT Plus/Pro)
---

# OpenAI Codex

Use Codex for: $ARGUMENTS

## Prerequisites Check

```bash
if ! command -v codex &> /dev/null; then
  echo "❌ Codex CLI not installed"
  echo ""
  echo "📦 Install:"
  echo "   npm install -g @openai/codex@latest"
  echo ""
  echo "🔐 Login:"
  echo "   codex auth login"
  echo "   (Select 'Sign in with ChatGPT')"
  echo ""
  echo "💳 Requires:"
  echo "   - ChatGPT Plus (\$20/month) → \$5 bonus credits"
  echo "   - ChatGPT Pro (\$200/month) → \$50 bonus credits"
  exit 1
fi

# Check auth status
codex auth status 2>/dev/null || {
  echo "⚠️ Not authenticated. Run: codex auth login"
  exit 1
}
```

## Best Use Cases

**Use Codex for:**
- 🔧 Algorithm optimization and complexity analysis
- 🐛 Complex debugging and root cause analysis
- ⚡ Performance tuning and bottleneck detection
- 🎯 Precise code generation from specs
- 🔍 Advanced refactoring patterns

**Available Models:**
- `gpt-5.2`: High intelligence (Complex tasks)
- `gpt-5.1`: Balanced (General tasks)
- `gpt-5.2-chat-latest`: Latest version

## Execute Codex Analysis

```bash
echo "💻 Analyzing with Codex..."
codex "$ARGUMENTS"
```

## Fallback

If Codex is not available or authentication fails, Claude will handle the request directly.

---

**Run Codex analysis for:** $ARGUMENTS
