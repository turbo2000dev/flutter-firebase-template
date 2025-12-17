# Commit

**Description:** Commit changes locally with a properly formatted commit message following conventional commit standards.

---

## Usage

```bash
/commit [optional: --push] [optional: --all]
```

**Options:**
- `--push` - Push to remote after committing
- `--all` - Stage all changes (equivalent to `git add .`)

**Examples:**
```bash
/commit                 # Interactive - review changes and craft message
/commit --push          # Commit and push to remote
/commit --all --push    # Stage all, commit, and push
```

---

## Workflow

### Phase 1: Check Current State

```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check for changes
echo "Checking for changes..."
git status --porcelain
```

**Evaluate the state:**

1. **If no changes exist:**
   ```markdown
   No changes to commit. Working tree is clean.
   ```
   **Action:** Abort with informational message.

2. **If on main branch:**
   - Warn the user: "You're committing directly to main. Consider using a feature branch."
   - Ask whether to:
     - **Continue anyway** - Commit to main (for minor fixes)
     - **Create feature branch first** - Run `/start-dev`
     - **Abort** - Cancel the operation

---

### Phase 2: Review Changes

Display changes for review:

```bash
# Show staged changes
echo "=== Staged Changes ==="
git diff --cached --stat

# Show unstaged changes
echo "=== Unstaged Changes ==="
git diff --stat

# Show untracked files
echo "=== Untracked Files ==="
git ls-files --others --exclude-standard
```

**Ask the user what to stage:**

If there are unstaged changes or untracked files, ask:
- **Stage all changes** - `git add .`
- **Stage specific files** - Let user specify files/patterns
- **Keep current staging** - Only commit what's already staged
- **Abort** - Cancel to handle manually

---

### Phase 3: Analyze Changes for Commit Message

Analyze the staged changes to suggest a commit message:

```bash
# Get list of changed files
git diff --cached --name-only

# Get diff summary
git diff --cached --stat

# Look at the actual changes
git diff --cached
```

**Determine commit type based on changes:**

| Change Pattern | Suggested Type |
|----------------|----------------|
| New files in `lib/features/*/` | `feat` |
| Modified existing functionality | `feat` or `fix` |
| Files in `test/` | `test` |
| `.md` files, comments only | `docs` |
| Formatting, no logic changes | `style` |
| Refactoring, no behavior change | `refactor` |
| Performance improvements | `perf` |
| Build/config files | `build` or `ci` |
| Dependencies | `build` |

**Determine scope from file paths:**

| File Path Pattern | Suggested Scope |
|-------------------|-----------------|
| `lib/features/auth/` | `auth` |
| `lib/features/profile/` | `profile` |
| `lib/features/*/domain/` | Feature name + `domain` |
| `lib/core/` | `core` |
| `test/` | Same as source file scope |
| `functions/` | `functions` |
| `landing-page/` | `landing` |

---

### Phase 4: Generate Commit Message

**Commit Message Format:**

```
<type>(<scope>): <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Generate a suggested message based on the analysis:**

1. **Subject line** (max 72 chars):
   - Imperative mood ("add", "fix", "update", not "added", "fixed")
   - Lowercase start
   - No period at end
   - Summarize the "what"

2. **Body** (optional but recommended):
   - Explain the "why" if not obvious
   - List main changes as bullet points
   - Reference related issues if applicable

**Present the suggested message to the user:**

```markdown
## Suggested Commit Message

Based on your changes, here's a suggested commit message:

```
feat(tax): add provincial tax calculation

- Implement Quebec provincial tax brackets
- Add income-tested credits calculation
- Include 2024 tax rates from Revenu Quebec

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Would you like to:
1. **Use this message** - Commit with the suggested message
2. **Edit the message** - Modify before committing
3. **Write custom message** - Provide your own message
4. **Abort** - Cancel the commit
```

---

### Phase 5: Execute Commit

```bash
# Stage files if requested
git add <files>

# Create commit with message
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Phase 6: Optional Push

If `--push` flag was provided or user requests:

```bash
echo "Pushing to remote..."
git push origin $CURRENT_BRANCH
```

**If push fails (branch not tracked):**

```bash
git push -u origin $CURRENT_BRANCH
```

---

### Phase 7: Confirmation

```markdown
## Commit Successful

**Branch:** `<branch-name>`
**Commit:** `<short-hash>` <commit-subject>
**Files changed:** X files (+Y/-Z lines)

---

### Changes Committed

```
<git diff --stat output>
```

---

### Next Steps

