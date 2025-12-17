# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **template repository** for building Flutter applications with Firebase backend, Astro landing page, and Claude Code AI-assisted development. It provides guidelines, agents, commands, and CI/CD workflows - no actual Flutter or app code.

**Purpose:** Clone/copy these files into a new Flutter project to set up architecture, tooling, and workflows.

## Essential Commands

### Template Setup (Use Once)
```bash
# After copying template files to your Flutter project:
./scripts/init-template.sh          # Replace {{VARIABLE}} placeholders
./scripts/setup-git-hooks.sh        # Configure pre-commit/pre-push hooks
./scripts/setup-hosting-targets.sh  # Initialize Firebase hosting targets
```

### Flutter Development
```bash
flutter pub get                                                    # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs   # Code generation (Riverpod, Freezed, JSON)
flutter pub run build_runner watch --delete-conflicting-outputs   # Watch mode for code generation
flutter run                                                        # Run app
flutter test                                                       # Run all tests
flutter test --coverage                                            # Generate coverage
python3 scripts/coverage-report.py                                 # Analyze coverage (excludes generated files)
flutter analyze                                                    # Static analysis
dart fix --apply                                                   # Auto-fix lint issues
```

### Building & Deployment
```bash
./scripts/build-all.sh <env>              # Build landing page + Flutter (dev|staging|prod)
./scripts/deploy.sh <env>                 # Deploy to environment
./scripts/deploy.sh <env> --functions     # Deploy with Cloud Functions
./scripts/deploy.sh <env> --all           # Deploy everything
```

### Landing Page (Astro)
```bash
cd landing-page && npm install && npm run dev   # Start dev server (localhost:4321)
npm run build                                    # Build for production
```

### Cloud Functions (Python)
```bash
cd functions
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
firebase emulators:start --only functions       # Test locally
firebase deploy --only functions                # Deploy
```

## Architecture

### High-Level Structure

The template enforces **Clean Architecture** with **feature-first** organization:

```
lib/
├── core/                    # Shared utilities, config, theme, router, widgets
└── features/                # Feature modules
    └── feature_name/
        ├── domain/          # Entities, use cases, repository interfaces
        ├── data/            # Repository implementations, DTOs, data sources
        ├── application/     # Riverpod providers, controllers, state
        └── presentation/    # Screens, widgets, UI components
```

### Multi-Component Architecture

```
project/
├── lib/                     # Flutter app (main codebase)
├── landing-page/            # Astro static site (SEO-optimized entry point)
├── functions/               # Firebase Cloud Functions (Python 3.12+)
└── test/                    # Tests mirroring lib/ structure
```

### Web Deployment Architecture
- `/` → Astro landing page (static HTML, SEO-friendly)
- `/app/` → Flutter web application

### State Management: Riverpod 3.0

Provider types and when to use them:
- `@riverpod` → Read-only computed values
- `@riverpod FutureProvider` → Async data fetching
- `@riverpod StreamProvider` → Real-time data (Firestore streams)
- `@riverpod NotifierProvider` → Synchronous state with mutations
- `@riverpod AsyncNotifierProvider` → Async state with mutations

All state classes must use **Freezed** for immutability.

### Data Flow
```
User Action → Provider → Use Case → Repository → Data Source
     ↓                                    ↓
UI Update  ←  State  ←  Domain Model  ←  DTO
```

## Code Generation

When you see these annotations, run `build_runner`:
- `@freezed` - Immutable classes
- `@riverpod` - Providers
- `@JsonSerializable` - JSON serialization

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

### Coverage Requirements
- **Overall:** 80% minimum
- **Domain layer:** 95%
- **Data layer:** 90%
- **Presentation:** 70%

### Running Coverage Analysis
```bash
flutter test --coverage
python3 scripts/coverage-report.py      # Excludes *.g.dart, *.freezed.dart
python3 scripts/coverage-report.py --ci # Fails if below 80%
```

**Important:** Never use raw `lcov.info` output - always use the coverage script which excludes generated files.

## Claude Code Integration

### Agents (`.claude/agents/`)
| Agent | Purpose |
|-------|---------|
| architect | Technical design, specifications |
| developer | Flutter implementation |
| python-developer | Cloud Functions (Python) |
| astro-developer | Landing page (Astro) |
| tester | Test strategy and implementation |
| reviewer | Code review |
| security | Security audits |
| performance | Performance optimization |
| devops | CI/CD and deployment |

### Commands (`.claude/commands/`)

**Workflow Commands (Development Cycle):**
- `/start-dev` - Start new feature development in a weekly branch (from `dev`)
- `/commit` - Commit changes with proper conventional commit message
- `/start-pr` - Run quality checks, create PR, and merge to `dev`
- `/promote` - Promote code to staging, main, or production

**Planning & Implementation:**
- `/plan [section-name]` - Create development plan (with optional section name)
- `/plan-from-requirements [section-name] [file]` - Create plan from requirements file
- `/execute-plan [section-name]` - Execute plan from PLAN.md (one section at a time)
- `/implement` - Implement a feature
- `/new-feature` - Full feature development workflow

**Section-Based Planning:**
Plans are organized into sections for incremental execution (one section at a time):
```bash
/plan authentication                    # Create plan with section name
/execute-plan authentication            # Execute specific section
/execute-plan                           # Execute next pending section (auto-selects)
```

**Build & Deploy:**
- `/deploy` - Deploy to environment
- `/build-all` - Build all components

**Quality Assurance:**
- `/code-review` - Review code quality
- `/security-audit` - Security analysis
- `/test-audit` - Test coverage audit

## Key Guidelines References

| File | Purpose |
|------|---------|
| `guidelines/architecture.md` | Layer architecture, data flow, patterns |
| `guidelines/state_management.md` | Riverpod 3.0 patterns with examples |
| `guidelines/coding_standards.md` | Naming, formatting, documentation |
| `guidelines/testing_strategy.md` | Test pyramid, coverage, CI setup |
| `guidelines/planning.md` | Plan-based development, sections, PLAN.md |
| `guidelines/astro-development.md` | Landing page development |
| `guidelines/deployment.md` | Multi-environment deployment |

## Environments

| Environment | Branch | Auto-Deploy | Promotion Command |
|-------------|--------|-------------|-------------------|
| Development | `dev` | No | N/A (merge via PR) |
| Staging | `staging` | Yes (on push) | `/promote staging` |
| Production | `main` | Yes (on push) | `/promote main` |

## Git Workflow

### Branch Flow
```
dev/YYYY-WW-* (feature) → dev (integration) → staging (UAT)
                                            → main (production)
```

### Development Cycle
1. `/start-dev <description>` - Create `dev/YYYY-WW-<description>` branch from `dev`
2. Develop, commit, push daily
3. `/start-pr` - Run checks, create PR to `dev`, merge
4. `/promote staging` - (Optional) Deploy to staging for UAT
5. `/promote main` - Deploy to production

### Hooks
- **Pre-commit:** Auto-format, lint, run affected tests
- **Pre-push:** Full test suite, coverage check
- **Commit messages:** Conventional commits (`feat:`, `fix:`, `docs:`, etc.)

## Template Variables

Replace these placeholders when initializing:
- `{{PROJECT_NAME}}` - snake_case project name
- `{{PROJECT_DISPLAY_NAME}}` - Human-readable name
- `{{FIREBASE_PROJECT_ID}}` - Firebase project ID
- `{{PROD_DOMAIN}}`, `{{DEV_DOMAIN}}`, `{{STAGING_DOMAIN}}` - Domain names

Run `./scripts/init-template.sh` to replace all variables interactively.
