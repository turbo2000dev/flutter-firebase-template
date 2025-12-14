# Code Quality Guidelines

This document outlines the code quality standards and automated checks for this project.

---

## Automated Quality Checks

This project uses **Git hooks** to automatically enforce code quality standards.

### Git Hooks

Three hooks are configured:

1. **pre-commit**: Runs before every commit
   - ✅ Formats code with `dart format`
   - ✅ Runs static analysis with `flutter analyze`
   - ✅ Runs tests if test files changed

2. **pre-push**: Runs before pushing to remote
   - ✅ Runs full test suite
   - ✅ Checks test coverage (warns if < 80%)
   - ✅ Confirms push to main branch

3. **commit-msg**: Validates commit message format
   - ✅ Enforces Conventional Commits format
   - ✅ Checks message length (≤ 72 chars)
   - ✅ Validates capitalization

---

## Setup

### One-Time Setup

Run this script to configure Git hooks:

```bash
./scripts/setup-git-hooks.sh
```

This will:
- Make all hooks executable
- Configure Git to use `.githooks` directory
- Display active hooks

### Verify Setup

```bash
git config core.hooksPath
# Should output: .githooks
```

---

## Manual Quality Checks

### Format Code

Format all Dart files:

```bash
dart format .
```

Or use the helper script:

```bash
./scripts/format-code.sh
```

This script:
1. Formats all Dart files
2. Applies auto-fixes (`dart fix --apply`)
3. Runs static analysis

### Run Analysis

Check for code issues:

```bash
flutter analyze
```

### Run Tests

Run all tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

### Comprehensive Check

Run all quality checks at once:

```bash
./scripts/check-code-quality.sh
```

This runs:
- ✅ Formatting check
- ✅ Static analysis
- ✅ All tests
- ✅ Coverage calculation
- ✅ Dependency audit
- ✅ Generated files check

---

## Commit Message Format

This project uses **Conventional Commits** format.

### Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add Google sign-in` |
| `fix` | Bug fix | `fix(dashboard): resolve loading state` |
| `docs` | Documentation | `docs: update README` |
| `style` | Code style/formatting | `style: format all files` |
| `refactor` | Code refactoring | `refactor(api): simplify error handling` |
| `test` | Tests | `test(calculator): add edge cases` |
| `chore` | Maintenance | `chore: update dependencies` |
| `perf` | Performance | `perf(query): optimize database calls` |
| `ci` | CI/CD changes | `ci: add code coverage check` |
| `build` | Build system | `build: update Flutter to 3.35.7` |
| `revert` | Revert commit | `revert: undo feature X` |

### Rules

1. **Subject line**: ≤ 72 characters
2. **Lowercase**: Subject should be lowercase after colon
3. **No period**: Don't end subject with a period
4. **Imperative mood**: Use "add" not "added" or "adds"

### Good Examples

```
feat(wizard): add 4-step project creation flow
fix(auth): prevent duplicate sign-in attempts
docs(setup): add Firebase configuration guide
test(projection): increase coverage to 95%
chore: upgrade Riverpod to 3.0
```

### Bad Examples

```
❌ Added new feature              # No type
❌ feat: Add feature              # Capital letter after colon
❌ feat(auth): added signin.      # Past tense + period
❌ updated stuff                  # Vague, no type
```

---

## Code Standards

### Formatting

- **Line length**: 80 characters (enforced by `dart format`)
- **Trailing commas**: Always use for better formatting
- **Quotes**: Prefer single quotes

### Naming

- **Classes/Types**: PascalCase (`UserProfile`)
- **Variables/Functions**: camelCase (`userName`)
- **Constants**: lowerCamelCase (`maxRetryAttempts`)
- **Private members**: Underscore prefix (`_privateField`)
- **Files**: snake_case (`user_profile.dart`)

### Best Practices

1. **Always use const**: Where possible
2. **Prefer final**: Over var
3. **Use trailing commas**: On multi-line structures
4. **Document public APIs**: Use dartdoc comments
5. **Avoid print**: Use proper logging
6. **Test coverage**: Aim for ≥80% overall

---

## CI/CD Integration

GitHub Actions automatically runs these checks on every push:

1. ✅ Code formatting (`dart format --set-exit-if-changed`)
2. ✅ Static analysis (`flutter analyze`)
3. ✅ All tests (`flutter test`)
4. ✅ Test coverage report
5. ✅ Build verification (Android, iOS, Web)

**All checks must pass before code can be merged.**

---

## Skipping Hooks

**Not recommended**, but you can skip hooks if needed:

```bash
# Skip pre-commit hook
git commit --no-verify

# Skip pre-push hook
git push --no-verify
```

**Warning**: Skipping hooks may cause CI/CD failures. Only use in emergencies.

---

## Testing Standards

### Coverage Targets

| Layer | Target | Criticality |
|-------|--------|-------------|
| Overall | ≥80% | Required |
| Calculators | 100% | Critical |
| Domain | ≥95% | High |
| Data | ≥90% | High |
| Presentation | ≥70% | Medium |

### Test Types

- **Unit tests** (50%): Business logic, calculations
- **Widget tests** (30%): UI components
- **Integration tests** (15%): Feature workflows
- **E2E tests** (5%): Complete user journeys

### Test Organization

```
test/
├── unit/           # Unit tests (business logic)
├── widget/         # Widget tests (UI)
├── integration/    # Integration tests (workflows)
└── fixtures/       # Test data and helpers
```

---

## Troubleshooting

### Hook Not Running

If hooks don't run:

```bash
# Re-run setup
./scripts/setup-git-hooks.sh

# Verify configuration
git config core.hooksPath

# Check permissions
ls -la .githooks
```

### Tests Failing in Hook

If tests fail during commit:

```bash
# Run tests to see details
flutter test

# Fix failing tests, then commit again
git commit
```

### Formatting Issues

If formatting check fails:

```bash
# Format all files
dart format .

# Re-stage changes
git add .

# Commit again
git commit
```

---

## Quick Reference

```bash
# Setup hooks (one-time)
./scripts/setup-git-hooks.sh

# Format code
./scripts/format-code.sh

# Check quality
./scripts/check-code-quality.sh

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Static analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

---

## Summary

✅ **Automated**: Git hooks enforce quality before commits
✅ **Comprehensive**: Multiple layers of checks
✅ **CI/CD**: GitHub Actions runs same checks
✅ **Conventional**: Standardized commit messages
✅ **Coverage**: Tracked and enforced
✅ **Documentation**: Clear guidelines and examples

Following these standards ensures consistent, high-quality code throughout the project.