| Action | Command |
|--------|---------|
| Continue developing | Keep coding! |
| Push changes | `git push` or `/commit --push` next time |
| View commit | `git show HEAD` |
| Undo commit (keep changes) | `git reset --soft HEAD~1` |
| Ready for PR | `/start-pr` |
```

---

## Commit Types Reference

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add Google OAuth login` |
| `fix` | Bug fix | `fix(calc): correct tax bracket rounding` |
| `docs` | Documentation | `docs(readme): update setup instructions` |
| `style` | Formatting (no logic) | `style: apply dart format` |
| `refactor` | Code restructuring | `refactor(repo): extract base repository` |
| `perf` | Performance | `perf(list): add RepaintBoundary` |
| `test` | Tests | `test(auth): add login flow tests` |
| `build` | Build/dependencies | `build: upgrade riverpod to 3.0` |
| `ci` | CI/CD changes | `ci: add coverage check to pipeline` |
| `chore` | Maintenance | `chore: clean up unused imports` |

---

## Scope Examples

| Scope | When to Use |
|-------|-------------|
| `auth` | Authentication feature |
| `profile` | User profile feature |
| `tax` | Tax calculations |
| `projection` | Financial projections |
| `ui` | General UI components |
| `core` | Core/shared utilities |
| `api` | API integration |
| `db` | Database/Firestore |
| `functions` | Cloud Functions |
| `landing` | Landing page |

---

## Smart Commit Examples

**Single file change:**
```bash
# Changed: lib/features/tax/domain/tax_calculator.dart
# Suggested: feat(tax): implement progressive tax brackets
```

**Multiple related files:**
```bash
# Changed:
#   lib/features/auth/domain/user.dart
#   lib/features/auth/data/user_repository.dart
#   test/features/auth/domain/user_test.dart
# Suggested: feat(auth): add user entity with repository

# Body:
# - Define User entity with Freezed
# - Implement UserRepository with Firestore
# - Add unit tests for User entity
```

**Bug fix:**
```bash
# Changed: lib/features/projection/application/projection_controller.dart
# Suggested: fix(projection): handle null retirement age

# Body:
# Previously crashed when retirement age was not set.
# Now defaults to 65 if not specified.
#
# Fixes #42
```

**Test addition:**
```bash
# Changed: test/features/tax/domain/tax_calculator_test.dart
# Suggested: test(tax): add edge case tests for tax calculator

# Body:
# - Test zero income scenario
# - Test maximum bracket overflow
# - Test negative income validation
```

---

## Error Handling

### Nothing to Commit

```markdown
## No Changes to Commit

Your working tree is clean. There are no staged or unstaged changes.

**To make changes:**
1. Edit some files
2. Run `/commit` again

**Or if you expected changes:**
- Check if files are gitignored: `git status --ignored`
- Verify you're in the right directory
```

### Commit Hook Failures

```bash
# If pre-commit hook fails
echo "Pre-commit hook failed. Common fixes:"
echo "1. Run 'dart format .' to fix formatting"
echo "2. Run 'flutter analyze' to check for issues"
echo "3. Run 'flutter test' to verify tests pass"
```

**Ask user:**
- **Fix and retry** - Address the issues and try again
- **Skip hooks** - `git commit --no-verify` (not recommended)
- **Abort** - Cancel the commit

### Merge Conflict State

```markdown
## Cannot Commit - Merge in Progress

You have unresolved merge conflicts. Resolve them first:

1. Check conflicted files: `git status`
2. Edit files to resolve conflicts
3. Stage resolved files: `git add <file>`
4. Complete merge: `git commit` (no message needed)

Or abort the merge: `git merge --abort`
```

---

## Integration with Workflow

The `/commit` command fits into the weekly workflow:

```
Monday:     /start-dev feature-name
            ↓
During      /commit (after each logical unit)
Week:       /commit --push (end of day)
            /commit (next morning)
            ...
            ↓
Friday:     /start-pr (final quality checks + merge)
            ↓
After:      /promote staging (optional UAT)
            /promote main (production)
```

**Recommended commit frequency:**
- After completing a layer (domain, data, application, presentation)
- After writing tests for a component
- After fixing a bug
- Before taking a break
- At end of each day (with `--push`)

---

## Related Commands

- `/start-dev` - Start new development branch
- `/start-pr` - Create PR when ready to merge
- `/code-review` - Review code before committing
- `/promote` - Promote to staging/production

---

## Related Documentation

- [Git Workflow](../guidelines/git_workflow.md) - Commit conventions
- [Weekly Workflow](../docs/ci-cd/weekly-workflow.md) - Development cycle
