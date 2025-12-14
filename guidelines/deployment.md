# Deployment Guidelines

## Overview

This document covers deployment procedures for all components of the {{PROJECT_DESCRIPTION}} application:
- **Flutter Web App** - Main application
- **Astro Landing Page** - SEO-optimized marketing/landing page
- **Firebase Cloud Functions** - Python backend services
- **Firebase Configuration** - Security rules, indexes

## Deployment Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          Firebase Hosting                             │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  example.com/          → Astro Landing Page (SEO-optimized HTML)     │
│  example.com/app/      → Flutter Web App (SPA, behind auth)          │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        Cloud Functions                                │
├──────────────────────────────────────────────────────────────────────┤
│  - generate_excel_export (Python 3.12)                               │
│  - Future API endpoints                                              │
└──────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    Firestore + Storage                                │
├──────────────────────────────────────────────────────────────────────┤
│  - User data, projects, scenarios                                    │
│  - Exported files, images                                            │
└──────────────────────────────────────────────────────────────────────┘
```

## Quick Reference

### Deploy Commands

```bash
# Full deployment to an environment
./scripts/deploy.sh <env>              # dev, staging, or prod

# Deploy everything (hosting + functions + rules + wizard images)
./scripts/deploy.sh <env> --all

# Build all components
./scripts/build-all.sh <env>

# Deploy specific components
firebase deploy --only hosting:dev      # Landing + App to dev
firebase deploy --only functions        # Cloud Functions only
firebase deploy --only firestore:rules  # Security rules only

# Deploy wizard images to Firebase Storage
./scripts/deploy.sh <env> --wizard-images
./scripts/upload-wizard-images.sh       # Standalone script
```

### Environment URLs

| Environment | Landing Page                             | Flutter App                                  |
| ----------- | ---------------------------------------- | -------------------------------------------- |
| dev         | `https://{{DEV_URL}}`         | `https://{{DEV_URL}}/app`         |
| staging     | `https://{{PROJECT_NAME}}-staging.web.app` | `https://{{PROJECT_NAME}}-staging.web.app/app` |
| prod        | `https://{{FIREBASE_PROJECT_ID}}.web.app`   | `https://{{FIREBASE_PROJECT_ID}}.web.app/app`   |

## Component Deployment

### 1. Flutter Web App

**Build:**
```bash
# Development
flutter build web --dart-define=ENVIRONMENT=dev

# Staging
flutter build web --dart-define=ENVIRONMENT=staging

# Production (optimized)
flutter build web --release \
  --dart-define=ENVIRONMENT=prod \
  --base-href /app/
```

**Important:** Always use `--base-href /app/` when the app is hosted under a subdirectory.

**Deploy:**
```bash
# The build output goes to build/web/
# Deploy script copies this to public/app/
./scripts/deploy.sh <env>
```

### 2. Astro Landing Page

**Build:**
```bash
cd landing-page
npm install
npm run build
# Output: landing-page/dist/
```

**Deploy:**
```bash
# Deploy script copies landing-page/dist/* to public/
./scripts/deploy.sh <env>
```

**Local Development:**
```bash
cd landing-page
npm run dev
# Opens at http://localhost:4321
```

### 3. Firebase Cloud Functions (Python)

