# Weekly Development Workflow

## Overview

This document defines the weekly development workflow for the {{project_type}} planning app. Each week of development follows a structured Git branching and merging strategy to ensure code quality and proper integration.

## Weekly Cycle

### Week Structure

Each development week follows this pattern:

```
Monday          → Create weekly branch from dev (/start-dev)
Monday-Thursday → Development work with daily commits
Friday          → Testing, cleanup, and weekly checkpoint commit
Friday EOD      → Create PR and merge to dev (/start-pr)
After merge     → Promote to staging/main/prod as needed (/promote)
```

## Git Workflow

### 1. Start of Week (Monday)

**Create a new weekly branch from dev:**

```bash
# Recommended: Use the /start-dev command
/start-dev tax-calculator

# Or manually:
# Update dev branch
git checkout dev
git pull origin dev

# Create weekly branch (format: feature/YYYY-WW-description)
git checkout -b feature/2024-45-tax-calculator

# Push branch to remote
git push -u origin feature/2024-45-tax-calculator
```

**Branch Naming Convention:**
```
dev/<year>-<week-number>-<brief-description>
```

**Examples:**
```
feature/2024-45-tax-calculator
feature/2024-46-asset-management
feature/2024-47-scenario-comparison
```

### 2. During the Week (Monday-Thursday)

**Daily development workflow:**

```bash
# Make changes and develop features
# ... code development ...

# Commit regularly after completing logical units of work
git add <files>
git commit -m "feat(scope): description

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to remote daily
git push origin feature/2024-45-tax-calculator
```

**Commit Frequency:**
- After completing each layer (domain, data, application, presentation)
- After running code generation
- After writing tests
- After fixing issues from code review
- At end of each day

### 3. End of Week (Friday)

**Step 1: Final Quality Checks**

Run all quality checks before creating the weekly checkpoint:

```bash
# 1. Format code
flutter format .

# 2. Run static analysis
flutter analyze

# 3. Apply auto-fixes
dart fix --apply

# 4. Run all tests
flutter test

# 5. Check test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Requirements:**
- ✅ `flutter analyze` shows "No issues found!"
- ✅ All tests passing (100%)
- ✅ Test coverage ≥80% overall
- ✅ Test coverage 100% on critical components (calculators, data layer)

**Step 2: Create Weekly Checkpoint Commit**

```bash
git add .
git commit -m "$(cat <<'EOF'
Week <number>: <Brief summary of work completed>

Completed:
- <Feature/component 1>
- <Feature/component 2>
- <Feature/component 3>

Tests: <X>/<X> passing (100%)
Coverage: <X>% overall, 100% on [critical components]

Quality Checks:
✅ flutter analyze - No issues found
✅ flutter test - All passing
✅ dart fix - Applied
✅ Code formatted

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Example:**
```bash
git add .
git commit -m "$(cat <<'EOF'
Week 45: Tax Calculator Implementation

Completed:
- TaxCalculator with federal and {{TARGET_REGION}} provincial tax calculations
- Progressive tax brackets with income-tested credits
- 2024 CRA/Revenu Québec tax data
- Comprehensive test suite (30 tests)
- Integration with projection engine

Tests: 130/130 passing (100%)
Coverage: 85% overall, 100% on TaxCalculator

Quality Checks:
✅ flutter analyze - No issues found
✅ flutter test - All passing
✅ dart fix - Applied
✅ Code formatted

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Step 3: Push and Create Pull Request**

```bash
# Recommended: Use the /start-pr command
/start-pr

# Or manually:
# Push final commit
git push origin feature/2024-45-tax-calculator

# Create PR to dev using GitHub CLI
gh pr create --base dev --title "Week 45: Tax Calculator Implementation" \
  --body "$(cat <<'EOF'
## Summary
Implementation of {{TARGET_REGION}}-specific tax calculator for {{project_type}} projections.

## Completed This Week
- Federal and {{TARGET_REGION}} provincial tax calculations
- Progressive tax brackets and credits
- 2024 tax data from CRA/Revenu Québec
- Comprehensive test coverage (100% on calculator)

