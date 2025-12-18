---
description: Deploy to environment (dev|staging|prod)  Use "/deploy --help" for options.
---

# Deploy

Unified command for building and deploying to all environments.

---

## Usage

```
/deploy <environment> [options]
```

**Environments:** `dev`, `staging`, `prod`

## Quick Reference

```bash
/deploy dev                 # Local build + deploy to dev
/deploy dev --build-only    # Build only, no deploy (test build locally)
/deploy staging             # Merge dev → staging (CI deploys)
/deploy staging --local     # Local build + deploy to staging
/deploy prod                # Merge dev → main (CI deploys everything)
/deploy prod --hotfix       # Quick web-only deploy to production
/deploy prod --functions    # Deploy only Cloud Functions
```

---

## Options

### Build Options

| Option         | Description                                       |
| -------------- | ------------------------------------------------- |
| `--build-only` | Build without deploying (test build locally)      |
| `--local`      | Force local build + deploy (for staging)          |

### Deployment Targets (prod only)

| Option        | Description                                  |
| ------------- | -------------------------------------------- |
| `--web`       | Deploy web only (landing page + Flutter web) |
| `--ios`       | Deploy iOS to TestFlight only                |
| `--android`   | Deploy Android to Play Store only            |
| `--functions` | Deploy Cloud Functions only                  |
| `--rules`     | Deploy Firestore rules only                  |

### Presets (prod only)

| Option      | Description                                               |
| ----------- | --------------------------------------------------------- |
| `--all`     | Deploy everything (default for prod)                      |
| `--hotfix`  | Quick web-only deploy (skips mobile, functions, rules)    |
| `--release` | Full release: web + iOS + Android with version increment  |
| `--none`    | Just merge branches, no deployment (sync only)            |

### Help

| Option   | Description            |
| -------- | ---------------------- |
| `--help` | Show this help message |

---

## Environment Behavior

### Development (`/deploy dev`)

Local build and deploy directly to Firebase:

```bash
# Build locally
./scripts/build-all.sh dev

# Deploy to dev hosting (skip if --build-only)
firebase deploy --only hosting:dev
```

### Staging (`/deploy staging`)

**Default:** Merge dev → staging branch (CI auto-deploys)

```bash
# Ensure dev is up to date
git checkout dev && git pull origin dev

# Merge to staging
git checkout staging
git pull origin staging
git merge dev --no-edit
git push origin staging

# Return to dev
git checkout dev
```

**With `--local`:** Build and deploy locally (same as dev)

```bash
./scripts/build-all.sh staging
firebase deploy --only hosting:staging
```

### Production (`/deploy prod`)

Merge dev → main with optional deployment markers. CI handles actual deployment.

| Option            | Commit Message Marker | CI Behavior                        |
| ----------------- | --------------------- | ---------------------------------- |
| `--all` (default) | (none)                | Deploy everything                  |
| `--hotfix`        | `[hotfix]`            | Web only, skip mobile/functions    |
| `--web`           | `[web-only]`          | Web only                           |
| `--ios`           | `[ios-only]`          | Web + iOS                          |
| `--android`       | `[android-only]`      | Web + Android                      |
| `--functions`     | `[functions-only]`    | Functions only                     |
| `--rules`         | `[rules-only]`        | Firestore rules only               |
| `--release`       | `[release]`           | Full deploy + version increment    |
| `--none`          | `[skip ci]`           | No deployment (branch sync only)   |

**Steps:**

```bash
# 1. Update branches
git checkout dev && git pull origin dev
git checkout main && git pull origin main

# 2. Merge dev → main
git merge dev --no-edit

# 3. For --release: increment version in pubspec.yaml
#    Commit: "chore: bump version to X.Y.Z"

# 4. Push with marker (if applicable)
git push origin main

# 5. Return to dev
git checkout dev
```

---

## Build Process (`--build-only`)

When using `--build-only` or as part of local deploy, the build process:

1. **Clean** - Remove existing `public/` directory

2. **Build Astro Landing Page** (if `landing-page/` exists)
   - Install npm dependencies
   - Run `npm run build`
   - Copy `dist/*` to `public/`

3. **Build Flutter Web App**
   - Run `flutter build web` with appropriate flags
   - Use `--dart-define=ENVIRONMENT=<env>` for configuration
   - Use `--base-href /app/` for subdirectory hosting
   - Copy `build/web/*` to `public/app/`

### Output Structure

```
public/
├── index.html        # Astro landing page
├── css/              # Landing page assets
├── images/           # Landing page images
└── app/
    ├── index.html    # Flutter app
    ├── main.dart.js  # Flutter compiled code
    ├── flutter.js    # Flutter runtime
    └── assets/       # Flutter assets
```

### Build Flags by Environment

| Environment | Mode    | Optimization | Debug Banner |
|-------------|---------|--------------|--------------|
| dev         | debug   | none         | shown        |
| staging     | debug   | none         | hidden       |
| prod        | release | full         | hidden       |

---

## Examples

```bash
# Build only (no deploy)
/deploy dev --build-only    # Test dev build locally
/deploy prod --build-only   # Test prod build locally

# Development
/deploy dev                 # Build + deploy to dev environment

# Staging
/deploy staging             # Promote dev → staging via CI
/deploy staging --local     # Build + deploy staging locally

# Production
/deploy prod                # Full deployment (default --all)
/deploy prod --hotfix       # Quick web fix (skips mobile builds)
/deploy prod --release      # Full release with version bump
/deploy prod --functions    # Deploy only Cloud Functions
/deploy prod --none         # Sync branches without deploying
```

---

## Environment URLs

| Environment | Landing Page              | Flutter App                  |
| ----------- | ------------------------- | ---------------------------- |
| dev         | {{DEV_URL}}               | {{DEV_URL}}/app              |
| staging     | {{STAGING_URL}}           | {{STAGING_URL}}/app          |
| prod        | {{PROD_URL}}              | {{PROD_URL}}/app             |

---

## Workflow Integration

```
Feature Branch
     │
     │ /start-pr (merge to dev)
     ▼
┌─────────┐
│   dev   │ ← Integration branch
└────┬────┘
     │
     ├──────────────────┬─────────────────┐
     │                  │                 │
     │ /deploy staging  │ /deploy prod    │ /deploy prod --hotfix
     ▼                  ▼                 ▼
┌─────────┐       ┌─────────┐       ┌─────────┐
│ staging │       │  prod   │       │  prod   │
│  (UAT)  │       │ (full)  │       │(web only)│
└─────────┘       └─────────┘       └─────────┘
```

**Typical flow:**
```bash
/start-dev my-feature       # Create feature branch
# ... develop ...
/deploy dev --build-only    # Test build works (optional)
/start-pr                   # Merge to dev
/deploy staging             # UAT testing (optional)
/deploy prod                # Ship to production
```

---

## Error Handling

### Merge Conflicts

```bash
# If conflicts occur during merge
echo "Resolve conflicts, then:"
git add .
git commit
git push origin <branch>
```

### Deployment Failure

```bash
# Check GitHub Actions logs
# Retry by pushing again:
git commit --allow-empty -m "chore: retry deployment"
git push origin main
```

### Rollback

```bash
# Quick rollback (Firebase Hosting only)
firebase hosting:rollback

# Or revert commit and redeploy
git revert HEAD
git push origin main
```

---

## Related Commands

- `/start-dev` - Start new feature branch
- `/start-pr` - Create PR and merge to dev
- `/commit` - Commit with conventional message

ARGUMENTS: $ARGUMENTS
