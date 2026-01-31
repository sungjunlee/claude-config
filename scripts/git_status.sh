#!/usr/bin/env bash
# Display git project status when Claude Code session starts
# Shows current branch, status, and recent commits

set -euo pipefail

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "[Project Context] Not a git repository"
    exit 0
fi

echo "════════════════════════════════════════════════════════════════════"
echo " 📁 Project: $(basename "$(git rev-parse --show-toplevel)")"
echo "════════════════════════════════════════════════════════════════════"

# Current branch and tracking info
echo ""
echo "🌿 Branch: $(git branch --show-current || echo 'detached HEAD')"

# Check if branch tracks a remote
if git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        echo "   Status: ✅ Up to date with remote"
    elif [ "$LOCAL" = "$BASE" ]; then
        BEHIND=$(git rev-list --count @..@{u})
        echo "   Status: ⬇️  Behind by $BEHIND commit(s)"
    elif [ "$REMOTE" = "$BASE" ]; then
        AHEAD=$(git rev-list --count @{u}..@)
        echo "   Status: ⬆️  Ahead by $AHEAD commit(s)"
    else
        AHEAD=$(git rev-list --count @{u}..@)
        BEHIND=$(git rev-list --count @..@{u})
        echo "   Status: 🔄 Diverged (ahead $AHEAD, behind $BEHIND)"
    fi
else
    echo "   Status: 📍 Local branch (no remote tracking)"
fi

# Working directory status
echo ""
echo "📊 Working Directory:"
status_ok=true
if ! STATUS_OUTPUT=$(git status --porcelain 2>&1); then
    status_ok=false
    first_line=$(echo "$STATUS_OUTPUT" | head -n 1)
    echo "   ⚠️  Unable to check git status: ${first_line:-unknown error}"
else
    CHANGES=$(echo -n "$STATUS_OUTPUT" | grep -c '^' || true)
fi

if [ "$status_ok" = true ]; then
    if [ "$CHANGES" -eq 0 ]; then
        echo "   ✨ Clean (no changes)"
    else
        # Count different types of changes
        MODIFIED=$(echo "$STATUS_OUTPUT" | grep -c "^ M" || true)
        ADDED=$(echo "$STATUS_OUTPUT" | grep -c "^A" || true)
        DELETED=$(echo "$STATUS_OUTPUT" | grep -c "^ D" || true)
        UNTRACKED=$(echo "$STATUS_OUTPUT" | grep -c "^??" || true)
        
        if [ "$MODIFIED" -gt 0 ]; then echo "   📝 Modified: $MODIFIED file(s)"; fi
        if [ "$ADDED" -gt 0 ]; then echo "   ➕ Added: $ADDED file(s)"; fi
        if [ "$DELETED" -gt 0 ]; then echo "   ➖ Deleted: $DELETED file(s)"; fi
        if [ "$UNTRACKED" -gt 0 ]; then echo "   🆕 Untracked: $UNTRACKED file(s)"; fi
        
        # Show file names if not too many
        if [ "$CHANGES" -le 10 ]; then
            echo ""
            echo "   Files:"
            echo "$STATUS_OUTPUT" | sed 's/^/      /'
        fi
    fi
fi

# Recent commits
echo ""
echo "📜 Recent Commits:"
if ! git log --oneline --graph -5 2>/dev/null | sed 's/^/   /'; then
    if ! git rev-parse HEAD >/dev/null 2>&1; then
         echo "   (No commits yet)"
    else
         echo "   ⚠️  Error listing commits"
    fi
fi

echo ""
echo "────────────────────────────────────────────────────────────────────"
echo ""
