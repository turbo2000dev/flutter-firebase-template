# Framework Documentation Hub

This directory contains the **framework/template documentation** for building Flutter applications with Firebase backend, Astro landing page, and Claude Code AI-assisted development.

**Note:** This is framework reference documentation. For project-specific documentation, see `docs/` (parent directory).

---

## Overview

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter 3.x | Cross-platform mobile & web app |
| **Landing Page** | Astro | SEO-optimized static site |
| **Backend** | Firebase | Auth, Firestore, Storage, Functions |
| **State Management** | Riverpod 3.0 | Reactive state with code generation |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **AI Assistant** | Claude Code | AI-powered development workflow |

### Architecture Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│                    User-Facing Layer                         │
│  ┌─────────────────┐              ┌─────────────────────┐   │
│  │  Astro Landing  │              │    Flutter App      │   │
│  │  (SEO-optimized)│──────────────│  (Feature-rich SPA) │   │
│  └─────────────────┘              └─────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                    Firebase Services                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │   Auth   │  │ Firestore│  │ Storage  │  │ Functions│    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────┘
```

**Key Principles:**
- **Clean Architecture** - Feature-first organization with clear layer separation
- **Offline-First** - Local cache with background sync
- **SEO-Optimized** - Static landing page for discoverability
- **Multi-Environment** - Dev → Staging → Production pipeline

---

## Quick Reference

### Essential Commands

#### Daily Development
```bash
# Start development
flutter pub get                    # Install dependencies
flutter run                        # Run app locally
flutter run -d chrome              # Run on Chrome (web)

# Code generation (after modifying Freezed/Riverpod files)
flutter pub run build_runner build --delete-conflicting-outputs

# Quality checks
flutter analyze                    # Static analysis
flutter test                       # Run all tests
dart fix --apply                   # Auto-fix issues
```

#### Deployment
```bash
# Deploy to environments
./scripts/deploy.sh dev            # Deploy to development
./scripts/deploy.sh staging        # Deploy to staging
./scripts/deploy.sh prod           # Deploy to production (requires confirmation)

# Deploy specific components
./scripts/deploy.sh dev --functions    # Deploy Cloud Functions only
./scripts/deploy.sh dev --rules        # Deploy Firestore rules only
./scripts/deploy.sh dev --all          # Deploy everything

# Build all components
./scripts/build-all.sh dev         # Build landing page + Flutter app
```

#### Testing & Coverage
```bash
flutter test                       # Run all tests
flutter test --coverage            # Run with coverage
python3 scripts/coverage-report.py # Analyze coverage (excludes generated files)
python3 scripts/coverage-report.py --ci  # CI mode (fails if < 80%)
```

#### Landing Page (Astro)
```bash
cd landing-page
npm install                        # Install dependencies
npm run dev                        # Start dev server (localhost:4321)
npm run build                      # Build for production
```

### Claude Code Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/plan-from-requirements` | Create implementation plan | Starting new features |
| `/execute-plan` | Execute approved plan | After plan approval |
| `/implement` | Implement specific feature | Direct implementation |
| `/deploy` | Deploy to environment | Ready for deployment |
| `/code-review` | Review code quality | Before merging |
| `/security-audit` | Run security audit | Before releases |
| `/test-audit` | Audit test coverage | Improving coverage |

### Git Workflow

```bash
# Start new work (from main)
git checkout main && git pull
git checkout -b feature/my-feature

# Daily commits (auto-formatted by hooks!)
git add . && git commit -m "feat: Add feature"

# Push triggers CI
git push origin feature/my-feature

# Promote through environments
git checkout develop && git merge feature/my-feature && git push  # → Dev
git checkout staging && git merge develop && git push              # → Staging
git checkout main && git merge staging && git push                 # → Prod
```

---

## Development Methodology

### Weekly Development Cycle

| Day | Activity |
|-----|----------|
| **Monday** | Create weekly branch, plan sprint |
| **Tue-Thu** | Development with daily commits |
| **Friday** | Quality checks, checkpoint commit, PR |
| **Friday EOD** | Merge to main after CI passes |

### Quality Gates

Every commit/push goes through automated checks:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Pre-Commit    │────▶│    Pre-Push     │────▶│    CI/CD        │
│                 │     │                 │     │                 │
│ ✓ Auto-format   │     │ ✓ Full tests    │     │ ✓ All tests     │
│ ✓ Lint check    │     │ ✓ Coverage warn │     │ ✓ Coverage ≥80% │
│ ✓ Affected tests│     │                 │     │ ✓ Build all     │
└─────────────────┘     └─────────────────┘     │ ✓ Security scan │
                                                └─────────────────┘
