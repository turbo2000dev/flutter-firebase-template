# Build All Command

Build all application components for deployment.

## Usage

```
/build-all <environment>
```

Where `<environment>` is one of:
- `dev` - Development build (debug mode)
- `staging` - Staging build
- `prod` - Production build (release mode, optimized)

## Process

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

## Output Structure

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

## Commands

```bash
# Development build
./scripts/build-all.sh dev

# Staging build
./scripts/build-all.sh staging

# Production build (optimized)
./scripts/build-all.sh prod
```

## Build Flags by Environment

| Environment | Mode | Optimization | Debug Banner |
|-------------|------|--------------|--------------|
| dev | debug | none | shown |
| staging | debug | none | hidden |
| prod | release | full | hidden |

## Notes

- Always build before deploying to ensure consistency
- The script creates a placeholder landing page if `landing-page/` doesn't exist
- Production builds take longer due to optimization