## Quality Assurance
- ✅ Tests: 130/130 passing
- ✅ Coverage: 85% overall, 100% on TaxCalculator
- ✅ Static analysis: No issues
- ✅ Security: No vulnerabilities
- ✅ Performance: Meets targets

## CI/CD Status
All checks will run automatically.

## Related
Implements Phase 0 milestone 3 from PLAN.md

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Step 4: Merge to Dev (after CI/CD passes)**

Once all CI/CD checks pass:

1. Review the PR yourself
2. Ensure all GitHub Actions workflows are green ✅
3. Merge using **Squash and merge** strategy
4. Delete the weekly branch after merge

```bash
# After merge on GitHub, update local dev
git checkout dev
git pull origin dev

# Delete local weekly branch
git branch -d feature/2024-45-tax-calculator
```

**Step 5: Promote to Other Environments**

After merging to dev, promote as needed:

```bash
# (Optional) Deploy to staging for UAT testing
/promote staging

# Deploy to production
/promote main
```

## Handling Incomplete Work

### If Work Extends Beyond One Week

If a week's work is not complete by Friday:

**Option 1: Merge Partial Progress (Recommended)**
```bash
# Create checkpoint commit
git commit -m "Week 45: Tax Calculator (Partial - In Progress)

Completed:
- Basic tax calculator structure
- Federal tax calculations
- Initial test suite

In Progress:
- {{TARGET_REGION}} provincial calculations
- Integration with projection engine

Tests: 85/85 passing (100% of completed features)
Coverage: 78% overall

This is a partial week's work. Will continue next week.
"

# Create PR and merge partial progress
# This keeps main branch updated with incremental progress
```

**Option 2: Continue on Same Branch Next Week**
```bash
# Don't create PR yet
# Continue work on Monday in same branch
# Add to weekly commit message:
"Week 45-46: Tax Calculator (Extended)

This feature spanned two weeks due to complexity...
"
```

### If Critical Bug Found

If a critical bug is found in production that needs immediate fix:

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-tax-calculation-error

# Fix the bug
# ... make fixes ...

# Commit fix
git commit -m "fix(tax): correct progressive bracket calculation

Critical bug in tax bracket calculation causing incorrect results.

Fixes #123"

# Create PR to main immediately
gh pr create --title "HOTFIX: Tax Calculation Error" --base main

# After merge to main, CI auto-deploys to production

# Also merge the fix to dev to keep branches in sync
git checkout dev
git pull origin dev
git merge main
git push origin dev

# Pull into your weekly branch if still active
git checkout feature/2024-45-tax-calculator
git merge dev
```

## Integration with PLAN.md

### Mapping Weeks to Plan Phases

Each week should correspond to milestones in `PLAN.md`:

**Example Mapping:**
```
Week 44: Phase 0, Milestone 1 - Project Setup
Week 45: Phase 0, Milestone 2 - Authentication
Week 46: Phase 0, Milestone 3 - Tax Calculator
Week 47: Phase 1, Milestone 1 - Project Management
```

### Updating PLAN.md

At the end of each week, update PLAN.md to track progress:

```markdown
## Phase 0: Foundation (Weeks 1-8)

### Week 44: ✅ Project Setup & Infrastructure
- Created Flutter project structure
- Set up CI/CD pipeline
- Configured Firebase
- **Status:** Complete
- **Branch:** week/2024-44-project-setup
- **Merged:** 2024-11-01

### Week 45: ✅ Tax Calculator
- Implemented {{TARGET_REGION}} tax calculator
- 100% test coverage on calculator
- **Status:** Complete
- **Branch:** week/2024-45-tax-calculator
- **Merged:** 2024-11-08

