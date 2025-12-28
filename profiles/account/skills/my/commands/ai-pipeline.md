---
description: Multi-stage analysis pipeline using specialized models
---

# Analysis Pipeline

Run multi-stage analysis pipeline: $ARGUMENTS

## Pipeline Stages

**Optimized Workflow:**
1. 🔍 **Explore** (Gemini) - Broad context analysis
2. 🔧 **Optimize** (Codex) - Technical implementation
3. 🎯 **Synthesize** (Claude) - Final action plan

**Best For:**
- Large refactoring projects
- Security audits
- Performance optimization
- System modernization
- Complex migrations

## Execute Pipeline

```bash
# Parse arguments
if [ -z "$1" ]; then
  echo "❌ Usage: /ai:pipeline <file_or_topic> <task_description>"
  echo ""
  echo "Examples:"
  echo "  /ai:pipeline auth.py 'security audit'"
  echo "  /ai:pipeline microservices 'performance optimization'"
  exit 1
fi

TARGET="$1"
TASK="${2:-analysis}"
FULL_ARGS="$ARGUMENTS"

echo "🔄 Starting Multi-Stage Analysis Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 Target: $TARGET"
echo "🎯 Task: $TASK"
echo ""

# Stage 1: Gemini for broad analysis
if command -v gemini &> /dev/null; then
  echo "📊 STAGE 1: BROAD ANALYSIS (Gemini)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  gemini "Analyze $TARGET for $TASK. Provide comprehensive overview." | tee /tmp/pipeline_gemini.txt
  echo ""
  echo ""
else
  echo "⚠️ Stage 1 skipped (Gemini not installed)"
  echo ""
fi

# Stage 2: Codex for technical optimization
if command -v codex &> /dev/null && codex auth status &>/dev/null; then
  echo "⚙️ STAGE 2: TECHNICAL OPTIMIZATION (Codex)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ -f /tmp/pipeline_gemini.txt ]; then
    codex "Based on this analysis: $(cat /tmp/pipeline_gemini.txt), provide technical optimization for $TARGET focusing on $TASK" | tee /tmp/pipeline_codex.txt
  else
    codex "Provide technical optimization for $TARGET focusing on $TASK" | tee /tmp/pipeline_codex.txt
  fi
  echo ""
  echo ""
else
  echo "⚠️ Stage 2 skipped (Codex not installed/authenticated)"
  echo ""
fi

# Stage 3: Claude synthesis and action plan
echo "🎯 STAGE 3: SYNTHESIS & ACTION PLAN (Claude)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f /tmp/pipeline_gemini.txt ] || [ -f /tmp/pipeline_codex.txt ]; then
  echo "**Pipeline Context:**"
  echo ""

  if [ -f /tmp/pipeline_gemini.txt ]; then
    echo "**Gemini's Broad Analysis:**"
    cat /tmp/pipeline_gemini.txt
    echo ""
  fi

  if [ -f /tmp/pipeline_codex.txt ]; then
    echo "**Codex's Technical View:**"
    cat /tmp/pipeline_codex.txt
    echo ""
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Based on the above pipeline analysis, create:"
  echo "1. Summary of key findings"
  echo "2. Prioritized action items"
  echo "3. Implementation roadmap for: $FULL_ARGS"
else
  echo "No pipeline stages completed. Running direct analysis."
  echo ""
  echo "Analyze and create action plan for: $FULL_ARGS"
fi
```

## Cleanup

```bash
# Clean up temp files
rm -f /tmp/pipeline_*.txt 2>/dev/null
```

## Example Usage

```bash
# Security audit
/ai:pipeline auth_system.py "security vulnerabilities"

# Performance optimization
/ai:pipeline api/ "performance bottlenecks"

# Code modernization
/ai:pipeline legacy_code "migration to Python 3.12"

# Architecture review
/ai:pipeline microservices "scalability analysis"
```

---

**Execute pipeline for:** $ARGUMENTS
