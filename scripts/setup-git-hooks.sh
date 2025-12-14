#!/bin/bash
# Setup script for Git hooks

set -e

echo "🔧 Setting up Git hooks..."
echo ""

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$GIT_ROOT/.githooks"
GIT_HOOKS_DIR="$GIT_ROOT/.git/hooks"

# Check if .githooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ .githooks directory not found"
    exit 1
fi

# Make hooks executable
echo "Making hooks executable..."
chmod +x "$HOOKS_DIR"/*

# Configure git to use .githooks directory
echo "Configuring git to use custom hooks directory..."
git config core.hooksPath "$HOOKS_DIR"

echo ""
echo "✅ Git hooks successfully configured!"
echo ""
echo "Active hooks:"
ls -la "$HOOKS_DIR"
echo ""
echo "These hooks will run automatically:"
echo "  • pre-commit:  Format, analyze, and test before commits"
echo "  • pre-push:    Run full test suite before pushing"
echo "  • commit-msg:  Validate commit message format"
echo ""
echo "To skip hooks (not recommended):"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""
