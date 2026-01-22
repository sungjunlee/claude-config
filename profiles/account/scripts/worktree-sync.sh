#!/usr/bin/env bash
# Worktree Sync - Sync environment files across git worktrees
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo, no worktrees, sync failures)

set -euo pipefail

WORKTREES_DIR_NAME=".worktrees"
SYNC_FILES=(.env .env.local package.json)

show_help() {
    cat <<EOF
Worktree Sync - Sync environment files across git worktrees

Usage: $0 [help]
EOF
}

repo_root() {
    git rev-parse --show-toplevel 2>/dev/null
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

sync_worktrees() {
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

    echo "Syncing environment files..."
    echo ""

    local count=0
    local synced=0
    local skipped=0
    local failures=0
    local -a npm_notice=()

    local dir
    while IFS= read -r dir; do
        [[ -z "$dir" ]] && continue
        local name
        name=$(basename "$dir")
        echo "Checking: $name"

        local file
        for file in "${SYNC_FILES[@]}"; do
            local src="$root/$file"
            local dest="$dir/$file"

            if [[ ! -f "$src" ]]; then
                continue
            fi

            # Check if files are identical (handle cmp errors gracefully)
            if [[ -f "$dest" ]]; then
                if cmp -s "$src" "$dest" 2>/dev/null; then
                    echo "  OK  $file is up to date"
                    continue
                fi
                # If cmp fails (not just different), treat as needing update
            fi

            if [[ -e "$dest" ]]; then
                if git -C "$dir" status --porcelain -- "$file" 2>/dev/null | grep -q .; then
                    echo "  SKIP $file differs (local changes)"
                    skipped=$((skipped + 1))
                    continue
                fi
            fi

            mkdir -p "$(dirname "$dest")"
            if cp "$src" "$dest"; then
                echo "  UPD $file updated"
                synced=$((synced + 1))

                if [[ "$file" == "package.json" ]]; then
                    npm_notice+=("$name")
                fi
            else
                echo "  ERR $file: copy failed" >&2
                failures=$((failures + 1))
            fi
        done

        echo ""
        count=$((count + 1))
    done < <(collect_worktrees "$worktrees_dir")

    if [[ $count -eq 0 ]]; then
        echo "No worktrees found"
        echo "Use /wt-distribute to create worktrees first"
        return 1
    fi

    echo "Done. Synced $synced file(s)."
    if [[ $skipped -gt 0 ]]; then
        echo "Skipped $skipped file(s) with local changes."
    fi
    if [[ $failures -gt 0 ]]; then
        echo "Failed to sync $failures file(s)." >&2
    fi
    if [[ ${#npm_notice[@]} -gt 0 ]]; then
        echo "Note: run 'npm install' in ${npm_notice[*]}"
    fi

    [[ $failures -gt 0 ]] && return 1
    return 0
}

main() {
    case "${1:-}" in
        help) show_help ;;
        "")  sync_worktrees ;;
        *)   show_help ;;
    esac
}

main "$@"
