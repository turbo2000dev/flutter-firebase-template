# CI/CD Guidelines

## Overview

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline powered by GitHub Actions and Firebase Hosting.

## Pipeline Architecture

```
┌─────────────┐
│ Git Push    │
│ or PR       │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│     GitHub Actions Workflow             │
├─────────────────────────────────────────┤
│  1. Code Quality                        │
│     - Format check                      │
│     - Static analysis (flutter analyze)│
│     - Dependency audit                  │
├─────────────────────────────────────────┤
│  2. Code Generation                     │
│     - Run build_runner                  │
│     - Verify generated files committed  │
├─────────────────────────────────────────┤
│  3. Tests                               │
│     - Unit & widget tests               │
│     - Coverage check (≥80%)             │
│     - Upload to Codecov                 │
├─────────────────────────────────────────┤
│  4. Security                            │
│     - Vulnerability scan                │
│     - Secrets detection                 │
│     - Insecure code patterns           │
├─────────────────────────────────────────┤
│  5. Build                               │
│     - Android APK/AAB                   │
│     - iOS IPA                           │
│     - Web build                         │
├─────────────────────────────────────────┤
│  6. Deploy (main branch only)           │
│     - Firebase Hosting                  │
│     - Preview for PRs                   │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────┐
│ Deployment  │
│ Success     │
└─────────────┘
```

## Pipeline Stages

### Stage 1: Code Quality (2-3 minutes)

**Purpose:** Ensure code meets formatting and quality standards

**Checks:**
- Code formatting with `dart format`
- Static analysis with `flutter analyze`
- Unused dependencies check

**Pass Criteria:**
- All files formatted correctly
- No analysis errors or warnings
- No unused dependencies

**Common Failures:**
- Formatting issues → Run `dart format .` locally
- Analysis errors → Fix reported issues
- Unused deps → Remove from `pubspec.yaml`

### Stage 2: Code Generation (1-2 minutes)

**Purpose:** Ensure generated code is up-to-date

**Checks:**
- Run `build_runner` to generate code
- Verify no uncommitted generated files

**Pass Criteria:**
- Generated files match source code
- All generated files committed

**Common Failures:**
- Generated files not committed → Run build_runner and commit
- Syntax errors in annotations → Fix Freezed/Riverpod annotations

### Stage 3: Tests (3-5 minutes)

**Purpose:** Verify functionality and maintain code quality

**Checks:**
- Run all unit and widget tests
- Calculate code coverage
- Verify coverage ≥80% threshold
- Upload coverage to Codecov

**Pass Criteria:**
- All tests pass
- Coverage ≥80% overall
- Coverage ≥95% for domain layer (if applicable)

**Common Failures:**
- Test failures → Fix broken tests
- Low coverage → Add more tests
- Flaky tests → Make tests deterministic

**Coverage Breakdown:**
```bash
# View coverage summary
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Stage 4: Security (1-2 minutes)

**Purpose:** Detect security vulnerabilities early

**Checks:**
- Scan for vulnerable package versions
- Detect hardcoded secrets (API keys, passwords)
- Find insecure Random() usage
- Identify HTTP (non-HTTPS) URLs

**Pass Criteria:**
- No known vulnerabilities
- No hardcoded secrets
- No insecure code patterns

**Common Failures:**
- Hardcoded secrets → Move to environment variables
- Insecure Random → Use Random.secure()
- HTTP URLs → Change to HTTPS
- Vulnerable packages → Update dependencies

**Security Scan Examples:**
```bash
# Check for vulnerabilities locally
flutter pub outdated

# Scan for secrets
grep -r "apikey" --include="*.dart" lib/
grep -r "password\s*=" --include="*.dart" lib/

# Check for insecure patterns
grep -r "Random()" --include="*.dart" lib/ | grep -v "Random.secure()"
grep -r "http://" --include="*.dart" lib/
```

### Stage 5: Build (5-10 minutes)

**Purpose:** Verify application builds successfully

**Builds:**
- **Android APK** (develop branch)
- **Android AAB** (main branch for Play Store)
- **iOS IPA** (no codesign for CI)
- **Web** (CanvasKit renderer)

**Pass Criteria:**
- All builds complete without errors
- Build artifacts uploaded

**Common Failures:**
- Missing dependencies → Run `flutter pub get`
- Native build errors → Check platform-specific config
- Gradle/Xcode errors → Update build tools

**Build Flavors:**
```yaml
# android/app/build.gradle
flavorDimensions "environment"
productFlavors {
    dev {
        dimension "environment"
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
    }
    prod {
        dimension "environment"
    }
}
```

### Stage 6: Deploy (2-3 minutes, main only)

**Purpose:** Deploy to production or preview environment

**Deployment Types:**

#### Production Deployment (main branch)
- Triggers on push to `main`
- Deploys to Firebase Hosting live channel
- Full production build
- Available at: `https://your-project.web.app`

