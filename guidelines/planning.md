# Plan-Based Development Guidelines

## Overview

This document describes the plan-based development workflow that enables systematic, transparent development with user involvement in design decisions and real-time progress tracking.

**Note:** This project uses a weekly Git branching workflow. See `docs/ci-cd/weekly-workflow.md` for Git branching strategy and `guidelines/git_workflow.md` for detailed Git practices.

## Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│  1. Run /plan                                               │
│     - Describe feature                                      │
│     - Answer design questions                               │
│     - Review proposed plan                                  │
│     - Approve plan → PLAN.md created                        │
├─────────────────────────────────────────────────────────────┤
│  2. Run /execute-plan                                       │
│     - Agents execute phases systematically                  │
│     - PLAN.md updates in real-time                         │
│     - User can monitor progress anytime                     │
│     - Pause/resume at any time                              │
├─────────────────────────────────────────────────────────────┤
│  3. Review results                                          │
│     - All phases complete                                   │
│     - PR created                                            │
│     - PLAN.md shows 100% completion                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 1: Plan Creation

You have two options for creating a plan:

### Option A: Interactive Planning (`/plan`)

**Use when:** You want to describe your feature interactively during the planning session.

**Process:**
1. **Requirement Gathering**
   - User describes what they want to build
   - Claude asks clarifying questions
   - Scope and requirements are defined

### Option B: Requirements-Based Planning (`/plan-from-requirements`)

**Use when:** You have requirements documented in a file (e.g., `requirements.md`).

**Process:**
1. **Requirements Reading**
   - User provides path to requirements file (or uses default `requirements.md`)
   - Claude reads and parses requirements
   - Claude summarizes requirements for confirmation
   - Claude asks clarifying questions if requirements are unclear

**Benefits:**
- Requirements documented in version control
- Requirements can be reviewed/approved separately from plan
- Easy to track requirement changes over time
- Plan includes requirements traceability matrix
- Better for formal development processes
- Supports collaborative requirements gathering

Both options continue with the same process:

2. **Design Decisions** (Critical - User Involvement)
   - Claude presents architecture options
   - Claude presents technical choices
   - Claude presents UI/UX approaches (if applicable)
   - User chooses preferred options
   - All decisions are recorded in plan

3. **Plan Creation**
   - Claude creates detailed 11-phase plan
   - Each phase broken into specific tasks
   - File paths, deliverables, git commits specified
   - Coverage targets and quality metrics defined

4. **Plan Review**
   - Claude presents complete plan to user
   - User reviews and can request adjustments
   - User approves plan

5. **Plan Storage**
   - Approved plan written to `PLAN.md`
   - Plan serves as single source of truth
   - User can review PLAN.md anytime

### Example Design Questions

**Architecture:**
```
Question: "How should we structure the data model for user profiles?"
Options:
  A. Single entity with nested data (simpler, less flexible)
  B. Separate entities with relationships (normalized, more complex)
  C. Hybrid approach (balance of both)

Your choice: B
Rationale: Better separation of concerns, easier to extend
```

**State Management:**
```
Question: "What state management approach for the shopping cart?"
Options:
  A. Local state (simple, screen-specific)
  B. Global state with providers (shared across app)
  C. Mixed approach (local + global where needed)

Your choice: B
Rationale: Cart needs to be accessible from multiple screens
```

**UI Flow:**
```
Question: "What should the user flow be for checkout?"
Options:
  A. Single screen with sections
  B. Multi-step wizard
  C. Bottom sheet modal

Your choice: B
Rationale: Complex process, better to break into steps
```

### Design Decisions Recorded in PLAN.md

```markdown
## 2. Design Decisions (User Approved)

### Architecture
- **Data Model:** Separate entities with relationships
- **State Management:** Global state with providers
- **Offline Support:** Full offline with sync

### Technical Choices
- **New Packages:** None required
- **Navigation:** Multi-step wizard
- **Caching:** LRU cache with 100-item limit

### UI/UX
- **Screen Flow:** Multi-step wizard (4 steps)
- **Forms:** Field-level validation
- **Error Handling:** Inline errors + summary
```

