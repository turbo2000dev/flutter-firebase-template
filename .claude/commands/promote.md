# Promote

**Description:** Promote code between environments: dev → main (stable), dev → staging (UAT), or main → prod (production deployment).

---

## Usage

```bash
/promote [target]
```

**Arguments:**
- `target` - Required. Target environment: `main`, `staging`, or `prod`
  - `main` - Merge dev → main (no deployment, stable release branch)
  - `staging` - Merge dev → staging (auto-deploys to staging for UAT)
  - `prod` - Deploy main → production (triggers production deployment)

**Examples:**
```bash
/promote main         # Merge dev → main (stable release)
/promote staging      # Merge dev → staging (UAT testing)
/promote prod         # Deploy main → production
```

---

## Environment Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Environment Promotion Flow                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Feature Branch (dev/YYYY-WW-*)                                    │
│        │                                                            │
│        │ /start-pr (merge to dev)                                   │
│        ▼                                                            │
│   ┌─────────┐                                                       │
│   │   dev   │ ←── Integration Branch                                │
│   └────┬────┘                                                       │
│        │                                                            │
│        ├────────────────────────────────────────────┐               │
│        │                                            │               │
│        │ /promote main                              │ /promote      │
│        │ (no deployment)                            │ staging       │
│        ▼                                            ▼               │
│   ┌─────────┐                                  ┌─────────┐          │
│   │  main   │ ←── Stable/Release-Ready         │ staging │ ←── UAT │
│   └────┬────┘                                  └─────────┘          │
│        │                                                            │
│        │ /promote prod                                              │
│        │ (triggers deployment)                                      │
│        ▼                                                            │
│   ┌─────────┐                                                       │
│   │  prod   │ ←── Production                                        │
│   └─────────┘                                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Points:**
- `dev` is the integration branch where all features merge
- `main` is stable/release-ready code (no auto-deployment)
- `staging` gets code directly from `dev` for UAT testing
- `prod` deployment requires code to be in `main` first

---

## Workflow

### Phase 1: Validate Current Context

```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
```

**Promotion Rules by Target:**

| Target | Source Branch | Action | Deployment |
|--------|---------------|--------|------------|
| `main` | `dev` | Merge dev → main | None |
| `staging` | `dev` | Merge dev → staging | Auto-deploy to staging |
| `prod` | `main` | Deploy from main | Trigger prod deployment |

#### If on Feature Branch (dev/*, feature/*, fix/*, etc.)

```markdown
## Cannot Promote from Feature Branch

You are currently on: `<branch-name>`

Feature branches must first be merged to `dev` before promotion.

**To proceed:**
```bash
/start-pr
```

This will:
1. Run quality checks
2. Create a PR to dev
3. Merge your changes
4. Then you can promote to main/staging/prod
```

**Action:** Abort and suggest `/start-pr`.

---

### Phase 2: Execute Promotion Based on Target

#### Promoting to Main (`/promote main`)

**Purpose:** Merge integrated code from dev to the stable main branch. No deployment triggered.

```bash
echo "Promoting dev → main..."

# Ensure we're on dev and it's up to date
git checkout dev
git pull origin dev

# Switch to main and merge
git checkout main
git pull origin main
git merge dev --no-edit

# Push (no deployment triggered)
git push origin main

# Return to dev
git checkout dev
```

**Post-promotion message:**
```markdown
## Promoted to Main

**Merge:** `dev` → `main`
**Commit:** `<commit-hash>`

✅ Code is now in stable main branch
❌ No deployment triggered (main branch does not auto-deploy)

### Next Steps

- **Deploy to production:** `/promote prod`
- **Test on staging first:** `/promote staging`
- **Continue development:** `/start-dev`
```

#### Promoting to Staging (`/promote staging`)

**Purpose:** Deploy code from dev to staging environment for UAT testing.

```bash
echo "Promoting dev → staging..."

# Ensure we're on dev and it's up to date
git checkout dev
git pull origin dev

# Switch to staging and merge
git checkout staging 2>/dev/null || git checkout -b staging
git pull origin staging 2>/dev/null || true
git merge dev --no-edit

# Push to trigger staging deployment
git push origin staging

# Return to dev
git checkout dev
```

**Post-promotion message:**
```markdown
## Deployed to Staging

**Merge:** `dev` → `staging`
**Commit:** `<commit-hash>`
**URL:** {{STAGING_URL}}

✅ Staging deployment triggered automatically

### Verification Checklist
- [ ] Landing page loads correctly
- [ ] Flutter app loads at /app
- [ ] Authentication works
- [ ] Core features functional
- [ ] No console errors

### Next Steps (after UAT approval)

1. **Merge to stable main:** `/promote main`
2. **Deploy to production:** `/promote prod`
```

#### Promoting to Production (`/promote prod`)

**Purpose:** Deploy stable code from main to production.

**Pre-requisites:**
- Code must be in `main` branch
- Run validation checks before deployment

