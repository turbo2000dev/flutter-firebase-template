# Execute Development Plan

**Description:** Execute the development plan from PLAN.md, automatically updating progress as tasks are completed.

---

You are executing the development plan defined in `PLAN.md`. As you work through each phase and task, you will **automatically update PLAN.md** to reflect real-time progress.

## Prerequisites

Before starting, verify:

```bash
# Check if PLAN.md exists
Read: PLAN.md
```

If PLAN.md doesn't exist:
```markdown
❌ **No Plan Found**

Please create a plan first using `/plan`.

The plan-based workflow requires:
1. Run `/plan` to create development plan
2. Review and approve the plan
3. Run `/execute-plan` to begin implementation

Alternatively, use:
- `/new-feature` - Traditional workflow (no planning)
- `/implement` - Streamlined workflow (no planning)
```

---

## Execution Workflow

### Step 0: Check Git History FIRST

**CRITICAL:** Before reading PLAN.md, ALWAYS check what's actually been done:

```bash
# 1. Check git commits to see completed work
git log --oneline --all -20

# 2. Look for Week X commits that indicate progress
# Example: "Week 1-2: Domain Models & Tax Calculator Foundation"

# 3. Use Glob to verify files exist
# Example: lib/features/projections/domain/**/*.dart
```

If git shows completed work but PLAN.md is out of sync:
1. Update PLAN.md to reflect actual progress
2. Update phase files (e.g., phase_0_foundation.md) to mark tasks complete
3. Then continue from correct position

---

### Step 1: Read and Parse PLAN.md

Read the complete plan to understand:
- Which phases are pending, in progress, or completed
- Current phase and task being worked on
- Overall progress status
- Design decisions and requirements

**Cross-check with git history** - PLAN.md should match reality

---

### Step 2: Determine Starting Point

**IMPORTANT:** Before checking PLAN.md status, ALWAYS check git history to see what's actually been completed:

```bash
# Check recent commits to understand what's been done
git log --oneline --all -20

# Check what files exist in the codebase
# Use Glob to find implemented features
```

Then check the plan status:

- **If all phases completed:** Plan is done, inform user
- **If a phase is 🚧 In Progress:** Check git commits to verify actual progress, update PLAN.md if needed
- **If all phases ⏳ Pending but git shows work done:** Update PLAN.md first, then resume

**Resume from last position:**
```markdown
📋 **Resuming Plan Execution**

**Plan:** [Feature Name]
**Overall Progress:** [X]%
**Current Phase:** Phase [X] - [Phase Name]
**Status:** 🚧 In Progress

**Completed Phases:** [X]/11
**Remaining Phases:** [X]/11

**Next Task:** [Task description]

Continuing from where we left off...
```

---

### Step 3: Execute Phase by Phase

For each phase in order:

#### A. Update Phase Status to "In Progress"

**IMPORTANT:** Before starting any phase, update PLAN.md:

```markdown
Use the Edit tool to update PLAN.md:

Find:
### Phase X: [Phase Name]
**Status:** ⏳ Pending

Replace:
### Phase X: [Phase Name]
**Status:** 🚧 In Progress
```

Also update the Progress Tracking section:
```markdown
Find:
**Last Updated:** [old date]
**Updated By:** [old agent]

Replace:
**Last Updated:** [current date and time]
**Updated By:** [current agent name]
```

#### B. Execute Tasks

For each task in the phase:

**1. Update task status to "In Progress":**
```markdown
Use Edit tool to update in PLAN.md:

Find:
- [ ] Task X.Y: [Task name]
  - Status: ⏳ Pending

Replace:
- [ ] Task X.Y: [Task name]
  - Status: 🚧 In Progress
```

**2. Launch appropriate agent for the phase:**

| Phase | Agent to Launch |
|-------|----------------|
| Phase 1: Architecture | architect |
| Phase 2-5: Implementation | developer |
| Phase 6: Testing | tester |
| Phase 7: Security Audit | security |
| Phase 8: Performance | performance |
| Phase 9: Code Review | reviewer |
| Phase 10-11: Verification & PR | developer |

**Example - Launching Agent:**

1. First, read the appropriate agent definition:
```
Read .claude/agents/[agent-name].md
```

2. Then launch the agent with full context:
```markdown
Use the Task tool:
- Description: "Phase [X]: [Phase Name]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/[agent-name].md, then add:
  "Now execute Phase [X] of the development plan in PLAN.md. Specifically:

  [Copy the exact tasks from PLAN.md for this phase]

  Follow the deliverables and git commit format specified in the plan. After completing the work, report back with:
  1. What was implemented
  2. Files created/modified
  3. Any issues encountered
  4. Confirmation that git commit was made per plan

  Refer to PLAN.md for complete context and requirements."
```

**3. Wait for agent to complete**

