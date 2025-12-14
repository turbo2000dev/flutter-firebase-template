# Test Audit

**Description:** Comprehensive test audit using the Tester agent to evaluate test coverage, test quality, and adherence to QA best practices.

---

You are conducting a test audit of the application to evaluate test coverage, test quality, and compliance with QA best practices defined in the project.

## Usage

```bash
/test-audit [optional: specific feature or files to audit]
```

## Workflow

### Phase 1: Scope Definition

Determine audit scope:

**Full Application Audit:**
- All test files across features
- Overall coverage analysis
- Test quality assessment
- QA best practices compliance

**Feature-Specific Audit:**
- Focused on specific feature tests
- Related test coverage
- Feature-specific test quality

Ask user for scope if not specified.

---

### Phase 2: Test Audit

Launch the **Tester Agent** to conduct comprehensive audit:

1. First, read the tester agent definition:
```
Read .claude/agents/tester.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Test audit of [SCOPE]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/tester.md, then add:
  "Now conduct a comprehensive TEST AUDIT (not implementation) of [SCOPE].

  This is an AUDIT - do NOT write new tests. Instead, EVALUATE:

  1. **Coverage Analysis:**
     - Run flutter test --coverage
     - Analyze coverage against targets (80% overall, 95% domain, 90% data, 70% presentation)
     - Identify untested code paths
     - Find critical paths without 100% coverage

  2. **Test Quality Assessment:**
     - Review test file structure and organization
     - Check for AAA pattern (Arrange-Act-Assert)
     - Verify test independence (no shared mutable state)
     - Check for descriptive test names
     - Look for test smells (flaky tests, slow tests, tests with no assertions)
     - Verify proper use of mocks (mocktail)
     - Check for edge case coverage

  3. **Test Pyramid Compliance:**
     - Unit tests: Should be ~50% of tests
     - Widget tests: Should be ~30% of tests
     - Integration tests: Should be ~15% of tests
     - E2E tests: Should be ~5% of tests

  4. **Best Practices Compliance:**
     - Proper test fixtures and factories
     - No hardcoded test data that could become stale
     - Proper setup/tearDown usage
     - No tests depending on execution order
     - Proper async test handling
     - Riverpod provider testing patterns
     - Freezed entity testing patterns

  5. **Critical Path Coverage:**
     - Authentication flows tested
     - Financial calculations tested (if applicable)
     - Data persistence tested
     - Error handling tested

  Provide your detailed test audit report following the format below.
  Scope: [SCOPE_DESCRIPTION]"
```

**Wait for tester agent to complete** and review the audit report.

---

### Phase 3: Automated Test Checks

Run automated test analysis:

```bash
echo "=== Automated Test Checks ==="

# 1. Run tests and check for failures
echo -e "\n1. Running all tests..."
flutter test 2>&1 | tail -20

# 2. Generate and analyze coverage (EXCLUDING GENERATED FILES)
echo -e "\n2. Analyzing test coverage (excluding .g.dart and .freezed.dart)..."
flutter test --coverage
python3 scripts/coverage-report.py

# 3. Count tests by type
echo -e "\n3. Test distribution..."
echo "Unit tests (domain/data):"
find test -name "*_test.dart" -path "*/domain/*" -o -name "*_test.dart" -path "*/data/*" | wc -l | xargs echo "  Count:"

echo "Widget tests (presentation):"
find test -name "*_test.dart" -path "*/presentation/*" -o -name "*_test.dart" -path "*/widgets/*" | wc -l | xargs echo "  Count:"

echo "Integration tests:"
find integration_test -name "*_test.dart" 2>/dev/null | wc -l | xargs echo "  Count:"

# 4. Check for test smells
echo -e "\n4. Checking for test smells..."

echo "Tests without assertions:"
grep -r "test(" --include="*_test.dart" test/ -A 20 | grep -B 20 "});" | grep -L "expect\|verify" | head -5 || echo "  None found"

echo "Tests with sleep/delay (potential flakiness):"
grep -r "Future.delayed\|sleep\|Duration(" --include="*_test.dart" test/ | wc -l | xargs echo "  Count:"

echo "Tests without proper group organization:"
find test -name "*_test.dart" -exec grep -L "group(" {} \; | head -5

# 5. Check for missing test files
echo -e "\n5. Checking for missing tests..."
echo "Source files without corresponding test files:"
for f in $(find lib/features -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" | head -20); do
  testfile=$(echo "$f" | sed 's|lib/|test/|' | sed 's|\.dart$|_test.dart|')
  if [ ! -f "$testfile" ]; then
    echo "  Missing: $testfile"
  fi
done | head -10

# 6. Check for proper mocking
echo -e "\n6. Checking mock usage..."
grep -r "Mock" --include="*_test.dart" test/ | wc -l | xargs echo "Mock classes found:"
grep -r "when(" --include="*_test.dart" test/ | wc -l | xargs echo "Mock setups (when) found:"
grep -r "verify(" --include="*_test.dart" test/ | wc -l | xargs echo "Mock verifications found:"

echo -e "\n=== Test Checks Complete ===\n"
```