```bash
echo "Deploying main → production..."

# Ensure main is up to date
git checkout main
git pull origin main

# Run pre-production validation
echo "Running pre-production validation..."
flutter analyze
flutter test

# Trigger production deployment
gh workflow run deploy-prod.yml

# Or if using a prod branch:
# git checkout prod 2>/dev/null || git checkout -b prod
# git merge main --no-edit
# git push origin prod
```

**Post-promotion message:**
```markdown
## Production Deployment Triggered

**Source:** `main`
**Commit:** `<commit-hash>`
**URL:** {{PROD_URL}}

⚠️ Production deployment in progress...

### Verification Checklist
- [ ] Deployment workflow completed successfully
- [ ] Landing page loads correctly
- [ ] Flutter app loads at /app
- [ ] Authentication works
- [ ] Core features functional
- [ ] Performance acceptable
- [ ] Monitoring/analytics active

### Rollback (if needed)
```bash
firebase hosting:rollback
```
```

---

### Phase 3: Pre-Promotion Checks

#### For `/promote main` and `/promote staging`

Validation is recommended but not required:

```bash
# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "WARNING: You have uncommitted changes."
    echo "These will NOT be included in the promotion."
fi

# Ensure branches are up to date
git fetch origin
```

#### For `/promote prod` (Required Validation)

```bash
echo "Running pre-production validation..."

# 1. Static analysis
flutter analyze
if [ $? -ne 0 ]; then
    echo "FAILED: Static analysis issues found."
    exit 1
fi

# 2. Run tests
flutter test
if [ $? -ne 0 ]; then
    echo "FAILED: Tests are failing."
    exit 1
fi

# 3. Check coverage (warning only)
flutter test --coverage
python3 scripts/coverage-report.py --ci || echo "WARNING: Coverage below threshold."
```

---

### Phase 4: Production Confirmation

Before deploying to production, require explicit confirmation:

```markdown
## Production Deployment Confirmation

You are about to deploy to **PRODUCTION**.

**Source branch:** `main`
**Target:** Production environment

**Changes since last production deployment:**
- <commit summary 1>
- <commit summary 2>
- <commit summary 3>

**This will affect live users immediately.**

Are you sure you want to proceed?
```

**Options:**
- **Yes, deploy to production** - Proceed with deployment
- **No, cancel** - Abort the promotion
- **Test on staging first** - Redirect to `/promote staging`

---

## Environment Configuration

### Branch to Environment Mapping

| Branch | Purpose | Auto-Deploy |
|--------|---------|-------------|
| `dev` | Integration branch | No |
| `main` | Stable/release-ready | No |
| `staging` | UAT testing | Yes (on push) |
| `prod` | Production | Manual trigger |

### CI/CD Triggers

```yaml
# Workflows triggered by promotions:

# /promote main → No workflow (just git merge)

# /promote staging → deploy-staging.yml
on:
  push:
    branches: [staging]

# /promote prod → deploy-prod.yml
on:
  workflow_dispatch  # Manual trigger required
```

---

## Error Handling

### Merge Conflicts

```bash
# If merge conflicts during promotion
echo "Merge conflicts detected."
echo "Resolve conflicts, then continue:"
git add .
git commit
git push origin <target-branch>
```

### Deployment Failure

```bash
# If deployment fails
echo "Deployment failed. Check:"
echo "1. GitHub Actions logs"
echo "2. Firebase Console"
echo "3. Service account permissions"

# Retry deployment
gh workflow run deploy-prod.yml
```

### Rollback

```bash
# Quick rollback (Firebase Hosting)
firebase hosting:rollback --site {{FIREBASE_PROJECT_ID}}

# Or revert and redeploy
git revert HEAD
git push origin main
/promote prod
```

---

## Safety Guards

### Production Deployment Guards

Before deploying to production:

1. **Require confirmation** - Explicit user approval
2. **Run full validation** - Tests and analysis must pass
3. **Check branch state** - main must be clean and up-to-date
4. **Recommend staging test** - Warn if staging wasn't tested

### Staging Validation

Before promoting to staging:

1. **Recommend testing** - Suggest running tests locally
2. **Check for breaking changes** - Warn about schema changes
3. **Remind about UAT** - Share staging URL with stakeholders

---

## Typical Workflow

```bash
# 1. Develop feature
/start-dev my-feature

# 2. Make changes, commit, push
/commit --push

# 3. Create PR and merge to dev
/start-pr

# 4. Deploy to staging for UAT
/promote staging

# 5. After UAT approval, merge to stable main
/promote main

# 6. Deploy to production
/promote prod
```

---

## Related Commands

- `/start-dev` - Start new development branch
- `/start-pr` - Create PR and merge to dev
- `/deploy` - Direct deployment without branch promotion
- `/build-all` - Build all components

---

## Related Documentation

- [Deployment Guidelines](../guidelines/deployment.md) - Detailed deployment procedures
- [Weekly Workflow](../docs/ci-cd/weekly-workflow.md) - Development cycle
- [CI/CD Guide](../guidelines/cicd.md) - Pipeline configuration
