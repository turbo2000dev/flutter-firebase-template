# Git Workflow: Dev → Staging → Prod

This document describes the branching and promotion workflow for the {{PROJECT_DISPLAY_NAME}} project.

## Branch Structure

| Branch | Environment | URL | Purpose |
|--------|-------------|-----|---------|
| `develop` | Development | dev.{{PROD_DOMAIN}} | Active development, testing new features |
| `staging` | Staging | staging.{{PROD_DOMAIN}} | Pre-production testing, QA |
| `main` | Production | {{PROD_DOMAIN}} | Live production environment |

## Workflow Overview

```
feature/xxx → develop → staging → main
                ↓          ↓        ↓
              [DEV]    [STAGING]  [PROD]
```

---

## 1. Start New Work

Always create feature branches from `main` to ensure you start with production-stable code.

```bash
# Make sure you're on main and up-to-date
git checkout main
git pull origin main

# Create a feature branch
git checkout -b feature/my-new-feature
```

### Branch Naming Conventions

- `feature/` - New features (e.g., `feature/add-dark-mode`)
- `fix/` - Bug fixes (e.g., `fix/login-error`)
- `hotfix/` - Urgent production fixes (e.g., `hotfix/critical-security-fix`)
- `refactor/` - Code refactoring (e.g., `refactor/optimize-queries`)
- `docs/` - Documentation updates (e.g., `docs/update-readme`)

---

## 2. Develop & Commit

Make your changes and commit frequently with meaningful messages.

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: Add my new feature"

# Push your feature branch to remote
git push origin feature/my-new-feature
```

### Commit Message Format

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

---

## 3. Merge to Develop (Dev Environment)

When your feature is ready for testing, merge it to `develop`.

```bash
# Switch to develop branch
git checkout develop
git pull origin develop

# Merge your feature branch
git merge feature/my-new-feature

# Push to trigger dev deployment
git push origin develop
```

**Next Step:** Test your changes in the dev environment.

---

## 4. Promote to Staging

After successful dev testing, promote to staging for QA.

```bash
# Switch to staging branch
git checkout staging
git pull origin staging

# Merge develop into staging
git merge develop

# Push to trigger staging deployment
git push origin staging
```

**Next Step:** Perform QA testing in the staging environment.

---

## 5. Promote to Production

After staging approval, promote to production.

```bash
# Switch to main branch
git checkout main
git pull origin main

# Merge staging into main
git merge staging

# Push to trigger production deployment
git push origin main
```

**Congratulations!** Your changes are now live in production.

---

## 6. Clean Up

After your feature is in production, delete the feature branch.

```bash
# Delete local branch
git branch -d feature/my-new-feature

# Delete remote branch
git push origin --delete feature/my-new-feature
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start feature | `git checkout main && git pull && git checkout -b feature/name` |
| Push feature | `git push origin feature/name` |
| Deploy to dev | `git checkout develop && git pull && git merge feature/name && git push` |
| Promote to staging | `git checkout staging && git pull && git merge develop && git push` |
| Promote to prod | `git checkout main && git pull && git merge staging && git push` |
| Delete branch | `git branch -d feature/name && git push origin --delete feature/name` |

---

## VS Code Instructions

### Create a Branch
1. Click the branch name in the bottom-left corner
2. Select "Create new branch from..."
3. Choose `main` as the source
4. Enter your branch name (e.g., `feature/my-feature`)

### Switch Branches
1. Click the branch name in the bottom-left corner
2. Select the target branch from the list

### Commit Changes
1. Open Source Control panel (Ctrl+Shift+G / Cmd+Shift+G)
2. Stage files by clicking the `+` icon
3. Enter commit message
4. Click the checkmark (✓) to commit

### Push Changes
1. Click "..." in Source Control panel
2. Select "Push"

### Merge Branches
1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Type "Git: Merge Branch"
3. Select the branch to merge from

---

## Hotfix Workflow

For urgent production fixes that can't wait for the normal flow:

```bash
# 1. Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# 2. Make your fix and commit
git add .
git commit -m "fix: Critical bug fix"

# 3. Merge directly to main (production)
git checkout main
git merge hotfix/critical-bug
git push origin main

# 4. Back-merge to staging and develop (keep them in sync)
git checkout staging
git merge main
git push origin staging

git checkout develop
git merge main
git push origin develop

# 5. Clean up
git branch -d hotfix/critical-bug
git push origin --delete hotfix/critical-bug
```

---

## Best Practices

1. **Always pull before merging** - Avoid merge conflicts
2. **Test in each environment** - Don't skip dev or staging
3. **Use meaningful commit messages** - Future you will thank you
4. **Delete merged branches** - Keep the repo clean
5. **Never force push to shared branches** - Especially `main`, `staging`, `develop`
6. **Review changes before promoting** - Use `git diff` or PR reviews

---

## Troubleshooting

### Merge Conflicts

```bash
# If you get merge conflicts:
# 1. Open conflicted files and resolve manually
# 2. Stage resolved files
git add .

# 3. Complete the merge
git commit -m "merge: Resolve conflicts"
```

### Undo Last Commit (before push)

```bash
git reset --soft HEAD~1
```

### Sync Branch with Main

```bash
git checkout feature/my-feature
git merge main
# Resolve any conflicts
git push origin feature/my-feature
```
