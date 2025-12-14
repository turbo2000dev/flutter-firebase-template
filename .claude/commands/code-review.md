# Code Review

**Description:** Comprehensive code review of recent changes using the Reviewer agent to ensure quality, standards compliance, and best practices.

---

You are conducting a comprehensive code review of recent changes to ensure they meet quality standards before merging.

## Usage

```bash
/review [optional: specific files or feature to review]
```

## Workflow

### Phase 1: Identify Changes

Determine what needs to be reviewed:

```bash
# Show recent changes
git status

# Show diff of staged changes
git diff --cached

# Or show recent commits
git log --oneline -5
```

Ask the user which changes to review if not specified.

---

### Phase 2: Code Review

Launch the **Reviewer Agent** to conduct the review:

1. First, read the reviewer agent definition:
```
Read .claude/agents/reviewer.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Code review of [CHANGES_DESCRIPTION]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/reviewer.md, then add:
  "Now conduct a comprehensive code review of the following changes: [CHANGES_DESCRIPTION].
  Files to review: [FILE_LIST or FEATURE_NAME]
  Provide your review report following the format specified in your agent definition."
```

**Wait for reviewer agent to complete** and review the report.

---

### Phase 3: Run Automated Checks

Supplement manual review with automated analysis:

```bash
# Static analysis
echo "Running flutter analyze..."
flutter analyze

# Check formatting
echo "Checking code formatting..."
flutter format --dry-run --set-exit-if-changed .

# Run tests
echo "Running tests..."
flutter test

# Check test coverage (excludes generated files)
echo "Checking test coverage..."
flutter test --coverage
python3 scripts/coverage-report.py
```

---

### Phase 4: Security Quick Check

For changes involving sensitive operations, run quick security check:

```bash
# Check for common security issues
echo "Checking for hardcoded secrets..."
grep -r "apiKey.*=" --include="*.dart" lib/ | grep -v "fromEnvironment" || echo "No issues found"

grep -r "password.*=" --include="*.dart" lib/ | grep "\".*\"" || echo "No issues found"

echo "Checking for missing input validation..."
grep -r "\.fromJson" --include="*.dart" lib/ | head -5
```

---

### Phase 5: Review Report

Provide comprehensive review report to user:

```markdown
# Code Review Report

## Review Summary
**Status:** ✓ Approved / ⚠️ Needs Changes / 🚫 Rejected

**Reviewed:** [X files, Y lines changed]

**Issues Found:**
- 🔴 Critical: X
- 🟡 Major: X
- 🟢 Minor: X
- ✅ Observations: X

---

## Critical Issues 🔴

[Issues that MUST be fixed before merge]

### Issue 1: [Title]
**Location:** `file.dart:123`
**Category:** [Security/Performance/Correctness]

**Problem:**
[Description of what's wrong]

**Impact:**
[Why this matters]

**Fix:**
```dart
// Before (bad)
[problematic code]

// After (fixed)
[corrected code]
```

---

## Major Issues 🟡

[Issues that SHOULD be fixed]

---

## Minor Issues 🟢

[Style issues, optimizations, suggestions]

---

## Positive Feedback ✅

- ✓ [Good practice observed]
- ✓ [Well-designed component]
- ✓ [Excellent test coverage]

---

## Code Quality Metrics

### Architecture ✓/⚠️/✗
- Layer separation: [score]
- Dependency direction: [score]
- Feature organization: [score]

### Code Style ✓/⚠️/✗
- Naming conventions: [score]
- Formatting: [score]
- Documentation: [score]

### State Management ✓/⚠️/✗
- Provider usage: [score]
- Immutability: [score]
- Error handling: [score]

### Testing ✓/⚠️/✗
- Coverage: X%
- Test quality: [score]
- Edge cases: [score]

### Security ✓/⚠️/✗
- Input validation: [score]
- Auth/authz: [score]
- Data protection: [score]

### Performance ✓/⚠️/✗
- Widget optimization: [score]
- Memory management: [score]
- Network efficiency: [score]

---

## Automated Checks

```
Flutter Analyze: ✓ Passed / ✗ X issues
Code Format: ✓ Passed / ✗ Needs formatting
Tests: ✓ X/X passed / ✗ X failed
Coverage: X% (target: 80%)
```

---

## Recommendations

### Must Do (Before Merge)
1. [Action item with location]
2. [Action item with location]

### Should Do (This Sprint)
1. [Improvement suggestion]
2. [Refactoring suggestion]

### Consider (Future)
1. [Long-term improvement]
2. [Architecture evolution]

---

## Approval Decision

**Status:** [Approved/Request Changes/Needs Discussion]

**Reasoning:**
[Explanation of decision]

**Next Steps:**
[What should happen next]
```

---

### Phase 6: Address Issues (If Needed)

If critical or major issues found, help developer fix them:

1. For each critical issue, provide specific fix
2. Offer to apply fixes automatically if straightforward
3. Re-run review after fixes applied

---

## Review Checklist

The reviewer agent checks for:

### Architecture
- [ ] Layer separation maintained
- [ ] Dependencies point inward
- [ ] Feature-first organization
- [ ] Repository pattern used correctly

### Code Quality
- [ ] Follows naming conventions
- [ ] Properly formatted
- [ ] Documented where needed
- [ ] No code smells

### State Management
- [ ] Uses @riverpod code generation
- [ ] Immutable state with Freezed
- [ ] Proper AsyncValue handling
- [ ] Appropriate provider types

### Security
- [ ] Input validation present
- [ ] No hardcoded secrets
- [ ] Proper authentication/authorization
- [ ] Sensitive data protected

### Performance
- [ ] Const constructors used
- [ ] Widgets properly split
- [ ] No memory leaks
- [ ] Efficient operations

### Testing
- [ ] Adequate test coverage
- [ ] Tests actually test behavior
- [ ] Edge cases covered
- [ ] Tests pass

### {{TARGET_REGION}}-Specific (if applicable)
- [ ] {{TARGET_REGION}} tax logic separate
- [ ] QPP used (not CPP)
- [ ] Bilingual support
- [ ] {{TARGET_REGION}} regulations respected

---

## When to Use

Use `/review` for:
- Before merging to main/development branch
- After completing a feature
- Before deployment
- When you want quality assurance
- To learn best practices

---

## Advanced Options

```bash
# Quick review (less thorough)
/review --quick

# Focus on specific aspects
/review --security-only
/review --performance-only

# Review specific files
/review src/features/auth/

# Review recent commits
/review --commits HEAD~3..HEAD
```

---

This command ensures code meets quality standards through comprehensive manual and automated review before integration.