#### Preview Deployment (pull requests)
- Triggers on PR creation/update
- Deploys to temporary preview URL
- Expires after 7 days
- Available at: `https://your-project--pr-123-<hash>.web.app`

**Pass Criteria:**
- Deployment succeeds
- Site accessible
- No broken links or errors

**Common Failures:**
- Firebase auth failed → Check service account
- Build artifacts missing → Ensure build stage passed
- Routing errors → Check `firebase.json` rewrite rules

## Secrets Management

### Required Secrets

Configure in: **GitHub Repository Settings → Secrets and variables → Actions**

```bash
# Firebase secrets
FIREBASE_SERVICE_ACCOUNT    # Firebase service account JSON key
FIREBASE_PROJECT_ID         # Firebase project ID

# Auto-provided by GitHub
GITHUB_TOKEN               # For Firebase preview deployments
```

### Setting Up Firebase Service Account

1. **Go to Firebase Console:**
   - Select your project
   - Go to Project Settings → Service Accounts

2. **Generate private key:**
   - Click "Generate new private key"
   - Download JSON file

3. **Add to GitHub:**
   - Go to repository Settings → Secrets
   - Create new secret: `FIREBASE_SERVICE_ACCOUNT`
   - Paste entire JSON content

4. **Add Project ID:**
   - Create secret: `FIREBASE_PROJECT_ID`
   - Value: Your Firebase project ID

### Environment Variables in Code

**Never commit secrets to code.** Use environment variables:

```dart
// ❌ Bad - Hardcoded secret
const apiKey = 'sk_live_12345...';

// ✅ Good - Environment variable
const apiKey = String.fromEnvironment('API_KEY');

// Or using flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['API_KEY']!;
```

**Load environment variables:**
```dart
// main.dart
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

**`.env` file (never commit):**
```bash
API_KEY=your_key_here
API_SECRET=your_secret_here
```

**`.gitignore`:**
```
.env
.env.*
!.env.example
```

**`.env.example` (commit this):**
```bash
API_KEY=your_api_key_here
API_SECRET=your_api_secret_here
```

## Branch Protection Rules

### Main Branch

**Settings → Branches → Add branch protection rule**

```yaml
Branch name pattern: main

Protection rules:
  ✅ Require a pull request before merging
     ✅ Require approvals: 1
     ✅ Dismiss stale pull request approvals when new commits are pushed
     ✅ Require review from Code Owners

  ✅ Require status checks to pass before merging
     ✅ Require branches to be up to date before merging
     Required checks:
       - Code Quality
       - Code Generation
       - Unit & Widget Tests
       - Security Audit
       - Build Android
       - Build iOS
       - Build Web

  ✅ Require conversation resolution before merging

  ✅ Require linear history (optional)

  ✅ Include administrators (optional)

  ❌ Allow force pushes
  ❌ Allow deletions
```

### Develop Branch

Same as main, but:
- Can allow force pushes for emergency fixes (optional)
- May require fewer approvals (optional)

## Monitoring and Notifications

### GitHub Actions Dashboard

Monitor pipeline status:
- Go to repository → Actions tab
- View running/failed workflows
- Click on workflow for detailed logs
- Download artifacts (APK, AAB, reports)

### Setting Up Notifications

#### Slack Integration

Add to workflow:
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment to Firebase completed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
  if: always()
```

#### Discord Integration

```yaml
- name: Notify Discord
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    status: ${{ job.status }}
    title: "CI/CD Pipeline"
    description: "Build and deployment completed"
```

#### Email Notifications

GitHub sends automatic emails on:
- Workflow failures
- Required checks failed
- PR review requests

### Monitoring Deployment

**Firebase Hosting:**
- Console: `https://console.firebase.google.com`
- View deployments, rollback if needed
- Monitor usage and performance

**Uptime Monitoring:**
- Use external service (UptimeRobot, Pingdom)
- Monitor main URL
- Alert on downtime

## Performance Optimization

