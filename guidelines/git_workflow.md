# Git Workflow Guidelines

## Overview

This document defines the Git workflow for the project, including branching strategy, commit conventions, pull request process, and integration with CI/CD.

## Branching Strategy

### Main Branch

#### `main`
- **Purpose:** Production-ready code with weekly integration
- **Protection:** Protected, requires PR reviews
- **Deployment:** Auto-deploys to Firebase Hosting on push
- **Testing:** Full CI/CD pipeline runs on every push
- **Naming:** Always `main`
- **Integration:** Weekly branches merge here at end of each week

**Note:** This project uses a simplified workflow without a separate `develop` branch. All development happens in weekly feature branches that merge directly to `main` after passing quality checks.

### Weekly Development Branches

**Primary Branch Type:** Weekly branches for regular development cycles

**Naming Convention:** `week/<year>-<week-number>-<brief-description>`

**Examples:**
```bash
week/2024-45-tax-calculator
week/2024-46-asset-management
week/2024-47-scenario-comparison
```

**Lifecycle:**
1. Branch from `main` at start of week (Monday)
2. Develop throughout week with daily commits
3. Create weekly checkpoint commit at end of week (Friday)
4. Create PR to `main` when quality checks pass
5. Merge to `main` after CI/CD passes
6. Delete branch after merge

**See:** `docs/ci-cd/weekly-workflow.md` for detailed weekly workflow guide

### Feature Branches (for ad-hoc features outside weekly cycle)

**Naming Convention:** `feature/<ticket-id>-<short-description>`

**Examples:**
```bash
feature/AUTH-123-user-authentication
feature/PROJ-456-payment-integration
feature/UI-789-dashboard-redesign
```

**Lifecycle:**
1. Branch from `main`
2. Develop feature with commits after each phase
3. Create PR to `main` when ready
4. Merge to `main` after review
5. Delete branch after merge

### Bug Fix Branches

**Naming Convention:** `fix/<ticket-id>-<short-description>`

**Examples:**
```bash
fix/BUG-321-calculation-error
fix/CRASH-654-null-pointer
fix/UI-987-button-alignment
```

**Lifecycle:**
1. Branch from `develop` (or `main` for hotfixes)
2. Fix bug with test
3. Create PR with bug description and fix
4. Merge after review
5. Delete branch after merge

### Hotfix Branches

**Naming Convention:** `hotfix/<ticket-id>-<short-description>`

**Examples:**
```bash
hotfix/PROD-111-critical-security-issue
hotfix/PROD-222-data-corruption
```

**Lifecycle:**
1. Branch from `main` (urgent production fixes)
2. Fix issue quickly
3. Create PR to `main`
4. After merge to `main`, merge back to `develop`
5. Delete branch after merge

### Release Branches

**Naming Convention:** `release/<version>`

**Examples:**
```bash
release/1.0.0
release/2.1.0-beta
```

**Lifecycle:**
1. Branch from `develop` when ready for release
2. Final testing and bug fixes only
3. Version bump and changelog update
4. Merge to `main` and tag
5. Merge back to `develop`
6. Delete branch after merge

## Commit Conventions

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, no logic change)
- **refactor:** Code refactoring (no feature or bug fix)
- **perf:** Performance improvements
- **test:** Adding or updating tests
- **build:** Build system or dependency changes
- **ci:** CI/CD configuration changes
- **chore:** Other changes (maintenance, etc.)

### Scope

The scope should indicate the feature/module affected:
- `auth` - Authentication
- `profile` - User profile
- `payments` - Payment processing
- `ui` - UI components
- `api` - API integration
- `db` - Database
- etc.

### Examples

```bash
# Feature
git commit -m "feat(auth): implement OAuth2 authentication

- Add Google OAuth provider
- Add Apple OAuth provider
- Include session management
- 95% test coverage

Closes #123"

# Bug fix
git commit -m "fix(payments): correct tax calculation

Previous implementation didn't handle edge case for zero amounts.
Added validation and test case.

Fixes #456"

# Documentation
git commit -m "docs(readme): update setup instructions

Add instructions for M1 Mac users
Include troubleshooting section"

# Refactoring
git commit -m "refactor(db): extract repository interface

Move repository interface to domain layer following clean architecture.
No functional changes.

Related to #789"

# Performance
git commit -m "perf(list): optimize rendering with RepaintBoundary

Add RepaintBoundary to list items to reduce repaint cost.
40% improvement in scroll performance."

# Test
git commit -m "test(auth): add integration tests for login flow

Cover edge cases:
- Invalid credentials
- Network errors
- Session expiry"
```

