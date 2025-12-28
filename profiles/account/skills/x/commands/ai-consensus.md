---
description: Get multiple AI opinions for critical decisions
---

# Multi-Model Consensus

Gather consensus from multiple AI models: $ARGUMENTS

## Strategy: Diverse Perspectives

**For Critical Decisions:**
1. 🧠 **Gemini**: Broad analysis & creative perspective
2. 💻 **Codex**: Technical implementation view
3. 🎯 **Claude**: Synthesis & final recommendation

**Best For:**
- Architecture decisions
- Technology selection
- Security strategies
- Performance trade-offs
- Complex problem solving

## Execute Consensus Analysis

```bash
echo "🤝 Gathering multi-model consensus..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Gemini's perspective
if command -v gemini &> /dev/null; then
  echo "🧠 GEMINI'S PERSPECTIVE:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  gemini "$ARGUMENTS" | tee /tmp/consensus_gemini.txt
  echo ""
  echo ""
else
  echo "⚠️ Gemini not available (install: npm install -g @google/gemini-cli)"
  echo ""
fi

# Codex's perspective
if command -v codex &> /dev/null && codex auth status &>/dev/null; then
  echo "💻 CODEX'S PERSPECTIVE:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  codex "$ARGUMENTS" | tee /tmp/consensus_codex.txt
  echo ""
  echo ""
else
  echo "⚠️ Codex not available (install: npm install -g @openai/codex@latest)"
  echo ""
fi

# Claude's synthesis
echo "🎯 CLAUDE'S SYNTHESIS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Based on the perspectives above, synthesize:"
echo ""

if [ -f /tmp/consensus_gemini.txt ] || [ -f /tmp/consensus_codex.txt ]; then
  echo "**Gemini's View:**"
  [ -f /tmp/consensus_gemini.txt ] && cat /tmp/consensus_gemini.txt || echo "Not available"
  echo ""
  echo "**Codex's View:**"
  [ -f /tmp/consensus_codex.txt ] && cat /tmp/consensus_codex.txt || echo "Not available"
  echo ""
  echo "**Question:** $ARGUMENTS"
  echo ""
  echo "Please provide:"
  echo "1. Areas of consensus"
  echo "2. Key differences in perspective"
  echo "3. Final balanced recommendation"
else
  echo "No external AI perspectives available. Proceeding with Claude analysis."
  echo ""
  echo "$ARGUMENTS"
fi
```

## Use Cases

**Critical Decision Examples:**
- "Should we use PostgreSQL or MongoDB for this system?"
- "Microservices vs Monolith for our scale?"
- "Which caching strategy: Redis, Memcached, or in-memory?"
- "React vs Vue for our team's skillset?"

## Cleanup

```bash
# Clean up temp files
rm -f /tmp/consensus_*.txt 2>/dev/null
```

---

**Execute consensus analysis for:** $ARGUMENTS
