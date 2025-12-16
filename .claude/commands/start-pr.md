# Start Pull Request

**Description:** Initiate pull request activities by running validation checks, creating a PR to dev, and guiding through the merge process.

---

## Usage

```bash
/start-pr [optional: --skip-tests] [optional: --draft]
```

**Options:**
- `--skip-tests` - Skip running tests (not recommended, use only if tests were recently run)
- `--draft` - Create as draft PR instead of ready for review

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        /start-pr Workflow                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Pre-flight Checks                                               │
│     └─→ Verify on feature branch, check uncommitted changes         │
│                                                                     │
│  2. Quality Validation                                              │
│     └─→ Format → Analyze → Test → Coverage                          │
│                                                                     │
│  3. Create Pull Request                                             │
│     └─→ Push changes → Create PR to dev → Wait for CI               │
│                                                                     │
│  4. Merge (after CI passes)                                         │
│     └─→ Squash merge to dev → Delete branch                         │
│                                                                     │
│  5. Post-Merge Recommendations                                      │
│     └─→ Recommend /promote main or /promote staging                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Pre-flight Checks

### Verify Current Branch

```bash
# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check if on dev - should not create PR from dev
if [ "$CURRENT_BRANCH" = "dev" ]; then
    echo "ERROR: Cannot create PR from dev branch."
    echo "Use /start-dev to create a feature branch first."
    exit 1
fi

# Check if on main - should not create PR from main
if [ "$CURRENT_BRANCH" = "main" ]; then
    echo "ERROR: Cannot create PR from main branch."
    echo "Use /start-dev to create a feature branch first."
    exit 1
fi
```

**If on dev or main branch:** Inform the user to use `/start-dev` first and abort.

### Check for Uncommitted Changes

```bash
# Check for uncommitted changes
git status --porcelain
```

**If uncommitted changes exist:**

Ask the user:
- **Commit all changes** - Stage and commit everything
- **Select files to commit** - Interactive selection
- **Stash for later** - Save changes without committing
- **Abort** - Cancel to handle manually

### Check Sync with Remote

```bash
# Check if branch is pushed
git fetch origin
git log origin/$CURRENT_BRANCH..HEAD --oneline 2>/dev/null
git log HEAD..origin/$CURRENT_BRANCH --oneline 2>/dev/null
```

**If local is behind remote:** Pull changes first.
**If local has unpushed commits:** Will push in Phase 3.

---

## Phase 2: Quality Validation

Run all quality checks before creating PR:

### Step 1: Code Formatting

```bash
echo "Step 1/5: Formatting code..."
dart format .

# Check if formatting made changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Formatting applied changes. Committing..."
    git add .
    git commit -m "style: apply dart format

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
fi
```

### Step 2: Static Analysis

```bash
echo "Step 2/5: Running static analysis..."
flutter analyze

# If issues found, attempt auto-fix
if [ $? -ne 0 ]; then
    echo "Attempting auto-fix..."
    dart fix --apply
    flutter analyze

    if [ $? -ne 0 ]; then
        echo "FAILED: Static analysis issues remain."
        echo "Fix the issues above before proceeding."
        # Show issues and ask user to fix or abort
    fi
fi
```

**If analysis fails:**
- Show the issues
- Ask user: **Fix issues and retry** or **Abort**

### Step 3: Run Tests

```bash
echo "Step 3/5: Running tests..."
flutter test
```

**If tests fail:**
- Show failing tests
- Ask user: **Fix tests and retry** or **Abort**
- Optionally: **Skip tests** (with warning)

### Step 4: Check Test Coverage

```bash
echo "Step 4/5: Checking test coverage..."
flutter test --coverage

# Use coverage script if available
if [ -f "scripts/coverage-report.py" ]; then
    python3 scripts/coverage-report.py --ci
else
    # Fallback to basic coverage check
    lcov --summary coverage/lcov.info | grep "lines"
fi
```

**Coverage Requirements:**
- Overall: ≥80%
- Critical components: 100%

**If coverage below threshold:**
- Show coverage report
- Warn user but allow proceeding (coverage is informational)

### Step 5: Build Check

```bash
echo "Step 5/5: Verifying build..."
flutter build web --release --base-href /app/
```

**If build fails:**
- Show build errors
- Abort and ask user to fix

---

## Phase 3: Create Pull Request

### Push Latest Changes

```bash
echo "Pushing changes to remote..."
git push origin $CURRENT_BRANCH
```

### Generate PR Summary

Analyze commits since branching from dev:

```bash
# Get commits for this branch
git log dev..$CURRENT_BRANCH --oneline

# Get diff summary
git diff dev..$CURRENT_BRANCH --stat
```