---

## Step 2: Plan Execution (`/execute-plan`)

### Purpose

Execute the approved plan systematically with real-time progress tracking.

### The 11 Phases

| Phase | Name | Agent | Typical Duration |
|-------|------|-------|-----------------|
| 1 | Architecture & Specification | Architect | 1-2 hours |
| 2 | Domain Layer Implementation | Developer | 1-2 hours |
| 3 | Data Layer Implementation | Developer | 1-2 hours |
| 4 | Application Layer Implementation | Developer | 1-2 hours |
| 5 | Presentation Layer Implementation | Developer | 2-3 hours |
| 6 | Testing | Tester | 2-3 hours |
| 7 | Security Audit | Security | 20-40 min |
| 8 | Performance Optimization | Performance | 30-60 min |
| 9 | Code Review | Reviewer | 20-40 min |
| 10 | Final Verification | Developer | 15-30 min |
| 11 | Pull Request | Developer | 10-15 min |

### Phase Execution Flow

For each phase:

1. **Phase Status Update**
   ```markdown
   PLAN.md before:
   ### Phase 2: Domain Layer Implementation
   **Status:** ⏳ Pending

   PLAN.md after:
   ### Phase 2: Domain Layer Implementation
   **Status:** 🚧 In Progress
   ```

2. **Agent Launch**
   - Appropriate agent launched for the phase
   - Agent reads PLAN.md to understand tasks
   - Agent executes tasks one by one

3. **Task Execution**
   - For each task in the phase:
     ```markdown
     PLAN.md before task:
     - [ ] Task 2.1: Implement entities
       - Status: ⏳ Pending

     PLAN.md during task:
     - [ ] Task 2.1: Implement entities
       - Status: 🚧 In Progress

     PLAN.md after task:
     - [x] Task 2.1: Implement entities
       - Status: ✅ Completed
     ```

4. **Deliverables Created**
   - Code files written
   - Tests created
   - Documentation added
   - Code generation run (if needed)

5. **Git Commit**
   - Commit made with exact format from PLAN.md
   - Claude Code attribution included
   - Only specified files committed

6. **Phase Completion**
   ```markdown
   PLAN.md after phase:
   ### Phase 2: Domain Layer Implementation
   **Status:** ✅ Completed

   Progress Tracking updated:
   **Overall Progress:** 18% (2/11 phases)
   **Last Updated:** 2024-11-01 14:32
   **Updated By:** Developer Agent
   ```

7. **User Notification**
   ```
   ✅ Phase 2 Complete: Domain Layer Implementation

   Files Created:
   - lib/features/profile/domain/entities/user_profile.dart
   - lib/features/profile/domain/repositories/profile_repository.dart

   Git Commit: abc1234 - feat(profile): implement domain layer

   Progress: 2/11 phases (18%)
   Next: Phase 3 - Data Layer Implementation
   ```

### Real-Time Progress Tracking

Users can open `PLAN.md` at any time to see:
- Which phase is currently running (🚧 In Progress)
- Which phases are complete (✅ Completed)
- Which tasks within current phase are done
- Overall completion percentage
- Last update timestamp
- Which agent is working

### Resumability

- User can stop execution at any time (Ctrl+C)
- Running `/execute-plan` again resumes from last in-progress phase
- PLAN.md serves as the state - nothing is lost
- All progress is preserved

### Checkpoints

At certain phases, execution pauses for user review:

**Checkpoint 1: After Phase 1 (Architecture)**
```
⏸️ Checkpoint: Architecture Complete

Technical specification has been created.

Review: docs/profile_specification.md

Options:
- Continue with implementation
- Review specification first
- Adjust architecture

(Auto-continues in 5 seconds if no response)
```

**Checkpoint 2: After Phase 6 (Testing)**
```
⏸️ Checkpoint: Implementation and Testing Complete

Test Coverage: 87%
Tests Passing: 156/156

Options:
- Continue with quality checks
- Manual testing first
- Review implementation

(Auto-continues in 5 seconds if no response)
```

---

## PLAN.md Structure

### Complete Structure

