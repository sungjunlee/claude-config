---
description: Use Gemini for large file analysis (Free with Google account)
---

# Gemini Analysis

Analyze with Gemini: $ARGUMENTS

## Prerequisites Check

```bash
if ! command -v gemini &> /dev/null; then
  echo "❌ Gemini CLI not installed"
  echo ""
  echo "📦 Install:"
  echo "   npm install -g @google/gemini-cli"
  echo ""
  echo "🔐 Login (Free!):"
  echo "   gemini login"
  echo ""
  echo "✅ Free Tier:"
  echo "   - 60 requests/minute"
  echo "   - 1,000 requests/day"
  echo "   - No API key needed"
  exit 1
fi

# Ensure using free tier
unset GEMINI_API_KEY
```

## Best Use Cases

**Use Gemini for:**
- 📚 Large codebase analysis (1000+ lines)
- 🏗️ Architecture and system design review
- 💡 Creative brainstorming sessions
- 🔬 Complex mathematical/scientific problems
- 📊 Data analysis and pattern recognition

**Free Tier Benefits:**
- Massive context window (2M tokens)
- No cost with Google account
- 60 requests/min, 1,000 requests/day

## Execute Gemini Analysis

```bash
echo "🧠 Analyzing with Gemini (free tier)..."
gemini "$ARGUMENTS"
```

## Fallback

If Gemini is not available, Claude will handle the request directly.

---

**Run Gemini analysis for:** $ARGUMENTS
