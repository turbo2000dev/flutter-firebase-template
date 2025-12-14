#!/bin/bash
# Comprehensive code quality check script

set -e

echo "🔍 Running comprehensive code quality checks..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ERRORS=$((ERRORS + 1))
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Check 1: Formatting
print_section "1. Code Formatting"
if dart format --set-exit-if-changed .; then
    print_success "Code is properly formatted"
else
    print_error "Code needs formatting"
    echo "Run: dart format ."
fi

# Check 2: Static Analysis
print_section "2. Static Analysis"
if flutter analyze; then
    print_success "No analysis issues"
else
    print_error "Analysis issues found"
    echo "Run: flutter analyze"
fi

# Check 3: Tests
print_section "3. Test Suite"
if flutter test; then
    print_success "All tests passed"
else
    print_error "Some tests failed"
    echo "Run: flutter test"
fi

# Check 4: Test Coverage
print_section "4. Test Coverage"
flutter test --coverage > /dev/null 2>&1

if [ -f coverage/lcov.info ]; then
    LINES=$(grep -c "^DA:" coverage/lcov.info || echo 0)
    HIT=$(grep "^DA:" coverage/lcov.info | grep -v ",0" | wc -l || echo 0)

    if [ "$LINES" -gt 0 ]; then
        COVERAGE=$(awk "BEGIN {printf \"%.1f\", ($HIT / $LINES) * 100}")
        echo "Coverage: $COVERAGE%"

        if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
            print_success "Coverage meets 80% threshold"
        else
            print_warning "Coverage below 80% threshold"
            echo "Target: 80%, Actual: $COVERAGE%"
        fi
    fi
else
    print_warning "Coverage report not found"
fi

# Check 5: Dependencies
print_section "5. Dependencies"
echo "Checking for outdated packages..."
flutter pub outdated || true
print_success "Dependency check complete"

# Check 6: Generated Files
print_section "6. Generated Files"
echo "Checking if generated files are up to date..."
flutter pub run build_runner build --delete-conflicting-outputs > /dev/null 2>&1
if git diff --quiet --exit-code; then
    print_success "Generated files are up to date"
else
    print_warning "Generated files have changes"
    echo "Run: flutter pub run build_runner build --delete-conflicting-outputs"
fi

# Summary
print_section "Summary"
if [ $ERRORS -eq 0 ]; then
    print_success "All checks passed! Code is ready to commit."
    exit 0
else
    print_error "$ERRORS check(s) failed"
    echo ""
    echo "Please fix the issues above before committing."
    exit 1
fi
