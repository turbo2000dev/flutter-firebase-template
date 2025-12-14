# Deploy Command

Deploy the application to a Firebase Hosting environment.

## Usage

```
/deploy <environment>
```

Where `<environment>` is one of:
- `dev` - Development environment
- `staging` - Staging/QA environment
- `prod` - Production environment

## Process

1. **Pre-deployment checks** (prod only)
   - Run `flutter analyze` to ensure no issues
   - Run `flutter test` to verify all tests pass

2. **Build**
   - Build Astro landing page (if exists)
   - Build Flutter web app with `--base-href /app/`
   - Combine into `public/` directory

3. **Deploy**
   - Deploy to Firebase Hosting target

4. **Post-deployment verification**
   - Provide checklist for manual verification

## Commands Used

```bash
# Build all components
./scripts/build-all.sh <env>

# Deploy to Firebase
./scripts/deploy.sh <env>
```

## Environment URLs

| Environment | Landing Page                           | Flutter App                                |
| ----------- | -------------------------------------- | ------------------------------------------ |
| dev         | https://{{DEV_URL}}         | https://{{DEV_URL}}/app         |
| staging     | https://{{PROJECT_NAME}}-staging.web.app | https://{{PROJECT_NAME}}-staging.web.app/app |
| prod        | https://{{FIREBASE_PROJECT_ID}}.web.app   | https://{{FIREBASE_PROJECT_ID}}.web.app/app   |

## Notes

- Production deployments require explicit confirmation
- The `--base-href /app/` flag is essential for Flutter assets to load correctly
- Use `--skip-build` if you've already built and just want to deploy
- Add `--functions` to also deploy Cloud Functions
- Add `--rules` to also deploy Firestore rules
