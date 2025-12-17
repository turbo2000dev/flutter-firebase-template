# Deploy Command

Deploy the application to a Firebase Hosting environment.

## Usage

```
/deploy <environment>
```

Where `<environment>` is one of:
- `dev` - Development environment
- `staging` - Staging/QA environment

## Production Deployment

**Do NOT use `/deploy prod`** - Production is deployed automatically via CI when you push to main.

Use the promotion workflow instead:
```bash
/promote main    # Merges dev → main, CI auto-deploys to production
```

This ensures:
- Tests run in CI before deployment
- Consistent build environment
- Deployment tags and summaries
- No local build inconsistencies

## Process (dev/staging only)

1. **Build**
   - Build Astro landing page (if exists)
   - Build Flutter web app with `--base-href /app/`
   - Combine into `public/` directory

2. **Deploy**
   - Deploy to Firebase Hosting target

3. **Post-deployment verification**
   - Provide checklist for manual verification

## Commands Used

```bash
# Build all components
./scripts/build-all.sh <env>

# Deploy to Firebase
./scripts/deploy.sh <env>
```

## Environment URLs

| Environment | Landing Page                              | Flutter App                                   | Deploy Method |
| ----------- | ----------------------------------------- | --------------------------------------------- | ------------- |
| dev         | https://{{DEV_URL}}                       | https://{{DEV_URL}}/app                       | `/deploy dev` |
| staging     | https://{{PROJECT_NAME}}-staging.web.app  | https://{{PROJECT_NAME}}-staging.web.app/app  | `/promote staging` or `/deploy staging` |
| prod        | https://{{FIREBASE_PROJECT_ID}}.web.app   | https://{{FIREBASE_PROJECT_ID}}.web.app/app   | `/promote main` (CI auto-deploys) |

## Notes

- **Production:** Always use `/promote main` - CI handles build and deploy
- The `--base-href /app/` flag is essential for Flutter assets to load correctly
- Use `--skip-build` if you've already built and just want to deploy
- Add `--functions` to also deploy Cloud Functions
- Add `--rules` to also deploy Firestore rules
