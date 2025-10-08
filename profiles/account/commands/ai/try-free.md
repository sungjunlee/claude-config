---
description: Try free models first, escalate to premium only if needed (50% cost savings)
---

# Smart Free-First Routing

Cost-optimized routing for: $ARGUMENTS

## Strategy: Free → Paid Escalation

**Cost Optimization Path:**
1. ✅ **Gemini** (Free - Google account)
2. ✅ **Qwen** (Free - if installed)
3. ⚠️ **Codex** (Paid - ChatGPT subscription)
4. ⚠️ **Claude** (Paid - usage limits)

**Expected Savings:** ~50% monthly AI costs (blog proven)

## Execute Free-First Strategy

```bash
echo "💰 Trying free models first..."
echo ""

# Try Gemini first (completely free)
if command -v gemini &> /dev/null; then
  echo "🆓 Using Gemini (free tier)"
  echo "   - 60 requests/min, 1,000 requests/day"
  gemini "$ARGUMENTS"
  exit 0
fi

# Try Qwen if available
if command -v qwen &> /dev/null; then
  echo "🆓 Using Qwen (free tier)"
  qwen "$ARGUMENTS"
  exit 0
fi

# Escalate to paid models
if command -v codex &> /dev/null && codex auth status &>/dev/null; then
  echo "💳 Escalating to Codex (ChatGPT subscription)"
  codex "$ARGUMENTS"
  exit 0
fi

# Final fallback to Claude
echo "💳 Using Claude Code (premium)"
echo ""
echo "💡 Tip: Install free models to save costs:"
echo "   npm install -g @google/gemini-cli"
echo "   gemini login  # Free with Google account!"
echo ""
```

## Installation Guide

**Get free models:**
```bash
# Gemini (Free - Recommended!)
npm install -g @google/gemini-cli
gemini login

# Qwen (Free)
npm install -g qwen-mcp-tool
```

---

**Execute cost-optimized routing for:** $ARGUMENTS
