#!/usr/bin/env bash
# Worktree Status - Show status summary for git worktrees
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo, no worktrees)

set -euo pipefail

WORKTREES_DIR_NAME=".worktrees"

show_help() {
    cat <<EOF
Worktree Status - Show status summary for git worktrees

Usage: $0 [help]
EOF
}

repo_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

default_branch() {
    local root="$1"
    local branch=""

    if git -C "$root" show-ref --verify --quiet refs/remotes/origin/HEAD; then
        branch=$(git -C "$root" symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    fi

    if [[ -z "$branch" ]]; then
        for candidate in main master; do
            if git -C "$root" show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
                branch="$candidate"
                break
            fi
        done
    fi

    echo "$branch"
}

collect_worktrees() {
    local worktrees_dir="$1"
    local -a results=()

    shopt -s nullglob
    for dir in "$worktrees_dir"/*/; do
        if [[ -d "$dir" && -e "$dir/.git" ]]; then
            results+=("${dir%/}")
        fi
    done
    shopt -u nullglob

    # Guard against empty array on bash < 4.4
    [[ ${#results[@]} -gt 0 ]] && printf "%s\n" "${results[@]}"
}

status_label() {
    local changes="$1"
    local conflicts="$2"
    local commits="$3"

    if [[ "$conflicts" -gt 0 ]]; then
        echo "CONFLICT"
    elif [[ "$changes" -gt 0 ]]; then
        echo "WIP"
    elif [[ "$commits" -gt 0 ]]; then
        echo "OK"
    else
        echo "NEW"
    fi
}

show_status() {
    local root
    root=$(repo_root) || true

    if [[ -z "$root" ]]; then
        echo "Error: not a git repository"
        return 1
    fi

    local worktrees_dir="$root/$WORKTREES_DIR_NAME"
    if [[ ! -d "$worktrees_dir" ]]; then
        echo "Error: no worktrees directory"
        return 1
    fi

    local base_branch
    base_branch=$(default_branch "$root")
    local base_ref=""
    if [[ -n "$base_branch" ]]; then
        base_ref="origin/$base_branch"
    fi

    echo "================================"
    echo " Worktree Status"
    echo "================================"
    echo ""

    local count=0
    local dir
    while IFS= read -r dir; do
        [[ -z "$dir" ]] && continue
        local name
        name=$(basename "$dir")
        local branch
        branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")
        [[ -z "$branch" ]] && branch="detached"

        local changes
        changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | xargs)
        local conflicts
        conflicts=$(git -C "$dir" diff --name-only --diff-filter=U 2>/dev/null | wc -l | xargs)

        local commits=0
        if [[ -n "$base_ref" ]] && git -C "$dir" rev-parse --verify --quiet "$base_ref" >/dev/null; then
            commits=$(git -C "$dir" rev-list --count "$base_ref"..HEAD 2>/dev/null || echo 0)
        fi

        local last_commit
        last_commit=$(git -C "$dir" log -1 --pretty=%s 2>/dev/null || echo "No commits yet")

        local label
        label=$(status_label "$changes" "$conflicts" "$commits")

        echo "[$label] $name"
        echo "  Branch:  $branch"
        echo "  Changes: $changes file(s)"
        if [[ -n "$base_ref" ]]; then
            echo "  Commits: $commits"
        fi
        echo "  Last:    $last_commit"

        local task_file="$worktrees_dir/tasks/$name.md"
        if [[ -f "$task_file" ]]; then
            echo "  Task:    $task_file"
        fi
        echo ""
        count=$((count + 1))
    done < <(collect_worktrees "$worktrees_dir")

    if [[ $count -eq 0 ]]; then
        echo "No worktrees found"
        echo "Use /wt-distribute to create worktrees first"
        return 1
    fi

    echo "--------------------------------"
    echo "Git Worktree Summary:"
    echo "$count active worktree(s)"
}

main() {
    case "${1:-}" in
        help) show_help ;;
        "")  show_status ;;
        *)   show_help ;;
    esac
}

main "$@"
