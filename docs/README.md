# Documentation

This directory contains all project documentation, organized into two main categories:

## Directory Structure

```
docs/
├── README.md           # This file - documentation overview
├── framework/          # Framework/template documentation (DO NOT MODIFY for project)
│   ├── README.md       # Framework documentation hub
│   ├── development/    # Development workflow and tools
│   ├── ci-cd/          # CI/CD and deployment guides
│   └── testing/        # Testing strategies and coverage
└── [project-dirs]/     # Project-specific documentation (create as needed)
```

## Documentation Categories

### Framework Documentation (`docs/framework/`)

**Purpose:** Reference documentation for the Flutter-Firebase template framework.

**Contains:**
- Development workflows and Claude Code integration
- CI/CD pipeline configuration and deployment guides
- Testing strategies and coverage requirements
- Git workflow and branching strategies

**Important:** These files are part of the template and should not be modified for project-specific content. They serve as reference documentation for how to use the framework.

**See:** [Framework Documentation Hub](./framework/README.md)

### Project Documentation (`docs/` - root level)

**Purpose:** Documentation specific to your project, generated during development.

**Create directories as needed:**
- `docs/api/` - API documentation
- `docs/architecture/` - Architecture Decision Records (ADRs)
- `docs/features/` - Feature specifications and designs
- `docs/specs/` - Technical specifications
- `docs/guides/` - User guides and tutorials
- `docs/releases/` - Release notes and changelogs

**Guidelines:**
- Organize logically by topic or feature
- Use clear, descriptive directory and file names
- Keep documentation close to what it describes
- Update documentation when code changes

## Quick Reference

| Need | Location |
|------|----------|
| How to use Claude Code | `docs/framework/development/CLAUDE-CODE-WORKFLOW.md` |
| Git hooks setup | `docs/framework/development/git-hooks.md` |
| Weekly workflow | `docs/framework/ci-cd/weekly-workflow.md` |
| Deployment guide | `docs/framework/ci-cd/firebase-deployment.md` |
| Coverage requirements | `docs/framework/testing/COVERAGE_QUICK_REF.md` |
| Architecture guidelines | `guidelines/architecture.md` |
| Coding standards | `guidelines/coding_standards.md` |

## Related Documentation

- **Guidelines** (`guidelines/`) - Coding standards, architecture patterns, and best practices
- **CLAUDE.md** - Quick reference for Claude Code integration
- **PLAN.md** - Development plan (created during `/plan` workflow)