```markdown
# Development Plan: [Feature Name]

**Created:** [Date]
**Status:** 📋 Approved | 🚧 In Progress | ✅ Completed
**Last Updated:** [Date and time]
**Overall Progress:** [X]%

## 1. Overview
- Feature Description
- Goals
- Success Criteria

## 2. Design Decisions (User Approved)
- Architecture choices
- Technical choices
- UI/UX decisions
- Rationale

## 3. Implementation Phases (11 phases)
Each with:
- Status (⏳ Pending | 🚧 In Progress | ✅ Completed)
- Agent assignment
- Estimated time
- Tasks (with checkboxes and statuses)
- Deliverables
- Git commit format

## 4. File Structure
Complete tree of files to create

## 5. Dependencies
New packages needed

## 6. Risk Assessment
Risks and mitigation strategies

## 7. Timeline Estimate
Time breakdown by phase

## 8. Progress Tracking
Real-time status (updated by agents):
- Phase counts (completed/in-progress/pending)
- Overall progress percentage
- Last updated timestamp
- Updated by which agent

## 9. Notes
Important considerations and open questions
```

### Status Indicators

- ⏳ **Pending** - Not started yet
- 🚧 **In Progress** - Currently being worked on
- ✅ **Completed** - Finished successfully
- ❌ **Failed** - Encountered error (with details)

### Task Format

```markdown
- [ ] Task X.Y: [Task name]
  - Status: ⏳ Pending | 🚧 In Progress | ✅ Completed | ❌ Failed
  - Files: `path/to/files/`
  - Details: [What needs to be done]
  - Error: [If failed, error details]
```

---

## Git Integration

### Commits After Each Phase

Each phase results in a git commit:

| Phase | Commit Type | Scope | Files |
|-------|------------|-------|-------|
| 1 | `docs` | feature | specs/, docs/ |
| 2 | `feat` | feature | domain/ |
| 3 | `feat` | feature | data/, generated files |
| 4 | `feat` | feature | application/, generated files |
| 5 | `feat` | feature | presentation/ |
| 6 | `test` | feature | test/ |
| 7 | `security` | feature | fixes (if any) |
| 8 | `perf` | feature | optimizations (if any) |
| 9 | `refactor` | feature | review fixes (if any) |
| 10 | - | - | no commit (verification only) |
| 11 | - | - | no commit (PR creation) |

### Commit Message Format