### End-of-Week Commits

**Special Convention:** At the end of each development week, create a checkpoint commit summarizing the week's work.

**Format:**
```bash
Week X: [Brief summary of work completed]

Completed:
- [Feature/component 1]
- [Feature/component 2]
- [Feature/component 3]

Tests: X/X passing (100%)
Coverage: X% overall, 100% on [critical components]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Example:**
```bash
git add .
git commit -m "$(cat <<'EOF'
Week 2: Tax Calculator Implementation

Completed:
- TaxCalculator with federal and {{TARGET_REGION}} provincial tax calculations
- Progressive tax brackets with income-tested credits
- 2024 CRA/Revenu Québec tax data
- Comprehensive test suite (30 tests)

Tests: 130/130 passing (100%)
Coverage: 100% on TaxCalculator

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Required Checks Before End-of-Week Commit:**
1. ✅ `flutter analyze` - No issues found
2. ✅ `flutter test` - All tests passing
3. ✅ `dart fix --apply` - Auto-fixable issues resolved
4. ✅ Test coverage maintained (≥80% overall, 100% critical code)

**When to Create:**
- End of each development week (typically Friday or after completing weekly milestones)
- After completing a significant phase in PLAN.md
- Before starting a new major feature
- When all weekly tasks from PLAN.md are done
```

### Claude Code Commits

When agents complete work, include Claude Code attribution:

```bash
git commit -m "feat(feature): implement feature

- Detailed changes
- Test coverage
- Security considerations

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Commit Strategy in Development Workflow

### Commit After Each Phase

When using `/new-feature` or `/implement`, commit after each major phase:

#### Phase 1: Architecture (if using /new-feature)
```bash
git add specs/ docs/
git commit -m "docs(feature): add technical specification

Architecture design by Architect Agent:
- Domain models defined
- Repository interfaces specified
- State management approach documented
- Firebase structure planned

🤖 Generated with Claude Code"
```

#### Phase 2: Domain Layer
```bash
git add lib/features/*/domain/
git commit -m "feat(feature): implement domain layer

- Add entities with Freezed
- Define repository interfaces
- Add value objects
- Include domain exceptions

🤖 Generated with Claude Code"
```

#### Phase 3: Data Layer
```bash
git add lib/features/*/data/
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/data/ # Generated files
git commit -m "feat(feature): implement data layer

- Add DTOs with JSON serialization
- Implement repositories
- Add data sources (remote/local)
- Include offline support

🤖 Generated with Claude Code"
```

#### Phase 4: Application Layer
```bash
git add lib/features/*/application/
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/application/ # Generated providers
git commit -m "feat(feature): implement application layer

- Add Riverpod providers with code generation
- Implement controllers/notifiers
- Add state classes with Freezed
- Include form validation

🤖 Generated with Claude Code"
```

#### Phase 5: Presentation Layer
```bash
git add lib/features/*/presentation/
git commit -m "feat(feature): implement presentation layer

- Add screens and widgets
- Implement forms with validation
- Add loading/error states
- Include navigation

🤖 Generated with Claude Code"
```

#### Phase 6: Tests
```bash
git add test/
git commit -m "test(feature): add comprehensive test coverage

- Unit tests for domain/data layers (95%+ coverage)
- Widget tests for presentation layer
- Integration tests for workflows
- Edge cases and error scenarios covered

Coverage: 87%

🤖 Generated with Claude Code"
```

#### Phase 7: After Security Audit
```bash
# If security issues found and fixed
git add lib/ test/
git commit -m "security(feature): address security audit findings

- Fix input validation issues
- Add data encryption for sensitive fields
- Update authentication checks
- Add audit logging

Security Audit: ✅ Passed

🤖 Generated with Claude Code"
```

#### Phase 8: After Performance Optimization
```bash
# If performance optimizations applied
git add lib/
git commit -m "perf(feature): optimize performance

- Add const constructors (24 widgets)
- Implement RepaintBoundary in lists
- Add selective watching with .select()
- Optimize image loading

Performance improvements:
- Frame time: 18ms → 14ms
- Memory: -35MB
- Rebuild count: -60%

🤖 Generated with Claude Code"
```

