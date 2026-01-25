---
description: Use Gemini for large file analysis (Google account required)
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
  echo "🔐 Login:"
  echo "   gemini login"
  echo ""
  echo "✅ Login required (no API key needed)"
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

**Notes:**
- Large context window
- No API key needed

## Execute Gemini Analysis

```bash
echo "🧠 Analyzing with Gemini..."
gemini "$ARGUMENTS"
```

## Fallback

If Gemini is not available, Claude will handle the request directly.

---

**Run Gemini analysis for:** $ARGUMENTS
