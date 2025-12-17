# Promote

**Description:** Promote code between environments: dev → main (production) or dev → staging (UAT).

---

## Usage

```bash
/promote [target]
```

**Arguments:**
- `target` - Required. Target environment: `main` or `staging`
  - `main` - Merge dev → main (auto-deploys to production)
  - `staging` - Merge dev → staging (auto-deploys to staging for UAT)

**Examples:**
```bash
/promote main         # Merge dev → main (deploys to production)
/promote staging      # Merge dev → staging (UAT testing)
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
│        │ (auto-deploys to production)               │ staging       │
│        ▼                                            ▼               │
│   ┌─────────┐                                  ┌─────────┐          │
│   │  main   │ ←── Production                   │ staging │ ←── UAT │
│   └─────────┘                                  └─────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Points:**
- `dev` is the integration branch where all features merge
- `main` auto-deploys to production on push
- `staging` gets code directly from `dev` for UAT testing
- Single deployment step: `/promote main` deploys to production

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
| `main` | `dev` | Merge dev → main | Auto-deploy to production |
| `staging` | `dev` | Merge dev → staging | Auto-deploy to staging |

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

#### Promoting to Main / Production (`/promote main`)

**Purpose:** Merge integrated code from dev to main and auto-deploy to production.

```bash
echo "Promoting dev → main (production)..."

# Ensure we're on dev and it's up to date
git checkout dev
git pull origin dev

# Switch to main and merge
git checkout main
git pull origin main
git merge dev --no-edit

# Push (triggers production deployment via CI)
git push origin main

# Return to dev
git checkout dev
```

**Post-promotion message:**
```markdown
## Deployed to Production

**Merge:** `dev` → `main`
**Commit:** `<commit-hash>`
**URL:** {{PROD_URL}}

✅ Production deployment triggered automatically

### Verification Checklist
- [ ] Deployment workflow completed successfully
- [ ] Landing page loads correctly
- [ ] Flutter app loads at /app
- [ ] Authentication works
- [ ] Core features functional
- [ ] Performance acceptable

### Rollback (if needed)
```bash
firebase hosting:rollback
```

### Next Steps
- **Continue development:** `/start-dev`
- **Test on staging first (next time):** `/promote staging`
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

- **Deploy to production:** `/promote main`
```

---

### Phase 3: Pre-Promotion Checks

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

---

## Environment Configuration

### Branch to Environment Mapping

| Branch | Purpose | Auto-Deploy |
|--------|---------|-------------|
| `dev` | Integration branch | No |
| `main` | Production | Yes (on push) |
| `staging` | UAT testing | Yes (on push) |

### CI/CD Triggers

```yaml
# Workflows triggered by promotions:

# /promote main → ci.yml (tests + production deployment)
on:
  push:
    branches: [main]

# /promote staging → deploy-staging.yml
on:
  push:
    branches: [staging]
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

# Retry by re-pushing to main (will trigger CI again)
git commit --allow-empty -m "chore: retry deployment"
git push origin main
```

### Rollback

```bash
# Quick rollback (Firebase Hosting)
firebase hosting:rollback --site {{FIREBASE_PROJECT_ID}}

# Or revert and redeploy
git revert HEAD
git push origin main
# CI will automatically deploy the reverted state
```

---

## Safety Guards

### Production Deployment Guards

Production deployment is automatic when pushing to main. Safety is ensured by:

1. **CI tests must pass** - Deployment only runs if tests succeed
2. **Code must be in main** - Only the main branch deploys to production
3. **Recommend staging test** - Test on staging first with `/promote staging`

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

# 4. (Optional) Deploy to staging for UAT
/promote staging

# 5. After UAT approval, deploy to production
/promote main
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
