# Multi-Environment Setup Guide

## Overview

This project supports three deployment environments:
- **Development (dev)**: For active development and testing
- **Staging (staging)**: For QA, user acceptance testing, and pre-production validation
- **Production (prod)**: Live application serving real users

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Firebase Project: {{PROJECT_NAME}}                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │   dev site      │  │  staging site   │  │   prod site     │     │
│  │                 │  │                 │  │                 │     │
│  │ dev.example.com │  │ staging.example │  │ app.example.com │     │
│  │                 │  │    .com         │  │                 │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Cloud Functions (Python)                  │   │
│  │  - Excel export                                              │   │
│  │  - Future backend services                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      Firestore Database                      │   │
│  │  - User data                                                 │   │
│  │  - Projects, scenarios, projections                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Environment Configuration

### Firebase Hosting Targets

We use Firebase Hosting "targets" to deploy different sites within the same project:

```bash
# .firebaserc defines the targets
{
  "projects": {
    "default": "{{FIREBASE_PROJECT_ID}}"
  },
  "targets": {
    "{{FIREBASE_PROJECT_ID}}": {
      "hosting": {
        "dev": ["retirement-dev"],
        "staging": ["{{PROJECT_NAME}}-staging"],
        "prod": ["{{FIREBASE_PROJECT_ID}}"]
      }
    }
  }
}
```

### Environment URLs

| Environment | URL                                      | Purpose                             |
| ----------- | ---------------------------------------- | ----------------------------------- |
| Development | `https://{{DEV_URL}}`         | Active development, feature testing |
| Staging     | `https://{{PROJECT_NAME}}-staging.web.app` | QA, UAT, pre-release validation     |
| Production  | `https://{{FIREBASE_PROJECT_ID}}.web.app`   | Live users                          |

### Custom Domains (Optional)

Configure custom domains in Firebase Console:
- `dev.retraite.app` → dev site
- `staging.retraite.app` → staging site
- `app.retraite.app` or `retraite.app` → prod site

## Git Branch to Environment Mapping

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   develop    │────▶│    dev       │     │ Development  │
│   branch     │     │  environment │     │   testing    │
└──────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   staging    │────▶│   staging    │     │   QA/UAT     │
│   branch     │     │  environment │     │   testing    │
└──────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    main      │────▶│    prod      │     │    Live      │
│   branch     │     │  environment │     │   users      │
└──────────────┘     └──────────────┘     └──────────────┘
```

### Branch Strategy

| Branch      | Auto-Deploy To | Manual Deploy To         |
| ----------- | -------------- | ------------------------ |
| `develop`   | dev            | staging (on demand)      |
| `staging`   | staging        | -                        |
| `main`      | -              | prod (requires approval) |
| `feature/*` | -              | dev (on demand)          |
| `week/*`    | -              | dev (on demand)          |

**Note:** Production deployments from `main` require manual approval via GitHub Actions.

## Configuration Files

### Environment-Specific Flutter Configuration

Create environment-specific Dart configuration:

```dart
// lib/core/config/environment.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool showDebugBanner;

  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.enableAnalytics,
    required this.enableCrashlytics,
    required this.showDebugBanner,
  });

  static const dev = EnvironmentConfig._(
    environment: Environment.dev,
    apiBaseUrl: 'https://us-central1-{{FIREBASE_PROJECT_ID}}.cloudfunctions.net',
    firebaseProjectId: '{{FIREBASE_PROJECT_ID}}',
    enableAnalytics: false,
    enableCrashlytics: false,
    showDebugBanner: true,
  );

  static const staging = EnvironmentConfig._(
    environment: Environment.staging,
    apiBaseUrl: 'https://us-central1-{{FIREBASE_PROJECT_ID}}.cloudfunctions.net',
    firebaseProjectId: '{{FIREBASE_PROJECT_ID}}',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugBanner: false,
  );

  static const prod = EnvironmentConfig._(
    environment: Environment.prod,
    apiBaseUrl: 'https://us-central1-{{FIREBASE_PROJECT_ID}}.cloudfunctions.net',
    firebaseProjectId: '{{FIREBASE_PROJECT_ID}}',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugBanner: false,
  );

  static EnvironmentConfig get current {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    switch (env) {
      case 'staging':
        return staging;
      case 'prod':
        return prod;
      default:
        return dev;
    }
  }
}
```

### Build Commands by Environment

```bash
# Development build
flutter build web --dart-define=ENVIRONMENT=dev

# Staging build
flutter build web --dart-define=ENVIRONMENT=staging

# Production build
flutter build web --release --dart-define=ENVIRONMENT=prod
```

## Deployment Commands

### Manual Deployment

```bash
# Deploy to development
./scripts/deploy.sh dev

# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production (requires confirmation)
./scripts/deploy.sh prod
```

### Automated Deployment (GitHub Actions)

Deployments are triggered automatically:
- Push to `develop` → deploys to dev
- Push to `staging` → deploys to staging
- Manual trigger with approval → deploys to prod

## Environment Variables and Secrets

### GitHub Actions Secrets

Configure in: **Settings → Secrets and variables → Actions**

```
FIREBASE_SERVICE_ACCOUNT     # Service account JSON for deployment
FIREBASE_PROJECT_ID          # {{FIREBASE_PROJECT_ID}}
```

### Local Development

Create `.env.local` (never commit):
```bash
ENVIRONMENT=dev
FIREBASE_PROJECT_ID={{FIREBASE_PROJECT_ID}}
```

## Database Considerations

### Single Firestore Database

Currently, all environments share a single Firestore database. Data is logically separated by:
- User authentication (users only see their own data)
- Firestore security rules

### Future: Separate Databases

For stronger isolation, consider:
1. Separate Firebase projects per environment
2. Or use Firestore in Datastore mode with namespaces
3. Or prefix collection names with environment (not recommended)

## Feature Flags

Use environment-aware feature flags:

```dart
class FeatureFlags {
  static bool get showBetaFeatures {
    return EnvironmentConfig.current.environment != Environment.prod;
  }

  static bool get enableExperimentalGraphs {
    return EnvironmentConfig.current.environment == Environment.dev;
  }
}
```

## Monitoring by Environment

### Logging Levels

| Environment | Log Level | Crash Reporting |
| ----------- | --------- | --------------- |
| dev         | verbose   | disabled        |
| staging     | info      | enabled         |
| prod        | warning   | enabled         |

### Analytics

- **dev**: Disabled to avoid polluting data
- **staging**: Enabled for testing analytics setup
- **prod**: Full analytics enabled

## Best Practices

### Do

- Always test in staging before deploying to prod
- Use feature flags for incomplete features
- Monitor staging deployments before prod promotion
- Keep environment configurations in sync
- Document environment-specific behaviors

### Don't

- Deploy directly to prod without staging validation
- Hardcode environment-specific values
- Share API keys across environments (future)
- Skip testing in lower environments
- Ignore staging failures before prod deployment

## Troubleshooting

### "Wrong environment deployed"

1. Check the deployment target in the script/action
2. Verify `.firebaserc` targets are correct
3. Check GitHub Actions workflow trigger conditions

### "Features missing in prod"

1. Check feature flags configuration
2. Verify build was done with correct `--dart-define`
3. Check environment detection in the app

### "Data not syncing between environments"

This is expected behavior - environments may use different data stores (future).
For shared Firestore, check user authentication and security rules.

---

**Version:** 1.0
**Last Updated:** December 2024
**Related:** `deployment.md`, `cicd.md`