### Create Pull Request

Use GitHub CLI to create PR targeting dev:

```bash
# Determine PR title from branch name or commits
# dev/2024-51-tax-calculator → "Week 51: Tax Calculator"

gh pr create \
  --base dev \
  --title "Week XX: <Feature Summary>" \
  --body "$(cat <<'EOF'
## Summary
<Auto-generated summary of changes based on commits>

## Completed This Week
- <Feature/component 1>
- <Feature/component 2>
- <Feature/component 3>

## Quality Assurance

### Tests
- ✅ All tests passing: X/X
- ✅ Coverage: X% (target: 80%)

### Code Quality
- ✅ `flutter analyze` - No issues
- ✅ `dart format` - Applied
- ✅ Build successful

## Commits
<List of commits in this PR>

## CI/CD
All checks will run automatically upon PR creation.

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Wait for CI/CD

```bash
echo "Pull Request created. Waiting for CI/CD checks..."
echo "PR URL: <url>"

# Monitor CI status
gh pr checks $CURRENT_BRANCH --watch
```

**If CI fails:**
- Show which checks failed
- Provide guidance on fixing
- User must fix and re-push

---

## Phase 4: Merge to Dev

Once CI passes:

### Confirm Ready to Merge

Ask the user:
- **Merge now** - Squash and merge to dev
- **Wait for review** - Keep PR open for human review
- **Close without merging** - Cancel the PR

### Perform Merge

```bash
# Squash and merge
gh pr merge $CURRENT_BRANCH --squash --delete-branch

# Update local dev
git checkout dev
git pull origin dev
```

---

## Phase 5: Post-Merge Recommendations

Provide recommendations based on the workflow:

```markdown
## PR Merged Successfully

**Branch:** `dev/YYYY-WW-<description>` → `dev`
**PR:** #<number>
**Merge commit:** `<hash>`

---

## Recommended Next Steps

### 1. Promote to Main (for stable release)

Merge your changes to main for a stable release candidate:

```bash
/promote main
```

This will:
- Merge dev → main
- No automatic deployment (main is stable branch)
- Code is ready for production deployment

### 2. Promote to Staging (for UAT testing)

Deploy directly to staging for user acceptance testing:

```bash
/promote staging
```

This will:
- Merge dev → staging
- Auto-deploy to staging environment
- URL: {{STAGING_URL}}

### 3. Deploy to Production (after testing)

When ready for production (requires code in main):

```bash
/promote prod
```

This will:
- Deploy main → production
- Trigger production deployment workflow

---

## Typical Workflow

1. `/start-pr` → Merge to dev ✅ (done)
2. `/promote staging` → Test on staging
3. `/promote main` → Merge to stable main
4. `/promote prod` → Deploy to production

---

## Start New Development

Ready to work on the next feature:

```bash
/start-dev <next-feature-description>
```
```

---

## Error Handling

### PR Creation Fails

```bash
# Common issues and fixes:
# 1. Not logged into gh CLI
gh auth login

# 2. No changes to create PR
echo "No commits between dev and current branch."

# 3. PR already exists
echo "A PR already exists for this branch."
gh pr view $CURRENT_BRANCH
```

### Merge Conflicts

```bash
# If merge conflicts detected
echo "Merge conflicts detected. Resolve before merging:"
git checkout $CURRENT_BRANCH
git fetch origin dev
git merge origin/dev
# ... resolve conflicts ...
git push origin $CURRENT_BRANCH
```

### CI/CD Timeout

```bash
# If CI takes too long
echo "CI/CD is taking longer than expected."
echo "Check status at: https://github.com/<repo>/actions"
echo "You can merge manually once checks pass."
```

---

## Validation Summary Report

At the end of Phase 2, provide a summary:

```markdown
## Quality Validation Report

| Check | Status | Details |
|-------|--------|---------|
| Formatting | ✅ Pass | No issues |
| Analysis | ✅ Pass | No issues found |
| Tests | ✅ Pass | 156/156 passing |
| Coverage | ✅ Pass | 85% (target: 80%) |
| Build | ✅ Pass | Web build successful |

**Overall:** Ready for PR ✅
```

---

## Related Commands

- `/start-dev` - Start new development branch
- `/promote` - Promote to main/staging/production
- `/code-review` - Run code review before PR
- `/test-audit` - Detailed test coverage analysis

---

## Related Documentation

- [Weekly Workflow](../docs/ci-cd/weekly-workflow.md) - End of week process
- [Git Workflow](../guidelines/git_workflow.md) - PR process details
- [CI/CD Guide](../guidelines/cicd.md) - Pipeline configuration