#### Phase 9: Final Review Fixes
```bash
# After code review
git add lib/ test/
git commit -m "refactor(feature): address code review feedback

- Extract large widgets into smaller components
- Add missing error handling
- Improve documentation
- Fix naming inconsistencies

Code Review: ✅ Approved

🤖 Generated with Claude Code"
```

## Pull Request Process

### Creating a Pull Request

1. **Ensure all commits are pushed:**
```bash
git push origin feature/your-feature-name
```

2. **Create PR on GitHub with template:**

**Title:** `feat(scope): Brief description`

**Description:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Agent Workflow
- [x] Architecture designed (Architect Agent)
- [x] Implementation completed (Developer Agent)
- [x] Tests written (Tester Agent) - 87% coverage
- [x] Security audit passed (Security Agent)
- [x] Performance optimized (Performance Agent)
- [x] Code review approved (Reviewer Agent)

## Quality Assurance

### Testing
- Unit tests: 95% coverage
- Widget tests: ✅ Passing
- Integration tests: ✅ Passing
- All tests passing: ✅ 156/156

### Security
- Security audit: ✅ No critical/high issues
- Input validation: ✅ Present
- Authentication: ✅ Verified
- Data protection: ✅ Encrypted

### Performance
- Frame rate: ✅ 60fps
- Memory usage: ✅ 87MB (target <100MB)
- Initial load: ✅ 2.8s (target <3s)
- Bundle size: ✅ 12.5MB (target <15MB)

## CI/CD Status
- [x] Code quality checks passed
- [x] Tests passed with 80%+ coverage
- [x] Security scans passed
- [x] Build successful

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Breaking Changes
[List any breaking changes]

## Migration Guide
[If breaking changes, provide migration guide]

## Related Issues
Closes #XXX

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

3. **Request reviewers**

4. **Wait for CI/CD pipeline** to complete

5. **Address review feedback** with new commits

### PR Review Checklist

Reviewers should verify:

- [ ] **CI/CD pipeline passed** (all checks green)
- [ ] **Agent reports included** (architecture, tests, security, performance, review)
- [ ] **Test coverage ≥80%** (≥95% for domain layer)
- [ ] **Security audit passed** (no critical/high issues)
- [ ] **Performance targets met** (60fps, <100MB memory)
- [ ] **Code follows standards** (formatting, naming, structure)
- [ ] **Documentation updated** (if needed)
- [ ] **Breaking changes documented** (if any)
- [ ] **Migration guide provided** (if breaking changes)

### Merging

**Requirements before merge:**
- ✅ All CI/CD checks passed
- ✅ Required reviews approved
- ✅ No merge conflicts
- ✅ Branch up to date with base branch

**Merge strategy:**
- Use **Squash and merge** for feature branches
- Use **Merge commit** for release branches
- Use **Rebase and merge** for hotfixes (if preferred)

**After merge:**
- Delete the feature branch
- Verify deployment (if to `main`)
- Update related tickets/issues

## CI/CD Integration

### GitHub Actions Workflow

The CI/CD pipeline runs automatically on:
- **Push to `main`**: Full pipeline + deployment
- **Push to `develop`**: Full pipeline + staging deployment
- **Pull requests**: Full pipeline + preview deployment

### Pipeline Stages

1. **Code Quality** (2-3 min)
   - Format check
   - Static analysis
   - Dependency check

2. **Code Generation** (1-2 min)
   - Run build_runner
   - Verify generated files committed

3. **Tests** (3-5 min)
   - Unit and widget tests
   - Coverage check (≥80%)
   - Upload to Codecov

4. **Security** (1-2 min)
   - Vulnerability scan
   - Hardcoded secrets check
   - Insecure code patterns check

5. **Build** (5-10 min)
   - Android APK/AAB
   - iOS IPA
   - Web build

6. **Deploy** (2-3 min, main only)
   - Firebase Hosting
   - Preview for PRs

**Total time:** ~15-25 minutes for full pipeline

### Secrets Configuration

Required secrets in GitHub repository settings:

```bash
FIREBASE_SERVICE_ACCOUNT  # Firebase service account JSON
FIREBASE_PROJECT_ID       # Firebase project ID
GITHUB_TOKEN             # Auto-provided by GitHub
```

### Firebase Setup

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Initialize Firebase Hosting:**
```bash
firebase init hosting
# Select your Firebase project
# Public directory: build/web
# Configure as single-page app: Yes
# Set up automatic builds with GitHub: Yes
```