### Week 46: 🔄 Asset Management (Current)
- **Status:** In Progress
- **Branch:** week/2024-46-asset-management
- **ETA:** 2024-11-15
```

## CI/CD Integration

### Automatic Checks on Push

Every push to a weekly branch triggers:

1. **Code Quality** - Format and analysis checks
2. **Tests** - Run all tests with coverage check
3. **Security** - Vulnerability scanning
4. **Build** - Attempt builds for all platforms

### PR Checks Before Merge

Before merging to dev, the PR must pass:

- ✅ All tests passing
- ✅ Coverage ≥80% overall
- ✅ No security vulnerabilities
- ✅ Successful builds (web, Android, iOS)
- ✅ No merge conflicts with dev

### Deployment Triggers

| Branch Push | Action |
|-------------|--------|
| `dev` | Auto-deploy to dev environment |
| `staging` | Auto-deploy to staging environment (UAT) |
| `main` | Full deployment: Web (production), iOS (TestFlight), Android (Play Store) |

See `docs/ci-cd/secrets-setup.md` for CI/CD configuration details.

## Best Practices

### ✅ Do:

- **Start fresh each week** - New branch from `dev` every Monday (`/start-dev`)
- **Commit daily** - Push progress daily to avoid losing work
- **Run tests frequently** - Don't wait until Friday
- **Keep branches focused** - One major feature per week
- **Document progress** - Update PLAN.md with status
- **Clean up** - Delete branches after merge
- **Use promotion flow** - Always promote through environments (`/promote`)

### ❌ Don't:

- **Don't work directly on `dev`, `main`, or `staging`** - Always use feature branches
- **Don't skip quality checks** - Run analyze/test before merging
- **Don't merge broken code** - All tests must pass
- **Don't let branches linger** - Merge by end of week
- **Don't forget attribution** - Include Claude Code co-author
- **Don't ignore CI/CD failures** - Fix before merging
- **Don't skip the promotion flow** - Always go through `dev` first

## Example Full Week Workflow

```bash
# === MONDAY ===
# Start new week using /start-dev command
/start-dev tax-calculator

# Or manually:
git checkout dev
git pull origin dev
git checkout -b feature/2024-45-tax-calculator
git push -u origin feature/2024-45-tax-calculator

# === MONDAY-THURSDAY ===
# Daily development cycle
# ... code, commit, push daily ...
git add lib/features/tax/domain/
git commit -m "feat(tax): implement domain layer"
git push

# === FRIDAY ===
# Quality checks
flutter format .
flutter analyze  # Must pass
flutter test     # Must pass
dart fix --apply

# Weekly checkpoint
git add .
git commit -m "Week 45: Tax Calculator Implementation
..."
git push

# Create PR to dev using /start-pr command
/start-pr

# Or manually:
gh pr create --title "Week 45: Tax Calculator Implementation" --base dev

# === FRIDAY AFTERNOON ===
# After CI/CD passes and PR approved
# Merge on GitHub (squash and merge)

# Update local
git checkout dev
git pull origin dev
git branch -d feature/2024-45-tax-calculator

# === AFTER MERGE ===
# Promote to other environments as needed

# (Optional) Deploy to staging for UAT testing
/promote staging

# Deploy to production
/promote main

# Ready for next week!
```

## Troubleshooting

### "Tests failing on CI but pass locally"

```bash
# Ensure code generation is run
flutter pub run build_runner build --delete-conflicting-outputs

# Commit generated files
git add lib/**/*.g.dart lib/**/*.freezed.dart
git commit -m "build: update generated files"
git push
```

### "Merge conflicts with dev"

```bash
# Update your branch with latest dev
git checkout feature/2024-45-tax-calculator
git fetch origin
git merge origin/dev

# Resolve conflicts
# ... edit files ...

git add .
git commit -m "merge: resolve conflicts with dev"
git push
```

### "Coverage dropped below 80%"

```bash
# Check what's not covered
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Add missing tests
# ... write tests ...

git add test/
git commit -m "test: improve coverage to 85%"
git push
```

## Related Documentation

- [Git Workflow Guidelines](../../guidelines/git_workflow.md) - Detailed Git practices
- [CI/CD Guide](../../guidelines/cicd.md) - CI/CD pipeline details
- [Secrets Setup](./secrets-setup.md) - GitHub secrets configuration
- [Google Sign-In Setup](./google-signin-setup.md) - OAuth configuration
- [Development Workflow](../../CLAUDE.md) - Overall development process

---

**Version:** 1.0
**Last Updated:** November 2024
**Author:** Development Team with Claude Code
