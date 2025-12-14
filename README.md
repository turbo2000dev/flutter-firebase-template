# Flutter + Firebase + Claude Code Template

A comprehensive project template for building Flutter applications with Firebase backend, Astro landing page, and Claude Code AI-assisted development workflow.

## What's Included

### Development Methodology
- **Claude Code Agents** - Specialized AI agents for architecture, development, testing, security, and more
- **Claude Code Commands** - Slash commands for planning, implementation, deployment, and code review
- **Weekly Development Workflow** - Structured Git workflow with quality gates
- **Git Hooks** - Automatic code formatting, linting, and testing on commit/push

### Architecture & Guidelines
- **Clean Architecture** - Feature-first organization with clear layer separation
- **State Management** - Riverpod 3.0 patterns with code generation
- **Coding Standards** - Comprehensive style guide with examples
- **Testing Strategy** - Testing pyramid with coverage requirements
- **Security Guidelines** - Best practices for secure development
- **Performance Guidelines** - Optimization strategies

### CI/CD Pipeline
- **Multi-Environment Deployment** - Dev, Staging, Production
- **GitHub Actions Workflows** - Automated testing, building, and deployment
- **Firebase Integration** - Hosting, Firestore, Functions, Storage

### Landing Page
- **Astro Integration** - SEO-optimized static landing page
- **Language Preference Sharing** - URL parameters with localStorage backup
- **Same-Origin Architecture** - Landing page and Flutter app on same domain

## Template Variables

The following placeholders are used throughout the template and must be replaced:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Snake_case project name | `my_app` |
| `{{PROJECT_NAME_UPPER}}` | UPPER_SNAKE_CASE project name | `MY_APP` |
| `{{PROJECT_DISPLAY_NAME}}` | Human-readable project name | `My Awesome App` |
| `{{PROJECT_DESCRIPTION}}` | Brief project description | `A mobile app for...` |
| `{{PROJECT_STATE}}` | Current development state | `Early development` |
| `{{TARGET_MARKET}}` | Target audience/region | `United States` |
| `{{TARGET_REGION}}` | Specific region if applicable | `California` |
| `{{FIREBASE_PROJECT_ID}}` | Firebase project ID | `my-app-12345` |
| `{{FIREBASE_STORAGE_BUCKET}}` | Firebase Storage bucket | `my-app-12345.appspot.com` |
| `{{PROD_DOMAIN}}` | Production domain | `myapp.com` |
| `{{DEV_DOMAIN}}` | Development domain | `dev.myapp.com` |
| `{{STAGING_DOMAIN}}` | Staging domain | `staging.myapp.com` |
| `{{DEV_URL}}` | Full dev URL | `https://my-app-dev.web.app` |
| `{{STAGING_URL}}` | Full staging URL | `https://my-app-staging.web.app` |
| `{{PROD_URL}}` | Full production URL | `https://my-app.web.app` |
| `{{GITHUB_USERNAME}}` | GitHub username/org | `myusername` |

## Quick Start

### 1. Create Your Flutter Project

```bash
flutter create my_app
cd my_app
```

### 2. Copy Template Files

```bash
# Clone this template
git clone https://github.com/YOUR_USERNAME/flutter-firebase-template.git /tmp/template

# Copy template files to your project
cp -r /tmp/template/.claude .
cp -r /tmp/template/guidelines .
cp -r /tmp/template/docs .
cp -r /tmp/template/scripts .
cp -r /tmp/template/.githooks .
cp -r /tmp/template/.github .

# Copy template files that need renaming
cp /tmp/template/CLAUDE.md.template ./CLAUDE.md
cp /tmp/template/firebase.json.template ./firebase.json
cp /tmp/template/.firebaserc.template ./.firebaserc
cp /tmp/template/.claude/settings.local.json.example ./.claude/settings.local.json
```

### 3. Initialize the Template

```bash
# Run the initialization script
./scripts/init-template.sh
```

Or manually replace all `{{VARIABLE}}` placeholders in the copied files.

### 4. Set Up Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (or use existing project)
firebase use --add

# Set up hosting targets
./scripts/setup-hosting-targets.sh
```

### 5. Set Up Git Hooks

```bash
./scripts/setup-git-hooks.sh
```

### 6. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

- `FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}}` - Firebase service account JSON
- `GOOGLE_SERVICES_JSON_BASE64` - Base64-encoded google-services.json
- `GOOGLE_SERVICE_INFO_PLIST_BASE64` - Base64-encoded GoogleService-Info.plist (iOS)
- `CODECOV_TOKEN` - (Optional) Codecov upload token

See `docs/ci-cd/secrets-setup.md` for detailed instructions.

### 7. Start Development

```bash
# Install dependencies
flutter pub get