**IMPORTANT:** Always use `scripts/coverage-report.py` for accurate coverage metrics.
The script excludes generated files (.g.dart, .freezed.dart) which should NOT be counted.

---

### Phase 4: Test Audit Report

Provide comprehensive test audit report to user:

```markdown
# Test Audit Report

## Executive Summary

**Test Health:** 🔴 Critical Issues / 🟡 Needs Improvement / 🟢 Good / ✅ Excellent

**Audit Scope:** [Description of what was audited]

**Overall Assessment:**
- Test Coverage: X% (Target: 80%)
- Test Quality: 🟢/🟡/🔴
- Best Practices: 🟢/🟡/🔴
- Critical Paths: 🟢/🟡/🔴

**Issues Found:**
- 🔴 Critical: X (Must fix immediately)
- 🟡 Major: X (Fix soon)
- 🟢 Minor: X (Nice to fix)
- ℹ️ Suggestions: X (Improvements)

---

## Coverage Analysis

### Overall Coverage

| Layer | Current | Target | Status |
|-------|---------|--------|--------|
| Overall | X% | 80% | 🟢/🟡/🔴 |
| Domain | X% | 95% | 🟢/🟡/🔴 |
| Data | X% | 90% | 🟢/🟡/🔴 |
| Application | X% | 85% | 🟢/🟡/🔴 |
| Presentation | X% | 70% | 🟢/🟡/🔴 |

### Critical Paths Coverage

| Critical Path | Coverage | Status |
|--------------|----------|--------|
| Authentication | X% | 🟢/🟡/🔴 |
| Financial Calculations | X% | 🟢/🟡/🔴 |
| Data Persistence | X% | 🟢/🟡/🔴 |
| Error Handling | X% | 🟢/🟡/🔴 |

### Untested Code

**High Priority (Critical paths without tests):**
```
[List of critical files/functions without tests]
```

**Medium Priority (Important logic untested):**
```
[List of important files/functions without tests]
```

---

## Test Pyramid Analysis

### Current Distribution

```
Target vs Actual:

Unit Tests:        [████████████░░░░] 50% target | X% actual
Widget Tests:      [██████████░░░░░░] 30% target | X% actual
Integration Tests: [████░░░░░░░░░░░░] 15% target | X% actual
E2E Tests:         [██░░░░░░░░░░░░░░]  5% target | X% actual
```

**Assessment:** 🟢 Balanced / 🟡 Skewed / 🔴 Inverted pyramid

**Issues:**
- [e.g., "Too many integration tests, not enough unit tests"]
- [e.g., "No E2E tests for critical user journeys"]

---

## Test Quality Assessment

### Test Structure

| Criterion | Status | Notes |
|-----------|--------|-------|
| AAA Pattern | 🟢/🟡/🔴 | [Notes] |
| Test Independence | 🟢/🟡/🔴 | [Notes] |
| Descriptive Names | 🟢/🟡/🔴 | [Notes] |
| Proper Grouping | 🟢/🟡/🔴 | [Notes] |
| Setup/TearDown | 🟢/🟡/🔴 | [Notes] |

### Test Smells Found

#### 🔴 Critical Issues

**1. [Issue Title]**
- **Location:** `test/path/to/test_file.dart`
- **Problem:** [Description]
- **Impact:** [Why this matters]
- **Fix:** [How to fix]

#### 🟡 Major Issues

[List major issues]

#### 🟢 Minor Issues

[List minor issues]

### Common Patterns Found

**Good Patterns ✅:**
- [Good pattern observed]
- [Good pattern observed]

**Anti-Patterns ❌:**
- [Anti-pattern found]
- [Anti-pattern found]

---

## Best Practices Compliance

### Riverpod Testing

| Practice | Status | Notes |
|----------|--------|-------|
| ProviderContainer usage | 🟢/🟡/🔴 | [Notes] |
| Provider overrides | 🟢/🟡/🔴 | [Notes] |
| Async provider testing | 🟢/🟡/🔴 | [Notes] |
| State verification | 🟢/🟡/🔴 | [Notes] |

### Mocking (Mocktail)

| Practice | Status | Notes |
|----------|--------|-------|
| Mock class definitions | 🟢/🟡/🔴 | [Notes] |
| when() setup | 🟢/🟡/🔴 | [Notes] |
| verify() usage | 🟢/🟡/🔴 | [Notes] |
| Mock reset in tearDown | 🟢/🟡/🔴 | [Notes] |

### Freezed Entity Testing

| Practice | Status | Notes |
|----------|--------|-------|
| Constructor tests | 🟢/🟡/🔴 | [Notes] |
| copyWith tests | 🟢/🟡/🔴 | [Notes] |
| Serialization tests | 🟢/🟡/🔴 | [Notes] |
| Equality tests | 🟢/🟡/🔴 | [Notes] |

### Test Data Management

| Practice | Status | Notes |
|----------|--------|-------|
| Test fixtures | 🟢/🟡/🔴 | [Notes] |
| Factory methods | 🟢/🟡/🔴 | [Notes] |
| No hardcoded data | 🟢/🟡/🔴 | [Notes] |
| Faker usage | 🟢/🟡/🔴 | [Notes] |

---

## Flaky Test Analysis

**Potentially Flaky Tests:**

| Test | Location | Risk | Reason |
|------|----------|------|--------|
| [Test name] | `path/to/test.dart:line` | High/Med/Low | [Why it might be flaky] |

**Recommendations to reduce flakiness:**
1. [Recommendation]
2. [Recommendation]

---

## Automated Checks Results

```
Test Execution: ✓ All passing / ✗ X failing
Coverage Report: ✓ Generated / ⚠️ Issues
Test Smells: X found
Missing Tests: X files without tests
Mock Usage: ✓ Proper / ⚠️ Issues
```

---

## Remediation Plan

### Immediate Actions (Critical)

1. **[Action]**
   - Priority: Critical
   - Effort: [Low/Medium/High]
   - Files: [Affected files]

2. **[Action]**
   - Priority: Critical
   - Effort: [Low/Medium/High]
   - Files: [Affected files]

### Short-term Actions (This Sprint)

1. **[Action]**
   - Priority: High
   - Effort: [Low/Medium/High]

### Long-term Improvements

1. **[Action]**
   - Priority: Medium
   - Effort: [Low/Medium/High]

---

## Positive Findings ✅

- ✓ [Good practice observed]
- ✓ [Well-tested component]
- ✓ [Excellent coverage in area]

---

## Recommendations

### Process Improvements

1. [Recommendation for testing process]
2. [Recommendation for CI/CD]

### Technical Improvements

1. [Technical testing enhancement]
2. [Test infrastructure improvement]

### Training Needs

1. [Testing skill to develop]
2. [Best practice to adopt]

---

## Re-audit Trigger

**Schedule next audit:** [When to re-audit]

**Re-audit if:**
- Coverage drops below 75%
- New critical feature added
- Major refactoring completed
- Test failures increase

---

## Appendix

### Coverage by Feature

| Feature | Coverage | Tests | Status |
|---------|----------|-------|--------|
| auth | X% | X tests | 🟢/🟡/🔴 |
| projects | X% | X tests | 🟢/🟡/🔴 |
| projections | X% | X tests | 🟢/🟡/🔴 |
| [etc.] | X% | X tests | 🟢/🟡/🔴 |

### Test File Inventory

```
Total test files: X
Unit tests: X files
Widget tests: X files
Integration tests: X files

Test lines of code: X
Production lines of code: X
Test-to-code ratio: X:1
```

```

---

### Phase 5: Remediation Assistance

If issues found, offer to help fix them:

1. For critical coverage gaps, offer to write missing tests
2. For test quality issues, provide refactored examples
3. For best practice violations, show correct patterns
4. Offer to re-run audit after fixes applied

---

## When to Use

Use `/test-audit` for:
- Before major releases
- After implementing new features (to verify test coverage)
- Periodically (monthly/quarterly) for quality assurance
- When test failures increase
- After refactoring
- When onboarding new team members (to assess test quality)
- Before code reviews of test files

---

## Audit Scope Options

```bash
# Full application audit
/test-audit

# Feature-specific audit
/test-audit features/auth
/test-audit features/projections

# Focus on specific aspects
/test-audit --coverage-only
/test-audit --quality-only
/test-audit --best-practices-only

# Quick audit (less thorough)
/test-audit --quick
```

---

## Test Quality Standards

The audit checks against these standards:

### Coverage Targets
- **Overall:** ≥80%
- **Domain Layer:** ≥95%
- **Data Layer:** ≥90%
- **Application Layer:** ≥85%
- **Presentation Layer:** ≥70%
- **Critical Paths:** 100%

### Test Pyramid Targets
- **Unit Tests:** ~50%
- **Widget Tests:** ~30%
- **Integration Tests:** ~15%
- **E2E Tests:** ~5%

### Quality Checklist
- [ ] Clear, descriptive test names
- [ ] AAA pattern (Arrange-Act-Assert)
- [ ] Independent tests (no shared state)
- [ ] Deterministic (no flaky tests)
- [ ] Fast execution (unit tests < 1s each)
- [ ] Proper mocking (no real network/DB calls)
- [ ] Edge cases covered
- [ ] Error scenarios tested
- [ ] Meaningful assertions
- [ ] Proper setup/tearDown

---

This command ensures your test suite is healthy, comprehensive, and follows QA best practices to maintain confidence in your codebase.
