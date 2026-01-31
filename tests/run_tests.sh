#!/usr/bin/env bash
#
# Run all tests for claude-config
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# Track results
PYTHON_RESULT=0
BATS_RESULT=0

# =============================================================================
# Python tests
# =============================================================================

run_python_tests() {
    log "Running Python tests..."

    if ! command -v pytest &>/dev/null; then
        warn "pytest not installed. Install with: pip install pytest pytest-mock"
        return 1
    fi

    cd "$REPO_DIR"
    if pytest tests/ -v --tb=short; then
        log "Python tests passed!"
        return 0
    else
        error "Python tests failed!"
        return 1
    fi
}

# =============================================================================
# Shell tests (bats)
# =============================================================================

run_bats_tests() {
    log "Running shell tests (bats)..."

    if ! command -v bats &>/dev/null; then
        warn "bats not installed."
        warn "Install with:"
        warn "  macOS: brew install bats-core"
        warn "  Linux: npm install -g bats"
        return 1
    fi

    cd "$REPO_DIR"
    if bats tests/install/*.bats tests/hooks/*.bats; then
        log "Shell tests passed!"
        return 0
    else
        error "Shell tests failed!"
        return 1
    fi
}

# =============================================================================
# Syntax checks
# =============================================================================

run_syntax_checks() {
    log "Running syntax checks..."
    local failed=0

    # Shell scripts
    for script in "$REPO_DIR/install.sh" "$REPO_DIR/scripts/"*.sh; do
        if [ -f "$script" ]; then
            if ! bash -n "$script" 2>/dev/null; then
                error "Syntax error in: $script"
                failed=1
            fi
        fi
    done

    # Python scripts
    for script in "$REPO_DIR/scripts/"*.py "$REPO_DIR/scripts/hooks/"*.py; do
        if [ -f "$script" ]; then
            if ! python3 -m py_compile "$script" 2>/dev/null; then
                error "Syntax error in: $script"
                failed=1
            fi
        fi
    done

    if [ "$failed" -eq 0 ]; then
        log "All syntax checks passed!"
    fi
    return $failed
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo "========================================"
    echo " claude-config Test Suite"
    echo "========================================"
    echo ""

    local exit_code=0

    # Syntax checks (always run)
    if ! run_syntax_checks; then
        exit_code=1
    fi

    echo ""

    # Python tests
    if ! run_python_tests; then
        PYTHON_RESULT=1
        exit_code=1
    fi

    echo ""

    # Bats tests
    if ! run_bats_tests; then
        BATS_RESULT=1
        exit_code=1
    fi

    # Summary
    echo ""
    echo "========================================"
    echo " Summary"
    echo "========================================"
    echo ""

    if [ "$exit_code" -eq 0 ]; then
        log "All tests passed!"
    else
        error "Some tests failed:"
        [ "$PYTHON_RESULT" -ne 0 ] && error "  - Python tests"
        [ "$BATS_RESULT" -ne 0 ] && error "  - Shell tests (bats)"
    fi

    echo ""
    return $exit_code
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
