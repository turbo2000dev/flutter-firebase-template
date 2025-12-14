# Git Hooks

This project uses custom Git hooks to maintain code quality and enforce standards automatically.

## Location

Git hooks are located in `.githooks/` directory and are configured via:
```bash
git config core.hooksPath .githooks
```

## Available Hooks

### 1. Pre-Commit Hook

**Triggers**: Every time you run `git commit`

**Purpose**: Ensures code quality before allowing commits

**What it does**:

#### Step 1: Auto-Format Code ✨
- **Automatically formats all staged Dart files** using `dart format`
- No manual formatting needed - just commit and it's done!
- Formatted files are automatically re-staged
- **Never fails** - always fixes formatting issues

**Example output**:
```
ℹ️  Step 1/3: Auto-formatting code...
ℹ️  Formatting files...
✅ Code auto-formatted and re-staged
```

#### Step 2: Static Analysis
- Runs `flutter analyze --no-pub` on your code
- Checks for potential issues, warnings, and errors
- **Will fail commit** if analysis issues found

**Fix if failed**:
```bash
flutter analyze
dart fix --apply  # Auto-fix some issues
```

#### Step 3: Run Tests (Conditional)
- Runs automatically if test files (`*_test.dart`) were changed
- Can be forced with: `RUN_TESTS=1 git commit`
- **Will fail commit** if tests fail

**Fix if failed**:
```bash
flutter test
```

### 2. Pre-Push Hook

**Triggers**: Every time you run `git push`

**Purpose**: Ensures all tests pass before pushing to remote

**What it does**:

#### Step 1: Run All Tests
- Runs complete test suite with coverage
- Ensures no breaking changes are pushed
- **Will prevent push** if any test fails

**Fix if failed**:
```bash
flutter test
```