# Start with Claude Code
/init
/plan-from-requirements <your requirements>
```

## Directory Structure

```
flutter-firebase-template/
├── .claude/
│   ├── agents/              # Claude Code specialized agents
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   ├── reviewer.md
│   │   ├── devops.md
│   │   ├── security.md
│   │   ├── performance.md
│   │   ├── astro-developer.md
│   │   └── python-developer.md
│   ├── commands/            # Claude Code slash commands
│   │   ├── plan.md
│   │   ├── execute-plan.md
│   │   ├── implement.md
│   │   ├── deploy.md
│   │   └── ...
│   └── settings.local.json.example
│
├── guidelines/              # Development guidelines
│   ├── architecture.md
│   ├── coding_standards.md
│   ├── testing_strategy.md
│   ├── deployment.md
│   ├── state_management.md
│   ├── security_guidelines.md
│   ├── performance.md
│   └── ...
│
├── docs/                    # Documentation
│   ├── development/
│   │   ├── CLAUDE-CODE-WORKFLOW.md
│   │   └── git-hooks.md
│   ├── ci-cd/
│   │   ├── weekly-workflow.md
│   │   ├── secrets-setup.md
│   │   └── ...
│   └── ...
│
├── scripts/                 # Build and deployment scripts
│   ├── build-all.sh
│   ├── deploy.sh
│   ├── setup-git-hooks.sh
│   ├── init-template.sh
│   └── ...
│
├── .githooks/               # Git hooks
│   ├── pre-commit
│   ├── pre-push
│   └── commit-msg
│
├── .github/workflows/       # CI/CD workflows
│   ├── ci.yml
│   ├── deploy-dev.yml
│   ├── deploy-staging.yml
│   └── deploy-prod.yml
│
├── CLAUDE.md.template       # Main Claude Code config template
├── firebase.json.template   # Firebase config template
├── .firebaserc.template     # Firebase project config template
└── README.md                # This file
```

## Development Workflow

### Using Claude Code

1. **Plan your feature**
   ```bash
   /plan-from-requirements Add user authentication with Google Sign-In
   ```

2. **Execute the plan**
   ```bash
   /execute-plan
   ```

3. **Deploy to development**
   ```bash
   /deploy dev
   ```

### Weekly Development Cycle

1. **Monday**: Create weekly branch from `main`
2. **Mon-Thu**: Develop with daily commits
3. **Friday**: Quality checks, checkpoint commit, PR
4. **Friday EOD**: Merge to `main`

See `docs/ci-cd/weekly-workflow.md` for details.

### Git Workflow

```bash
# Feature development
git checkout main && git pull
git checkout -b feature/my-feature

# Daily commits (auto-formatted!)
git add . && git commit -m "feat: Add feature"

# Promote through environments
develop → staging → main
```

See `docs/GIT_WORKFLOW.md` for complete branching strategy.

## Key Features

### Claude Code Agents

| Agent | Purpose |
|-------|---------|
| `architect` | Technical design and specification |
| `developer` | Flutter implementation |
| `tester` | Test strategy and implementation |
| `reviewer` | Code review and quality |
| `security` | Security audits |
| `performance` | Performance optimization |
| `devops` | CI/CD and deployment |
| `astro-developer` | Landing page development |
| `python-developer` | Cloud Functions development |

### Claude Code Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Create development plan |
| `/execute-plan` | Execute existing plan |
| `/implement` | Implement a feature |
| `/deploy` | Deploy to environment |
| `/code-review` | Review code quality |
| `/security-audit` | Run security audit |
| `/test-audit` | Audit test coverage |

### Quality Automation

- **Pre-commit**: Auto-format, analyze, run affected tests
- **Pre-push**: Run full test suite, check coverage
- **Commit-msg**: Enforce conventional commits
- **CI/CD**: Full pipeline on every push

## Documentation

**Start here:** [Documentation Hub](./docs/README.md) - Central navigation for all documentation.

### Quick Links

| Category | Key Documents |
|----------|---------------|
| **Getting Started** | [Documentation Hub](./docs/README.md) · [Claude Code Workflow](./docs/development/CLAUDE-CODE-WORKFLOW.md) |
| **Development** | [Git Hooks](./docs/development/git-hooks.md) · [Weekly Workflow](./docs/ci-cd/weekly-workflow.md) |
| **CI/CD** | [Secrets Setup](./docs/ci-cd/secrets-setup.md) · [Firebase Deployment](./docs/ci-cd/firebase-deployment.md) |
| **Architecture** | [Architecture Guide](./guidelines/architecture.md) · [Astro Integration](./docs/Astro%20Flutter%20Integration.md) |
| **Code Quality** | [Coding Standards](./guidelines/coding_standards.md) · [Testing Strategy](./guidelines/testing_strategy.md) |
| **Operations** | [Deployment Guide](./guidelines/deployment.md) · [Git Workflow](./docs/GIT_WORKFLOW.md) |

### Guidelines Reference

All development guidelines are in the `/guidelines/` directory:

- `architecture.md` - Clean architecture patterns
- `coding_standards.md` - Style guide and conventions
- `state_management.md` - Riverpod 3.0 patterns
- `testing_strategy.md` - Testing pyramid and examples
- `security_guidelines.md` - Security best practices
- `performance.md` - Optimization strategies
- `deployment.md` - Multi-environment deployment
- `environments.md` - Environment configuration
- `astro-development.md` - Landing page development

## Requirements

- Flutter 3.x+
- Node.js 20+
- Python 3.12+ (for Cloud Functions)
- Firebase CLI
- GitHub CLI (recommended)

## License

MIT License - Use freely for your projects.

## Contributing

Contributions welcome! Please read the guidelines before submitting PRs.

---

**Created with Claude Code** - AI-assisted development for the modern era.
