#!/bin/bash
set -euo pipefail

# JavaScript/TypeScript Project Profile Installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing JavaScript/TypeScript project profile...${NC}"

# Create .claude directory structure
mkdir -p "${CLAUDE_DIR}/commands/"{dev,test}

# Copy commands
cp -r "${SCRIPT_DIR}/.claude/commands/"* "${CLAUDE_DIR}/commands/" 2>/dev/null || true

# Detect project type and provide guidance
echo -e "\n${YELLOW}Detecting JavaScript project setup...${NC}"

if [ -f "package.json" ]; then
    echo "✓ Found package.json"
    
    # Check for test runners
    if grep -q "\"test\":" package.json; then
        echo "✓ Test script detected"
    fi
    
    # Check for linters
    if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ]; then
        echo "✓ ESLint configuration found"
    fi
    
    # Check for formatters
    if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
        echo "✓ Prettier configuration found"
    fi
    
    # Check for TypeScript
    if [ -f "tsconfig.json" ]; then
        echo "✓ TypeScript project detected"
    fi
    
    # Check for build tools
    if [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
        echo "✓ Next.js project detected"
    elif [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
        echo "✓ Vite project detected"
    elif [ -f "webpack.config.js" ]; then
        echo "✓ Webpack configuration found"
    fi
else
    echo "⚠ No package.json found - commands may need adjustment"
fi

echo -e "\n${GREEN}JavaScript project profile installed!${NC}"
echo "Available commands:"
echo "  /test     - Smart test runner"
echo "  /lint     - Linting and formatting"
echo "  /bundle   - Build optimization"