**Prerequisites:**
```bash
cd functions
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

**Test Locally:**
```bash
firebase emulators:start --only functions
```

**Deploy:**
```bash
firebase deploy --only functions
```

**Logs:**
```bash
firebase functions:log
# Or in Google Cloud Console
```

### 4. Firestore Security Rules

**Deploy:**
```bash
firebase deploy --only firestore:rules
```

**Test Rules Locally:**
```bash
firebase emulators:start --only firestore
# Run security rules tests
```

### 5. Wizard Images (Firebase Storage)

Wizard images for the project creation wizard are stored in Firebase Storage and loaded dynamically based on user language.

**Deploy with deploy.sh:**
```bash
./scripts/deploy.sh prod --wizard-images
# Or include in full deployment
./scripts/deploy.sh prod --all
```

**Deploy standalone:**
```bash
./scripts/upload-wizard-images.sh
```

**Automated via CI/CD:**
- Production deployments via GitHub Actions automatically upload wizard images if present in `images/wizard/{en,fr}/`

**Source location:** `images/wizard/{en,fr}/*.png`
**Destination:** `gs://{{FIREBASE_PROJECT_ID}}.firebasestorage.app/wizard_images/{en,fr}/`

For detailed image specifications and generation prompts, see `docs/asset_pipeline.md`.

## Full Deployment Process

### Manual Deployment

```bash
# 1. Ensure you're on the correct branch
git checkout main  # for prod
git pull origin main

# 2. Run quality checks
flutter analyze
flutter test

# 3. Build and deploy
./scripts/deploy.sh prod
```

### Automated Deployment (CI/CD)

Deployments are triggered by GitHub Actions:

| Trigger                  | Environment | Approval  |
| ------------------------ | ----------- | --------- |
| Push to `develop`        | dev         | Automatic |
| Push to `staging`        | staging     | Automatic |
| Manual workflow dispatch | prod        | Required  |

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing (`flutter test`)
- [ ] No analysis issues (`flutter analyze`)
- [ ] Code reviewed and approved
- [ ] Feature flags set correctly for environment
- [ ] Environment variables configured
- [ ] Database migrations applied (if any)

### Post-Deployment

- [ ] Smoke test the deployment
- [ ] Verify landing page loads correctly
- [ ] Verify Flutter app loads at /app
- [ ] Test authentication flow
- [ ] Check Cloud Functions are responding
- [ ] Monitor error rates in Firebase Console
- [ ] Verify analytics events (if applicable)

## Rollback Procedures

### Quick Rollback (Firebase Hosting)

```bash
# List recent deployments
firebase hosting:releases:list --site {{FIREBASE_PROJECT_ID}}

# Rollback to previous version
firebase hosting:rollback --site {{FIREBASE_PROJECT_ID}}
```

### Via Firebase Console

1. Go to Firebase Console → Hosting
2. Click on release history
3. Select previous deployment
4. Click "Rollback"

### Git Revert (Triggers New Deployment)

```bash
# Revert the problematic commit
git revert HEAD
git push origin main

# CI/CD will deploy the reverted state
```

## Troubleshooting

### "404 on /app routes"

**Cause:** SPA routing not configured correctly.

**Fix:** Ensure `firebase.json` has proper rewrites:
```json
{
  "rewrites": [
    { "source": "/app/**", "destination": "/app/index.html" },
    { "source": "**", "destination": "/index.html" }
  ]
}
```

### "Assets not loading in /app"

**Cause:** Flutter built without correct base-href.

**Fix:** Rebuild with `--base-href /app/`:
```bash
flutter build web --release --base-href /app/
```

### "Cloud Function returns CORS error"

**Cause:** CORS headers not configured.

**Fix:** Ensure function sets CORS headers:
```python
# In Cloud Function
headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
}
```

### "Landing page shows Flutter app"

**Cause:** Rewrite rules catching everything.

**Fix:** Ensure landing page files are in root, not under `/app`:
```
public/
├── index.html         ← Landing page
├── css/
├── app/
│   └── index.html     ← Flutter app
```

### "Deployment failed - permission denied"

**Cause:** Service account lacks permissions.

**Fix:**
```bash
# Verify service account roles
./scripts/verify-firebase-permissions.sh

# Required roles:
# - Firebase Hosting Admin
# - Cloud Functions Developer
# - Service Account User
```

## Security Considerations

### Secrets Management

- Never commit secrets to repository
- Use GitHub Actions secrets for CI/CD
- Use `.env` files locally (gitignored)
- Rotate service account keys periodically

### Pre-Deployment Security Check

```bash
# Check for hardcoded secrets
grep -r "apikey\|password\|secret" --include="*.dart" lib/

# Run security audit
./scripts/security-scan.sh
```

### Production Safeguards

- Production deployments require manual approval
- Tag production releases: `git tag v1.2.3`
- Maintain deployment log

## Monitoring

### Firebase Console

- **Hosting:** Deployment history, traffic
- **Functions:** Invocations, errors, latency
- **Firestore:** Usage, security rules evaluation

### Crashlytics

Monitor app crashes post-deployment:
- Check crash-free user rate
- Investigate new crash patterns
- Set up alerts for regression

### Custom Monitoring

```bash
# Check function logs
gcloud functions logs read generate_excel_export --limit 50

# Check hosting traffic
firebase hosting:channel:list
```

## Environment-Specific Notes

### Development (dev)

- Debug mode enabled
- Verbose logging
- Analytics disabled
- May have experimental features

### Staging (staging)

- Release mode
- Normal logging
- Analytics enabled (for testing)
- Feature-complete for testing

### Production (prod)

- Release mode, fully optimized
- Minimal logging
- Full analytics and crash reporting
- Only stable, tested features

---

**Version:** 1.0
**Last Updated:** December 2024
**Related:** `environments.md`, `cicd.md`