**4. After agent completes, update PLAN.md:**

**Mark task as completed:**
```markdown
Use Edit tool to update in PLAN.md:

Find:
- [ ] Task X.Y: [Task name]
  - Status: 🚧 In Progress

Replace:
- [x] Task X.Y: [Task name]
  - Status: ✅ Completed
```

**5. Repeat for all tasks in phase**

#### C. Update Phase Status to "Completed"

After all tasks in phase are done:

```markdown
Use Edit tool to update in PLAN.md:

Find:
### Phase X: [Phase Name]
**Status:** 🚧 In Progress

Replace:
### Phase X: [Phase Name]
**Status:** ✅ Completed
```

Update Progress Tracking section:
```markdown
Find:
**Phase Status:**
- ✅ Completed: [old count] phases
- 🚧 In Progress: [old count] phases
- ⏳ Pending: [old count] phases

Replace:
**Phase Status:**
- ✅ Completed: [new count] phases
- 🚧 In Progress: 0 phases
- ⏳ Pending: [new count] phases
```

Calculate and update overall progress:
```markdown
Find:
**Overall Progress:** [old]%

Replace:
**Overall Progress:** [new]%

Calculation: (completed_phases / 11) * 100
```

#### D. Inform User of Progress

After each phase completes:

```markdown
✅ **Phase [X] Completed: [Phase Name]**

**Deliverables:**
- [List what was created]
- [Files modified]
- [Tests added]

**Git Commit:**
```bash
[Show the commit message that was used]
```

**Progress:** [X]/11 phases complete ([XX]%)

**Next Phase:** Phase [X+1] - [Phase Name]

Continuing to next phase...
```

---

### Step 4: Handle Checkpoints

At certain phases, pause for user review:

**Checkpoint after Phase 1 (Architecture):**
```markdown
⏸️ **Checkpoint: Architecture Complete**

The technical specification has been created and documented.

**What was produced:**
- Technical specification document
- Domain model definitions
- Repository interfaces
- Firebase structure design

**Files created:**
- docs/[spec files]
- specs/[spec files]

**Git commit made:** ✅

**Before proceeding to implementation, would you like to:**
- ✅ Continue with implementation (I'll proceed automatically)
- 👀 Review the specification first (I'll wait)
- 🔄 Adjust the architecture (please specify changes)

Please respond, or I'll automatically continue in 5 seconds...
```

**Checkpoint after Phase 6 (Testing):**
```markdown
⏸️ **Checkpoint: Implementation and Testing Complete**

All implementation layers and tests are complete.

**Coverage Results:**
- Overall: [X]%
- Domain: [X]%
- Data: [X]%
- Application: [X]%

**Test Summary:**
- Unit tests: [X] passing
- Widget tests: [X] passing
- Integration tests: [X] passing

**Before proceeding to security/performance/review, would you like to:**
- ✅ Continue with quality checks (I'll proceed automatically)
- 🧪 Review test results
- 🔍 Manual testing first

Please respond, or I'll automatically continue in 5 seconds...
```

---

### Step 5: Complete Execution

When all 11 phases are done:

```markdown
🎉 **Development Plan Completed Successfully!**

**Plan:** [Feature Name]
**Status:** ✅ 100% Complete
**Duration:** [Actual time taken]

## Summary

**Phases Completed:** 11/11
- ✅ Phase 1: Architecture & Specification
- ✅ Phase 2: Domain Layer
- ✅ Phase 3: Data Layer
- ✅ Phase 4: Application Layer
- ✅ Phase 5: Presentation Layer
- ✅ Phase 6: Testing
- ✅ Phase 7: Security Audit
- ✅ Phase 8: Performance Optimization
- ✅ Phase 9: Code Review
- ✅ Phase 10: Final Verification
- ✅ Phase 11: Pull Request

## Deliverables

**Files Created:** [X] files
**Tests Written:** [X] tests
**Test Coverage:** [X]%
**Git Commits:** [X] commits
**Pull Request:** #[PR number] (if created)

## Quality Metrics

✅ **Code Quality:** All checks passed
✅ **Tests:** [X]/[X] passing ([X]% coverage)
✅ **Security:** No critical/high issues
✅ **Performance:** Targets met
✅ **Code Review:** Approved

## Git Information

**Branch:** [branch-name]
**Commits:** [X] commits
**Pull Request:** [URL if created]

## Next Steps

1. ✅ Wait for CI/CD pipeline to complete
2. ✅ Review PR and address any feedback
3. ✅ Manual testing recommended
4. ✅ Merge after approval
5. ✅ Monitor deployment

## Files Modified

The complete list is in PLAN.md under "Progress Tracking" section.

---

**Plan Status:** You can archive PLAN.md or keep it for reference.
**Start New Feature:** Run `/plan` for next feature.
```