```

### Coverage Requirements

| Layer | Target | Rationale |
|-------|--------|-----------|
| **Overall** | ≥80% | Baseline quality |
| **Critical Business Logic** | 100% | Prevents costly bugs |
| **Domain Layer** | ≥95% | Core functionality |
| **Data Layer** | ≥90% | Data integrity |
| **Presentation** | ≥70% | UI flexibility |

---

## CI/CD Pipeline

### Environments

| Environment | Branch | URL | Deployment |
|-------------|--------|-----|------------|
| **Development** | `develop` | {{DEV_URL}} | Auto on push |
| **Staging** | `staging` | {{STAGING_URL}} | Auto on push |
| **Production** | `main` | {{PROD_URL}} | Manual trigger |

### Pipeline Stages

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Lint &  │───▶│   Test   │───▶│  Build   │───▶│  Deploy  │
│ Analyze  │    │          │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │
     ▼               ▼               ▼               ▼
 dart format    flutter test    flutter build   firebase deploy
 flutter analyze  coverage      astro build
```

### Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] Coverage ≥80%
- [ ] No security vulnerabilities
- [ ] Staging tested and approved
- [ ] CHANGELOG updated
- [ ] Version bumped

---

## Documentation Index

### Development

| Document | Description |
|----------|-------------|
| [Claude Code Workflow](./development/CLAUDE-CODE-WORKFLOW.md) | How to use Claude Code agents and commands |
| [Git Hooks](./development/git-hooks.md) | Pre-commit, pre-push hooks setup |

### CI/CD

| Document | Description |
|----------|-------------|
| [Weekly Workflow](./ci-cd/weekly-workflow.md) | Weekly development cycle guide |
| [Code Quality](./ci-cd/CODE_QUALITY.md) | Quality standards and automation |
| [Secrets Setup](./ci-cd/secrets-setup.md) | GitHub secrets configuration |
| [Firebase Deployment](./ci-cd/firebase-deployment.md) | Firebase CI/CD deployment |
| [Deployment Checklist](./ci-cd/deployment-checklist.md) | Pre-deployment checklist |

### Testing

| Document | Description |
|----------|-------------|
| [Coverage Quick Ref](./testing/COVERAGE_QUICK_REF.md) | Coverage commands and targets |

### Architecture

| Document | Description |
|----------|-------------|
| [Git Workflow](./GIT_WORKFLOW.md) | Git branching strategy (dev → staging → prod) |
| [Astro Flutter Integration](./Astro%20Flutter%20Integration.md) | Landing page + Flutter architecture |

### Guidelines (in `/guidelines/`)

| Document | Description |
|----------|-------------|
| [Architecture](../../guidelines/architecture.md) | Clean architecture patterns |
| [Coding Standards](../../guidelines/coding_standards.md) | Style guide and conventions |
| [State Management](../../guidelines/state_management.md) | Riverpod 3.0 patterns |
| [Testing Strategy](../../guidelines/testing_strategy.md) | Testing pyramid and examples |
| [Security](../../guidelines/security_guidelines.md) | Security best practices |
| [Performance](../../guidelines/performance.md) | Optimization strategies |
| [Deployment](../../guidelines/deployment.md) | Multi-environment deployment |
| [Environments](../../guidelines/environments.md) | Environment configuration |

---

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/deploy.sh` | Deploy to environment | `./scripts/deploy.sh <env> [--flags]` |
| `scripts/build-all.sh` | Build all components | `./scripts/build-all.sh <env>` |
| `scripts/setup-git-hooks.sh` | Configure git hooks | `./scripts/setup-git-hooks.sh` |
| `scripts/format-code.sh` | Format and fix code | `./scripts/format-code.sh` |
| `scripts/check-code-quality.sh` | Run all quality checks | `./scripts/check-code-quality.sh` |
| `scripts/coverage-report.py` | Analyze test coverage | `python3 scripts/coverage-report.py` |
| `scripts/setup-hosting-targets.sh` | Setup Firebase hosting | `./scripts/setup-hosting-targets.sh` |

---

## Claude Code Agents

Specialized AI agents for different development tasks:

| Agent | Purpose | Invoke With |
|-------|---------|-------------|
| **architect** | Technical design, system architecture | Complex feature planning |
| **developer** | Flutter implementation | Feature development |
| **tester** | Test strategy, test implementation | Improving coverage |
| **reviewer** | Code review, quality assessment | Pre-merge review |
| **security** | Security audits, vulnerability checks | Security reviews |
| **performance** | Performance optimization | Performance issues |
| **devops** | CI/CD, deployment, infrastructure | Pipeline issues |
| **astro-developer** | Landing page development | Landing page work |
| **python-developer** | Cloud Functions development | Backend functions |

---

## Getting Started

### New to this project?

1. **Read the [Claude Code Workflow](./development/CLAUDE-CODE-WORKFLOW.md)** - Understand how to use AI-assisted development
2. **Set up [Git Hooks](./development/git-hooks.md)** - Enable automatic quality checks
3. **Review [Architecture](../../guidelines/architecture.md)** - Understand the codebase structure
4. **Check [Coding Standards](../../guidelines/coding_standards.md)** - Follow the style guide

### Starting a new feature?

1. Use `/plan-from-requirements` to create a plan
2. Review and approve the plan
3. Use `/execute-plan` to implement
4. Run tests and quality checks
5. Deploy to dev for testing
6. Promote through staging to production

### Need help?

- **Documentation**: Check this hub and linked docs
- **Guidelines**: See `/guidelines/` for detailed guidance
- **Claude Code**: Ask Claude for help with any task

---

**Last Updated:** December 2024
**Version:** 1.0