### Caching

The workflow uses caching to speed up builds:

```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      ${{ github.workspace }}/.dart_tool
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
```

**Speed improvements:**
- First run: ~15 minutes
- Cached run: ~8 minutes

### Parallel Jobs

Jobs run in parallel when possible:
```yaml
jobs:
  code-quality:
    # Runs independently

  test:
    needs: code-quality  # Waits for code-quality

  security:
    needs: code-quality  # Runs parallel with test

  build-android:
    needs: [test, security]  # Waits for both

  build-ios:
    needs: [test, security]  # Parallel with build-android
```

### Matrix Builds

For multiple Flutter versions:
```yaml
strategy:
  matrix:
    flutter-version: ['3.24.0', '3.22.0']

steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

## Troubleshooting

### Common Pipeline Failures

#### "Format check failed"
```bash
# Fix locally
dart format .
git add .
git commit -m "style: format code"
git push
```

#### "Analysis errors found"
```bash
# Check locally
flutter analyze

# Fix issues and commit
git commit -m "fix: address analysis issues"
```

#### "Tests failed"
```bash
# Run tests locally
flutter test

# Fix failing tests
# Commit fixes
git commit -m "test: fix failing tests"
```

#### "Coverage below 80%"
```bash
# Check coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# Add more tests to increase coverage
git commit -m "test: increase coverage to 82%"
```

#### "Security scan failed - secrets detected"
```bash
# Remove hardcoded secrets
# Use environment variables instead
# Commit changes
git commit -m "security: remove hardcoded secrets"
```

#### "Build failed - dependencies not found"
```bash
# Update dependencies
flutter pub get

# If using build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Commit generated files
git add .
git commit -m "build: update dependencies and generated files"
```

#### "Deployment failed - Firebase auth error"
```bash
# Verify secrets in GitHub repository settings
# Regenerate service account key if needed
# Update FIREBASE_SERVICE_ACCOUNT secret
```

### Debugging Failed Workflows

1. **View logs:**
   - Go to Actions tab
   - Click on failed workflow
   - Click on failed job
   - Expand failed step to see logs

2. **Download artifacts:**
   - Scroll to bottom of workflow run
   - Download artifacts for inspection

3. **Re-run workflow:**
   - Click "Re-run jobs" button
   - Select "Re-run failed jobs" or "Re-run all jobs"

4. **Test locally:**
```bash
# Simulate CI environment
docker run -it cirrusci/flutter:stable /bin/bash
cd /app
# Run same commands as CI
```

### Rollback Deployment

If deployment has issues:

1. **Firebase Console:**
   - Go to Hosting → Release history
   - Click on previous version
   - Click "Rollback"

2. **Via CLI:**
```bash
firebase hosting:channel:deploy previous --project your-project-id
```

3. **Via Git:**
```bash
# Revert the merge commit
git revert HEAD
git push origin main
# CI/CD will redeploy previous version
```

## Best Practices

### ✅ Do

- **Test locally** before pushing
- **Keep builds fast** (use caching, parallel jobs)
- **Monitor failures** and fix promptly
- **Update dependencies** regularly
- **Review security** scan results
- **Use branch protection** rules
- **Cache dependencies** for faster builds
- **Document changes** in commit messages

### ❌ Don't

- **Skip CI checks** (force push to main)
- **Commit secrets** to repository
- **Ignore test failures**
- **Deploy without review**
- **Leave failed builds** unattended
- **Disable security scans**
- **Merge without passing checks**
- **Hard-code** environment-specific values

## Metrics and KPIs

### Track These Metrics

```yaml
Pipeline Metrics:
  - Build success rate: Target >95%
  - Average build time: Target <15 minutes
  - Test coverage: Target ≥80%
  - Security issues: Target 0 critical/high
  - Deployment frequency: Track trend
  - Mean time to recovery: Target <1 hour
  - Change failure rate: Target <5%

Quality Metrics:
  - Code quality score: Track over time
  - Technical debt: Monitor and reduce
  - Bug escape rate: Target <2%
  - Test flakiness: Target <1%
```

### Dashboard

Create a dashboard to monitor:
- Build status (passing/failing)
- Test coverage trend
- Security vulnerabilities
- Deployment frequency
- Performance metrics

---

**Version:** 1.0
**Last Updated:** November 2024
**Related:** `git_workflow.md`, `dev-workflow/DEVELOPMENT_WORKFLOW.md`
