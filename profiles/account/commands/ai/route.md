---
description: Auto-route to best AI based on task type (70% token savings)
---

# Intelligent Task Routing

Auto-route task to optimal model: $ARGUMENTS

## Routing Logic

**Task-based optimization:**
- Large analysis → Gemini (huge context)
- Algorithm/perf → Codex (coding specialist)
- Debugging → Codex (detailed analysis)
- Quick queries → Gemini (free tier)
- General tasks → Claude (balanced)

**Expected Savings:** ~70% token usage (blog proven)

## Execute Smart Routing

```bash
TASK="$ARGUMENTS"

echo "🎯 Analyzing task type..."
echo ""

# Route based on task keywords
case "$TASK" in

  # Large file/codebase analysis → Gemini
  *analyze*|*large*|*codebase*|*architecture*|*entire*|*full*)
    echo "📊 Task: Large analysis"
    echo "🎯 Routing to: Gemini (massive context window)"
    if command -v gemini &> /dev/null; then
      gemini "$TASK"
    else
      echo "⚠️ Gemini not installed. Using Claude."
      echo "💡 Install: npm install -g @google/gemini-cli"
      echo ""
      echo "Proceeding with Claude: $TASK"
    fi
    ;;

  # Algorithm/optimization → Codex
  *optimize*|*algorithm*|*performance*|*refactor*|*improve*)
    echo "⚙️ Task: Optimization/Algorithm"
    echo "🎯 Routing to: Codex (coding specialist)"
    if command -v codex &> /dev/null && codex auth status &>/dev/null; then
      codex "$TASK"
    else
      echo "⚠️ Codex not available. Using Claude."
      echo "💡 Install: npm install -g @openai/codex@latest"
      echo ""
      echo "Proceeding with Claude: $TASK"
    fi
    ;;

  # Debugging → Codex
  *debug*|*error*|*bug*|*fix*|*issue*|*problem*)
    echo "🐛 Task: Debugging"
    echo "🎯 Routing to: Codex (debugging specialist)"
    if command -v codex &> /dev/null && codex auth status &>/dev/null; then
      codex "Debug and fix: $TASK"
    else
      echo "⚠️ Codex not available. Using Claude."
      echo ""
      echo "Proceeding with Claude: $TASK"
    fi
    ;;

  # Quick questions → Gemini (free!)
  *quick*|*what*|*explain*|*how*|*why*)
    echo "❓ Task: Quick query"
    echo "🎯 Routing to: Gemini (free tier)"
    if command -v gemini &> /dev/null; then
      gemini "$TASK"
    else
      echo "⚠️ Gemini not installed. Using Claude."
      echo ""
      echo "Proceeding with Claude: $TASK"
    fi
    ;;

  # Brainstorming → Gemini
  *brainstorm*|*idea*|*design*|*approach*|*strategy*)
    echo "💡 Task: Brainstorming"
    echo "🎯 Routing to: Gemini (creative analysis)"
    if command -v gemini &> /dev/null; then
      gemini "$TASK"
    else
      echo "⚠️ Gemini not installed. Using Claude."
      echo ""
      echo "Proceeding with Claude: $TASK"
    fi
    ;;

  # Default → Claude
  *)
    echo "📝 Task: General"
    echo "🎯 Using: Claude Code (balanced)"
    echo ""
    echo "$TASK"
    ;;
esac
```

## Quick Setup

**Install free models for auto-routing:**
```bash
npm install -g @google/gemini-cli
gemini login  # Free!
```

**Install Codex (ChatGPT Plus/Pro):**
```bash
npm install -g @openai/codex@latest
codex auth login
```

---

**Execute intelligent routing for:** $ARGUMENTS
