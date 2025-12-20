# Coverage Quick Reference

## 🚀 Quick Commands

```bash
# Run tests with coverage
flutter test --coverage

# View coverage summary
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Check specific coverage
lcov --list coverage/lcov.info | grep "features/projections"
```

## 📊 Current Status

```
Overall Coverage: ~69% (Target: 80%)

Priority Areas:
🔴 Projections: 45% → Need 95%+ (CRITICAL)
🔴 Reports:     52% → Need 80%+
🟡 Assets:      78% → Need 85%+
✅ Auth:        92% (Excellent!)
✅ Projects:    81% (Good!)
```

## 🎯 Coverage Standards

| Area | Target | Priority |
|------|--------|----------|
| **Tax Calculations** | 100% | 🔴 Critical |
| **Projection Engine** | 100% | 🔴 Critical |
| **Data Persistence** | 95% | 🟠 High |
| **Business Logic** | 90% | 🟠 High |
| **Repositories** | 85% | 🟡 Medium |
| **UI Widgets** | 70% | 🟢 Low |

## 📍 Codecov Access

- **Dashboard**: https://app.codecov.io/gh/{{GITHUB_USERNAME}}/{{PROJECT_NAME}}
- **Setup**: Add `CODECOV_TOKEN` to GitHub Secrets
- **Token**: Get from Codecov Settings → General

## ✅ PR Checklist

Before merging:
- [ ] Coverage did not decrease
- [ ] New code is 80%+ covered
- [ ] Critical paths are tested
- [ ] Codecov PR comment reviewed

## 🔍 Find Untested Code

```bash
# Files with < 80% coverage
lcov --summary coverage/lcov.info | awk -F'[|%]' '$2 < 80'

# Specific feature coverage
lcov --list coverage/lcov.info | grep "features/projections"

# Lines covered vs total
lcov --summary coverage/lcov.info | grep "lines"
```

## 📈 Weekly Goals

Week by week improvement plan:

```
Week 1: Projections 45% → 60% (+15%)
Week 2: Projections 60% → 75% (+15%)
Week 3: Projections 75% → 90% (+15%)
Week 4: Projections 90% → 95% (+5%)
Week 5: Reports 52% → 70% (+18%)
Week 6: Reports 70% → 80% (+10%)
Week 7: Assets 78% → 85% (+7%)
Week 8: Maintain & improve
```

## 🚨 Coverage Dropped? Fix It!

```bash
# 1. See what changed
git diff main...HEAD coverage/lcov.info

# 2. Find untested files
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 3. Add tests for red lines
# Create test file: test/path/to/file_test.dart

# 4. Verify improvement
flutter test --coverage
lcov --summary coverage/lcov.info
```

## 📚 Full Guide

See `docs/testing/codecov-guide.md` for complete documentation.