3. **Generate service account:**
```bash
firebase login
# Go to Firebase Console > Project Settings > Service Accounts
# Generate new private key
# Add JSON content to GitHub secret: FIREBASE_SERVICE_ACCOUNT
```

4. **Configure firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

## Local Git Workflow

### Starting a New Week

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Create weekly branch (use current year-week)
git checkout -b week/2024-45-tax-calculator

# 3. Push to remote
git push -u origin week/2024-45-tax-calculator

# 4. Develop with Claude Code throughout the week
/new-feature
# Or
/implement

# 5. Commit daily and push progress
git add <files>
git commit -m "feat(tax): implement domain layer"
git push

# 6. End of week: quality checks and PR
# See docs/ci-cd/weekly-workflow.md for complete end-of-week process
```

### Starting an Ad-Hoc Feature (outside weekly cycle)

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/AUTH-123-oauth-login

# 3. Develop with Claude Code
/new-feature
# Or
/implement

# 4. Agents will create commits after each phase
# Review and push when ready

# 5. Push to remote
git push -u origin feature/AUTH-123-oauth-login

# 6. Create PR on GitHub
# Use GitHub UI or CLI: gh pr create
```

### Syncing with Main

```bash
# Update your branch with latest main
git checkout main
git pull origin main
git checkout week/2024-45-tax-calculator  # or feature/your-feature
git merge main
# Or: git rebase main (if no conflicts expected)

# Push updated branch
git push origin week/2024-45-tax-calculator
```

### Fixing PR Review Feedback

```bash
# Make changes based on feedback
# ... edit files ...

# Commit fixes
git add .
git commit -m "refactor: address PR feedback

- Extract large widget into components
- Add missing error handling
- Update documentation"

# Push to update PR
git push origin feature/your-feature
```

## Best Practices

### Commit Frequency

✅ **Do:**
- Commit after each logical phase (domain, data, application, presentation)
- Commit after generating code with build_runner
- Commit after writing tests
- Commit after fixing security/performance issues
- Commit after addressing review feedback

❌ **Don't:**
- Commit every small change (bundle related changes)
- Commit broken code (unless WIP branch)
- Commit generated files without running build_runner
- Commit without meaningful message

### Commit Messages

✅ **Do:**
- Use conventional commit format
- Write clear, descriptive subjects
- Include "why" in body, not just "what"
- Reference issue numbers
- Include Claude Code attribution

❌ **Don't:**
- Write vague messages ("fix stuff", "updates")
- Skip the body for non-trivial changes
- Forget to reference related issues
- Use past tense ("fixed" instead of "fix")

### Branch Management

✅ **Do:**
- Keep feature branches short-lived (< 1 week)
- Sync with develop regularly
- Delete branches after merge
- Use descriptive branch names
- Create draft PRs for early feedback

❌ **Don't:**
- Let branches get too far behind develop
- Push directly to main or develop
- Keep stale branches
- Use generic branch names (feature/new-stuff)
- Create PRs without CI/CD passing

## Troubleshooting

### CI/CD Pipeline Failures

**Code Quality Issues:**
```bash
# Run locally before pushing
dart format .
flutter analyze
```

**Test Failures:**
```bash
# Run tests locally
flutter test
flutter test --coverage

# Check coverage
lcov --summary coverage/lcov.info
```

**Build Failures:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web --release
```

**Security Scan Failures:**
```bash
# Check for issues locally
grep -r "apikey" --include="*.dart" lib/
grep -r "password\s*=" --include="*.dart" lib/
```

### Merge Conflicts

```bash
# Update your branch
git checkout feature/your-feature
git fetch origin
git merge origin/develop

# Resolve conflicts
# ... edit conflicting files ...

# Mark as resolved
git add .
git commit -m "merge: resolve conflicts with develop"

# Push
git push origin feature/your-feature
```

### Failed Deployment

1. Check Firebase Hosting logs
2. Verify secrets are configured
3. Ensure firebase.json is correct
4. Check build output in GitHub Actions logs
5. Test deployment locally:
```bash
firebase serve
firebase deploy --only hosting
```

---

**Version:** 1.0
**Last Updated:** November 2024
**Related:** `cicd.md`, `dev-workflow/DEVELOPMENT_WORKFLOW.md`