#### Step 2: Check Test Coverage
- Calculates test coverage percentage
- Warns if below 80% threshold (but doesn't fail)
- Helps maintain quality standards

#### Step 3: Info Messages
- Provides info about pushing to main branch
- Reminds about weekly feature branch workflow

### 3. Commit Message Hook

**Triggers**: After you write a commit message

**Purpose**: Ensures commit messages follow standards

**Format required**:
```
type(scope): subject

body (optional)

footer (optional)
```

**Valid types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
```bash
# Good
feat(auth): Add Google sign-in support
fix(projections): Fix individual profile not found error
docs(readme): Update installation instructions

# Bad (will be rejected)
updated stuff
WIP
fixed bug
```

## Workflow Example

### Normal Commit Flow

```bash
# 1. Stage your changes
git add lib/my_feature.dart

# 2. Commit (hooks run automatically)
git commit -m "feat(feature): Add new feature"

# Output:
# 🔍 Running pre-commit checks...
# ℹ️  Step 1/3: Auto-formatting code...
# ✅ Code auto-formatted and re-staged
# ℹ️  Step 2/3: Analyzing code...
# ✅ Static analysis: OK
# ⚠️  Step 3/3: Tests skipped (no test files changed)
# ✅ All pre-commit checks passed!

# 3. Push to remote
git push origin main

# Output:
# 🚀 Running pre-push checks...
# ℹ️  Running all tests...
# ✅ All tests passed
# ✅ All pre-push checks passed!
```

### If Formatting Needed

```bash
git add lib/unformatted.dart
git commit -m "feat: Add feature"

# Hook automatically formats and re-stages:
# ℹ️  Step 1/3: Auto-formatting code...
# ℹ️  Formatting files...
# ✅ Code auto-formatted and re-staged
# ✅ All pre-commit checks passed!
```

### If Analysis Fails

```bash
git commit -m "feat: Add feature"

# Output:
# ❌ Static analysis: FAILED
# Please fix the analysis issues before committing.
# Run: flutter analyze

# Fix issues:
flutter analyze
dart fix --apply  # Auto-fix some issues

# Try again:
git commit -m "feat: Add feature"
```

### If Tests Fail

```bash
# Changed test file
git add test/my_test.dart
git commit -m "test: Add new tests"

# Output:
# ❌ Tests: FAILED
# Please fix failing tests before committing.

# Fix tests:
flutter test

# Try again:
git commit -m "test: Add new tests"
```

## Bypassing Hooks (Not Recommended)

In rare cases, you may need to bypass hooks:

```bash
# Skip pre-commit hook
git commit --no-verify -m "message"

# Skip pre-push hook
git push --no-verify
```

**⚠️ Warning**: Only use `--no-verify` when absolutely necessary. Bypassing hooks can lead to:
- Unformatted code being committed
- Broken code being pushed
- CI/CD failures
- Difficult code reviews

## Benefits

### 1. Automatic Code Formatting ✨
- **No more "formatting failed" CI errors**
- No need to remember to run `dart format`
- Consistent code style across the team
- Formatted code is automatically re-staged

### 2. Early Issue Detection
- Catch problems before they reach CI/CD
- Faster feedback loop
- Prevents broken code from being pushed

### 3. Enforced Standards
- Commit message conventions
- Code quality requirements
- Test coverage awareness

### 4. Time Savings
- No waiting for CI/CD to fail
- Fix issues immediately while context is fresh
- Fewer failed PRs

## Troubleshooting

### Hook Not Running

**Check if hooks are configured**:
```bash
git config core.hooksPath
# Should output: .githooks
```

**Fix**:
```bash
git config core.hooksPath .githooks
```

### Hook Permission Denied

**Check permissions**:
```bash
ls -la .githooks/
```

**Fix**:
```bash
chmod +x .githooks/pre-commit
chmod +x .githooks/pre-push
chmod +x .githooks/commit-msg
```

### Format Check Fails

If auto-formatting doesn't seem to work:

**Manual format**:
```bash
dart format .
git add .
git commit -m "style: Format code"
```

### Tests Take Too Long

**Skip tests in pre-commit** (they run in pre-push anyway):
- Don't modify test files
- Or accept the test run as necessary

**Skip tests in pre-push** (not recommended):
```bash
git push --no-verify
```

## Customization

### Disable Test Running on Commit

Edit `.githooks/pre-commit` line 81:
```bash
# Change from:
if [ ! -z "$TEST_FILES" ] || [ "$RUN_TESTS" = "1" ]; then

# To (never run tests on commit):
if [ "$RUN_TESTS" = "1" ]; then
```

### Always Run Tests on Commit

```bash
RUN_TESTS=1 git commit -m "message"
```

### Adjust Coverage Threshold

Edit `.githooks/pre-push` line 62:
```bash
# Change from:
if (( $(echo "$COVERAGE < 80" | bc -l) )); then

# To (e.g., 70%):
if (( $(echo "$COVERAGE < 70" | bc -l) )); then
```

## CI/CD Integration

Git hooks work **in addition to** CI/CD, not instead of:

- **Local (Git Hooks)**: Fast feedback, catches most issues
- **CI/CD (GitHub Actions)**: Final verification, runs on all platforms

**Why both?**:
1. Hooks can be bypassed with `--no-verify`
2. CI/CD runs on clean environment
3. CI/CD tests multiple platforms (iOS, Android, Web)
4. CI/CD provides permanent record
5. CI/CD required for PR approvals

## Best Practices

1. ✅ **Never use `--no-verify`** unless absolutely necessary
2. ✅ **Fix issues immediately** when hooks fail
3. ✅ **Run `flutter test` regularly** during development
4. ✅ **Keep hooks fast** - they run frequently
5. ✅ **Let auto-formatting work** - don't fight it
6. ✅ **Commit often** with working code

## Summary

| Hook | When | Auto-Fix | Can Fail |
|------|------|----------|----------|
| **pre-commit** | On commit | ✅ Formats code | ❌ Analysis<br>❌ Tests (if changed) |
| **pre-push** | On push | ❌ None | ❌ All tests |
| **commit-msg** | After commit message | ❌ None | ❌ Invalid format |

**Key Takeaway**: Just commit and push as normal - the hooks will handle formatting automatically and catch issues early! 🚀

---

**Questions or Issues?**
- Check this documentation
- Review hook output messages
- Run commands manually to debug
- Contact team if hooks consistently fail