Update PLAN.md one final time:
```markdown
Use Edit tool to update in PLAN.md:

Find:
**Status:** 🚧 In Progress

Replace:
**Status:** ✅ Completed

Find:
**Overall Progress:** [old]%

Replace:
**Overall Progress:** 100%
```

---

## Error Handling

### If Agent Fails

If an agent encounters an error:

```markdown
❌ **Phase [X] Failed**

**Error:** [Error description from agent]

**What happened:**
[Details of what went wrong]

**Current Status:**
- Phase [X] is still marked as 🚧 In Progress
- Task [X.Y] failed
- PLAN.md has been updated to reflect failure

**Your Options:**

1. **Fix and Resume:**
   - Fix the issue manually or tell me how to fix it
   - Run `/execute-plan` again to resume

2. **Skip Task:**
   - Mark task as completed manually in PLAN.md
   - Run `/execute-plan` to continue

3. **Adjust Plan:**
   - Edit PLAN.md to change approach
   - Run `/execute-plan` to continue with new plan

4. **Abort:**
   - Leave PLAN.md as-is
   - Start over with `/plan`

What would you like to do?
```

Update PLAN.md to show the error:
```markdown
Use Edit tool to add error note in PLAN.md:

Find:
- [ ] Task X.Y: [Task name]
  - Status: 🚧 In Progress

Replace:
- [ ] Task X.Y: [Task name]
  - Status: ❌ Failed
  - Error: [Error description]
  - Date: [current date]
```

### If PLAN.md is Corrupted

```markdown
❌ **Cannot Parse PLAN.md**

The plan file appears to be corrupted or in an unexpected format.

**Options:**
1. Restore from git history: `git checkout HEAD -- PLAN.md`
2. Start new plan: `/plan`
3. Fix manually and try again: Edit PLAN.md then run `/execute-plan`
```

---

## Real-Time Progress Updates

**CRITICAL:** You MUST update PLAN.md after EVERY significant action:

### When starting a phase:
```markdown
Update: **Status:** ⏳ Pending → **Status:** 🚧 In Progress
Update: **Last Updated:** to current date/time
```

### When completing a task:
```markdown
Update: - [ ] → - [x]
Update: **Status:** 🚧 In Progress → **Status:** ✅ Completed
```

### When completing a phase:
```markdown
Update: Phase **Status:** 🚧 In Progress → **Status:** ✅ Completed
Update: **Phase Status:** increment completed count
Update: **Overall Progress:** recalculate percentage
Update: **Last Updated:** to current date/time
```

### When making a git commit:
```markdown
Add to phase notes:
**Git Commit:** [commit hash] - [commit message first line]
```

### End-of-Week Git Commits:

**IMPORTANT**: At the end of each development week (typically after completing weekly tasks from PLAN.md), create a git commit to checkpoint progress.

**Required steps before committing:**
1. Run `flutter analyze` - must show "No issues found!"
2. Run `flutter test` - all tests must pass
3. Run `dart fix --apply` - auto-fix any linter issues
4. Verify test coverage is maintained (≥80% overall, 100% for critical code)

**Commit message format:**
```bash
git add .
git commit -m "$(cat <<'EOF'
Week X: [Brief summary of work completed]

Completed:
- [Feature/component 1]
- [Feature/component 2]
- [Feature/component 3]

Tests: X/X passing (100%)
Coverage: X% overall, 100% on [critical components]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**After committing:**
- Update PLAN.md with the commit hash
- Mark the week as completed
- Continue to next week's tasks

---

## Resumability

The execution is designed to be pausable and resumable:

- **User can stop at any time** (Ctrl+C)
- **Running `/execute-plan` again** resumes from last 🚧 In Progress phase
- **PLAN.md serves as state** - no need to remember where you left off
- **All progress is preserved** in PLAN.md

---

## Usage

```bash
# Start executing the plan
/execute-plan

# If interrupted, resume with same command
/execute-plan

# The command will:
# 1. Read PLAN.md
# 2. Find where it left off
# 3. Continue from there
# 4. Update PLAN.md in real-time
# 5. Complete all 11 phases
# 6. Create PR at the end
```

---

## Important Notes

### DO:
- ✅ Read PLAN.md first to understand the plan
- ✅ Update PLAN.md after every task/phase change
- ✅ Launch appropriate agents for each phase
- ✅ Follow git commit format from plan exactly
- ✅ Track progress with percentages
- ✅ Inform user of progress regularly
- ✅ Pause at checkpoints if needed

### DON'T:
- ❌ Skip updating PLAN.md (always keep it current)
- ❌ Make up tasks not in the plan
- ❌ Change plan without user approval
- ❌ Continue if agent reports failure
- ❌ Skip phases or rush through

---

This command provides **systematic, trackable execution** of your development plan with real-time progress visibility in PLAN.md.
