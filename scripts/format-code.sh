#!/bin/bash
# Script to format all code and fix auto-fixable issues

set -e

echo "🎨 Formatting and fixing code..."
echo ""

# Step 1: Format all Dart files
echo "Step 1/3: Formatting Dart files..."
dart format .
echo "✅ Formatting complete"
echo ""

# Step 2: Fix auto-fixable issues
echo "Step 2/3: Applying auto-fixes..."
dart fix --apply
echo "✅ Auto-fixes applied"
echo ""

# Step 3: Run analysis
echo "Step 3/3: Running static analysis..."
if flutter analyze; then
    echo "✅ No analysis issues found"
else
    echo "⚠️  Some analysis issues remain"
    echo "Please fix them manually"
    exit 1
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Code formatting and fixes complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run 'git status' to see what changed"
echo ""
