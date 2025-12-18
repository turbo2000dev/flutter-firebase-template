# Start Development

**Description:** Start a new feature development cycle by creating a properly configured weekly branch from dev.

---

## Usage

```bash
/start-dev [optional: branch-description]
```

**Examples:**
```bash
/start-dev                          # Will prompt for description
/start-dev tax-calculator           # Creates feature/YYYY-WW-tax-calculator
/start-dev user-authentication      # Creates feature/YYYY-WW-user-authentication
```

---

## Workflow

### Phase 1: Pre-flight Checks

Before creating a new branch, check the current Git state:

```bash
# Get current branch
echo "Current branch:"
git branch --show-current

# Check for uncommitted changes
echo "Checking for uncommitted changes..."
git status --porcelain

# Check if on dev and if there are unpushed commits
echo "Checking for unpushed commits..."
git log origin/dev..HEAD --oneline 2>/dev/null || echo "No upstream tracking"
```

**Evaluate the output:**

1. **If there are uncommitted changes:**
   - Ask the user what to do:
     - **Stash changes** - Save changes for later with `git stash`
     - **Commit changes** - Create a commit before proceeding
     - **Discard changes** - Reset to clean state (warn about data loss)
     - **Abort** - Cancel the operation

2. **If on dev with unpushed commits:**
   - Warn the user that there are local commits not pushed to origin
   - Ask whether to:
     - **Push to dev** - Push the commits before branching
     - **Continue anyway** - Branch will include unpushed commits
     - **Abort** - Cancel to review commits first

3. **If on a feature branch (not dev):**
   - Inform user they're not on dev
   - Ask whether to:
     - **Switch to dev** - Checkout dev first
     - **Continue from current branch** - Create new branch from current HEAD
     - **Abort** - Cancel the operation

---

### Phase 2: Update Dev Branch

If proceeding from dev:

```bash
# Fetch latest from remote
echo "Fetching latest changes..."
git fetch origin

# Update dev branch
git checkout dev
git pull origin dev
```

**Handle pull failures:**
- If merge conflicts, inform user and abort
- If network issues, warn and ask to proceed with local state

---

### Phase 3: Create Weekly Branch

Determine the branch name:

```bash
# Get current year and week number
YEAR=$(date +%Y)
WEEK=$(date +%V)

# Branch name format: feature/YYYY-WW-description
# Example: feature/2024-51-tax-calculator
# Note: Using 'feature/' prefix to avoid git ref conflict with 'dev' branch
```

**Ask the user for branch description if not provided:**

Use AskUserQuestion to get a brief (2-4 words, hyphenated) description of the feature/work for this week.

**Create and push the branch:**

```bash
# Create the branch
BRANCH_NAME="feature/${YEAR}-${WEEK}-<description>"
git checkout -b $BRANCH_NAME

# Push to remote with upstream tracking
git push -u origin $BRANCH_NAME
```

---

### Phase 4: Confirmation and Next Steps

Provide confirmation message:

```markdown
## Development Branch Created

**Branch:** `feature/YYYY-WW-<description>`
**Based on:** `dev` @ `<commit-hash>`
**Remote:** Pushed and tracking `origin/feature/YYYY-WW-<description>`

---

## Next Steps

1. **Plan your work** (recommended)
   ```bash
   /plan
   ```
   Create a detailed implementation plan before coding.

2. **Start implementing**
   ```bash
   /implement <feature-description>
   ```
   Begin implementation with AI assistance.

3. **Or use the full feature workflow**
   ```bash
   /new-feature
   ```
   Complete end-to-end development with all agents.

---

## During Development

- **Commit frequently** - After each logical unit of work
- **Push daily** - Keep remote updated with progress
- **Run tests often** - Don't wait until end of week

```bash
# Daily workflow
git add <files>
git commit -m "feat(scope): description"
git push
```

---

## End of Week

When ready to merge, use:
```bash
/start-pr
```
This will run quality checks and create a PR to dev.

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/plan` | Create implementation plan |
| `/implement` | Implement a feature |
| `/code-review` | Review your code |
| `/test-audit` | Check test coverage |
| `/start-pr` | Prepare and create PR |
```

---

## Handling Edge Cases

### Working on an Existing Weekly Branch

If the user already has a weekly branch for the current week:

```bash
# Check for existing weekly branch
git branch -a | grep "feature/${YEAR}-${WEEK}"
```

If found, ask the user:
- **Switch to existing branch** - Checkout the existing weekly branch
- **Create new branch anyway** - Use a different description
- **Abort** - Cancel the operation

### Week Spanning Features

If work extends beyond a week:

Inform the user they can:
1. Create a PR with partial work and merge
2. Continue on the same branch into next week
3. Reference `docs/ci-cd/weekly-workflow.md` for detailed guidance

---

## Error Handling

### Network Issues

```bash
# If fetch/push fails
echo "Network error. Check your connection and try again."
echo "You can also work offline and push later."
```

### Permission Issues

```bash
# If push fails due to permissions
echo "Push failed. Verify you have write access to the repository."
echo "Check your SSH keys or access tokens."
```

### Branch Already Exists

```bash
# If branch name collision
echo "Branch 'feature/YYYY-WW-description' already exists."
# Offer to add a suffix or use different description
```

---

## Related Commands

- `/start-pr` - Create PR when development is complete
- `/deploy` - Promote code to main/staging/production
- `/plan` - Create implementation plan
- `/implement` - Implement a feature

---

## Related Documentation

- [Weekly Workflow](../docs/ci-cd/weekly-workflow.md) - Complete weekly cycle guide
- [Git Workflow](../guidelines/git_workflow.md) - Branching and commit conventions
- [Development Workflow](../CLAUDE.md) - Overall development process