From PLAN.md:
```bash
git commit -m "type(scope): description

Details:
- Detail 1
- Detail 2
- Detail 3

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Commit Tracking in PLAN.md

After each commit, PLAN.md is updated:
```markdown
**Git Commits Made:**
- Phase 1: abc1234 - docs(profile): add technical specification
- Phase 2: def5678 - feat(profile): implement domain layer
- Phase 3: ghi9012 - feat(profile): implement data layer
```

---

## Benefits of Plan-Based Development

### For Users

1. **Design Control** - Involved in all architecture decisions
2. **Transparency** - See exactly what's being built before implementation
3. **Progress Visibility** - Open PLAN.md anytime to see status
4. **Flexibility** - Pause and resume at any time
5. **Confidence** - Know what to expect, no surprises
6. **Documentation** - Complete plan serves as feature documentation

### For Development Process

1. **Systematic** - Clear phases, no skipped steps
2. **Trackable** - Every task has a status
3. **Resumable** - Can stop and continue without losing context
4. **Auditable** - Complete record of what was done when
5. **Quality** - All quality phases included (security, performance, review)
6. **Consistent** - Same workflow every time

### For Teams

1. **Onboarding** - New members can read PLAN.md to understand feature
2. **Collaboration** - Multiple people can see progress
3. **Review** - Clear checkpoints for review
4. **Knowledge Transfer** - Plan documents decisions and rationale

---

## Comparison with Traditional Workflows

| Aspect | Traditional (`/new-feature`) | Plan-Based (`/plan` + `/execute-plan`) |
|--------|------------------------------|----------------------------------------|
| User Involvement | Minimal | High (design decisions) |
| Progress Visibility | Agents report at end | Real-time in PLAN.md |
| Resumability | Start over if interrupted | Resume from last task |
| Design Documentation | May or may not exist | Always in PLAN.md |
| Flexibility | Fixed workflow | Adjustable plan |
| User Control | Agent drives | User drives |
| Time to Start | Immediate | After plan approval |
| Best For | Clear requirements, trust agent decisions | Complex features, want design control |

---

## When to Use Each Workflow

### Use Plan-Based (`/plan`)

✅ **When you want:**
- Control over architecture decisions
- To understand the plan before implementation
- Progress visibility during development
- Ability to pause and resume
- Documentation of design decisions
- To review approach before committing

✅ **Best for:**
- Complex features with multiple approaches
- Features where architecture is critical
- Learning about design patterns
- Team collaboration (others can see plan)
- Features you may need to pause/resume

### Use Traditional (`/new-feature` or `/implement`)

✅ **When you want:**
- Fastest path to implementation
- Trust Claude to make good decisions
- Simple, straightforward features
- Immediate execution without planning phase

✅ **Best for:**
- Simple, well-defined features
- Following established patterns
- Quick fixes or enhancements
- Solo development
- Time-critical changes

---

## Best Practices

### During Planning

1. **Be Specific** - Provide clear requirements
2. **Ask Questions** - If unsure about options presented
3. **Think Through Decisions** - Consider trade-offs
4. **Review Carefully** - Check plan before approving
5. **Document Rationale** - Ask Claude to note why decisions were made

### During Execution

1. **Monitor PLAN.md** - Check progress periodically
2. **Review at Checkpoints** - Don't skip checkpoint reviews
3. **Let It Run** - Don't interrupt unless necessary
4. **Resume if Interrupted** - Just run `/execute-plan` again
5. **Review Results** - Check implementation against plan

### After Completion

1. **Keep PLAN.md** - Serves as feature documentation
2. **Review Deviations** - Note if implementation differed from plan
3. **Update if Needed** - Edit PLAN.md if things changed
4. **Archive** - Keep for future reference
5. **Learn** - Review what worked well for next time

---

## Error Handling

### If Planning Fails

```
Issue: Can't create plan due to unclear requirements

Solution:
1. Provide more details about the feature
2. Answer clarifying questions
3. Start with simpler scope
4. Try again with /plan
```

### If Execution Fails

```
Issue: Agent encounters error during phase execution

What happens:
1. Task marked as ❌ Failed in PLAN.md
2. Error details recorded
3. User notified with options
4. Execution pauses

Options:
1. Fix manually, update PLAN.md, resume with /execute-plan
2. Skip task (mark complete), resume
3. Adjust plan, resume
4. Abort and start over
```

### If PLAN.md Gets Corrupted

```
Issue: PLAN.md format is broken

Solutions:
1. Restore from git: git checkout HEAD -- PLAN.md
2. Fix manually (it's just markdown)
3. Start new plan with /plan
```

---

## FAQ

**Q: Can I edit PLAN.md manually?**
A: Yes! It's just markdown. Edit to adjust tasks, add notes, etc. Agents will follow the updated plan.

**Q: What if I disagree with a design decision after approval?**
A: Edit PLAN.md to note the change, or stop execution and create new plan.

**Q: Can I skip phases?**
A: Not recommended, but you can mark phases as complete in PLAN.md if you've done them manually.

**Q: How long does execution take?**
A: Depends on feature size. Estimate is in PLAN.md. Typically 4-8 hours for medium feature.

**Q: Can multiple people work on the same PLAN.md?**
A: Yes, but coordinate to avoid conflicts. Use git branches for parallel work.

**Q: What if I want to add a task mid-execution?**
A: Edit PLAN.md to add the task, agents will see it and execute it.

**Q: Can I use plan-based workflow with existing code?**
A: Yes! Create plan for enhancements/refactoring. Adjust Phase 2-5 to modify existing code instead of creating new.

---

**Version:** 1.0
**Last Updated:** November 2024
**Related:** `dev-workflow/DEVELOPMENT_WORKFLOW.md`, `dev-workflow/CLAUDE_CODE_SETUP.md`
