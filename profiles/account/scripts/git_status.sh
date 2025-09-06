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
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | xargs)
if [ "$CHANGES" -eq 0 ]; then
    echo "   ✨ Clean (no changes)"
else
    # Count different types of changes
    MODIFIED=$(git status --porcelain | grep -c "^ M" || true)
    ADDED=$(git status --porcelain | grep -c "^A" || true)
    DELETED=$(git status --porcelain | grep -c "^ D" || true)
    UNTRACKED=$(git status --porcelain | grep -c "^??" || true)
    
    if [ "$MODIFIED" -gt 0 ]; then echo "   📝 Modified: $MODIFIED file(s)"; fi
    if [ "$ADDED" -gt 0 ]; then echo "   ➕ Added: $ADDED file(s)"; fi
    if [ "$DELETED" -gt 0 ]; then echo "   ➖ Deleted: $DELETED file(s)"; fi
    if [ "$UNTRACKED" -gt 0 ]; then echo "   🆕 Untracked: $UNTRACKED file(s)"; fi
    
    # Show file names if not too many
    if [ "$CHANGES" -le 10 ]; then
        echo ""
        echo "   Files:"
        git status -s | sed 's/^/      /'
    fi
fi

# Recent commits
echo ""
echo "📜 Recent Commits:"
git log --oneline --graph -5 2>/dev/null | sed 's/^/   /' || echo "   No commits yet"

echo ""
echo "────────────────────────────────────────────────────────────────────"
echo ""