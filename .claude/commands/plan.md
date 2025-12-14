# Plan Development

**Description:** Create a detailed, phased development plan for review and approval before implementation.

---

You are creating a comprehensive development plan that will be reviewed and approved by the user before execution. This is the first step in a systematic, collaborative development approach where the user is involved in all design decisions. This is a crucial and very important element in the project execution. Therefore, read carefully the requirements, take proper time to analyze and ultrathink to produce the final result. 

## Your Task

1. **Understand the requirement** by asking clarifying questions
2. **Analyze the codebase** to understand existing architecture
3. **Present design decisions** for user approval
4. **Create a detailed plan** broken down into phases and tasks
5. **Write the approved plan** to `PLAN.md`

---

## Step 1: Gather Requirements

Ask the user clarifying questions using the AskUserQuestion tool:

**Essential questions:**
- Feature scope and requirements
- Priority and timeline constraints
- Specific user preferences
- Integration requirements
- Design preferences (if UI involved)

**Example:**
```
If user says "I want to add user profile management":

Use AskUserQuestion:
Question: "What profile information should users be able to manage?"
Options:
- Basic info only (name, email, photo)
- Extended info (address, phone, preferences)
- Full profile with custom fields
```

---

## Step 2: Analyze Codebase

Before creating the plan, launch the **Architect Agent** to analyze the existing codebase:

1. First, read the architect agent definition:
```
Read .claude/agents/architect.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Codebase analysis for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/architect.md, then add:
  "Analyze the existing codebase to prepare for implementing [FEATURE_NAME].

  User requirements:
  [Include gathered requirements from Step 1]

  Please analyze and report:
  1. Where this feature fits in the existing architecture
  2. Similar existing features to maintain consistency with
  3. Reusable patterns, components, and domain models
  4. Potential dependencies or conflicts
  5. Firebase collection structure considerations
  6. Required new packages
  7. Any technical constraints or considerations

  Do NOT create implementation - only analyze and report findings.
  Reference: CLAUDE.md, guidelines/architecture.md, guidelines/coding_standards.md"
```

**Wait for architect agent to complete** and review the codebase analysis.

---

## Step 3: Design Review - Critical User Involvement

**IMPORTANT:** Present ALL major design decisions to the user for approval.

### Architecture Decisions to Present

Use AskUserQuestion to present options:

**1. Data Model Structure**
```
Question: "How should we structure the data model for [feature]?"
Options:
- Single entity with nested data (simpler, less flexible)
- Separate entities with relationships (normalized, more complex)
- Hybrid approach (balance of both)
```

**2. State Management Approach**
```
Question: "What state management approach for [feature]?"
Options:
- Local state (simple, screen-specific)
- Global state with providers (shared across app)
- Mixed approach (local + global where needed)
```

**3. Offline Support Strategy**
```
Question: "What offline support should [feature] have?"
Options:
- Full offline support (local cache, sync)
- Read-only offline (cached data, no edits)
- Online-only (requires connection)
```

**4. UI/UX Flow** (if applicable)
```
Question: "What should the user flow be for [feature]?"
Options:
- Single screen with sections
- Multi-step wizard
- Tab-based navigation
- Modal/bottom sheet
```

**Present mockup ideas or flow diagrams if helpful**

---

## Step 4: Create Development Plan

After design decisions are approved, launch the **Architect Agent** to create a detailed technical plan:

1. First, read the architect agent definition (if not already loaded):
```
Read .claude/agents/architect.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Create development plan for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/architect.md, then add:
  "Create a comprehensive development plan for [FEATURE_NAME].

  User Requirements:
  [Include gathered requirements from Step 1]

  Codebase Analysis Results:
  [Include findings from Step 2]

  User-Approved Design Decisions:
  [Include all decisions from Step 3]

  Create a detailed plan following the 11-phase structure:
  1. Architecture & Specification
  2. Domain Layer Implementation
  3. Data Layer Implementation
  4. Application Layer Implementation
  5. Presentation Layer Implementation
  6. Testing
  7. Security Audit
  8. Performance Optimization
  9. Code Review
  10. Final Verification
  11. Pull Request

  For each phase, include:
  - Specific tasks derived from requirements
  - File paths based on feature name and architecture analysis
  - Deliverables aligned with requirements
  - Git commit messages
  - Time estimates

  Also include:
  - Complete file structure tree
  - Required dependencies/packages
  - Risk assessment

  Output the complete plan in markdown format ready to be written to PLAN.md."
```

**Wait for architect agent to complete** and review the generated plan.

The plan should use this structure:

### Plan Template Structure

```markdown
# Development Plan: [Feature Name]

**Created:** [Date]
**Status:** 📋 Approved
**Last Updated:** [Date]
**Overall Progress:** 0%

---

## 1. Overview

### Feature Description
[What we're building based on user requirements]

### Goals
- [Goal 1]
- [Goal 2]

### Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

---

## 2. Design Decisions (User Approved)

### Architecture
- **Data Model:** [User's choice]
- **State Management:** [User's choice]
- **Offline Support:** [User's choice]

### Technical Choices
- **New Packages:** [List if any]
- **Navigation:** [User's choice]
- **UI Flow:** [User's choice]

### Rationale
[Why these decisions make sense]

---

## 3. Implementation Phases

[11 phases total - see detailed template below]

Each phase must include:
- **Status:** ⏳ Pending | 🚧 In Progress | ✅ Completed
- **Agent:** [Which agent executes this]
- **Estimated Time:** [X] hours/minutes
- **Tasks:** Granular checklist with file paths
- **Deliverables:** What gets produced
- **Git Commit:** Exact commit message to use

---

## 4. File Structure

[Complete tree of files to create]

---

## 5. Dependencies

### New Packages Needed
- [ ] package_name: version - purpose

---

## 6. Risk Assessment

1. **Risk:** [Description]
   - **Mitigation:** [Strategy]
   - **Impact:** High/Medium/Low

---

## 7. Timeline Estimate

| Phase                 | Estimated Time |
| --------------------- | -------------- |
| Phase 1: Architecture | [X] hours      |
| ...                   | ...            |
| **Total**             | **[X] hours**  |

---

## 8. Progress Tracking

This section will be automatically updated as tasks are completed.

**Phase Status:**
- ✅ Completed: 0 phases
- 🚧 In Progress: 0 phases
- ⏳ Pending: 11 phases

**Last Updated:** [Will be updated by agents]
**Updated By:** [Agent name]

---

## 9. Notes

### Important Considerations
[Any special notes]

### Open Questions
- [ ] [To be resolved]
```

### Detailed Phase Template

Each of the 11 phases should follow this structure:

```markdown
### Phase X: [Phase Name]
**Status:** ⏳ Pending
**Agent:** [Agent name]
**Estimated Time:** [X] hours

**Tasks:**
- [ ] Task X.1: [Task name]
  - Status: ⏳ Pending
  - Files: `path/to/files/`
  - Details: [Specific details]

- [ ] Task X.2: [Task name]
  - Status: ⏳ Pending
  - Files: `path/to/files/`
  - Details: [Specific details]

**Deliverables:**
- [What gets produced]

**Git Commit:**
```bash
git add [files]
git commit -m "type(scope): description

Details:
- Detail 1
- Detail 2

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```
```

The 11 standard phases are:
1. Architecture & Specification
2. Domain Layer Implementation
3. Data Layer Implementation
4. Application Layer Implementation
5. Presentation Layer Implementation
6. Testing
7. Security Audit
8. Performance Optimization
9. Code Review
10. Final Verification
11. Pull Request

---

## Step 5: Present Plan for User Approval

Present the plan summary:

```markdown
# Development Plan Ready: [Feature Name]

I've created a comprehensive development plan based on our design discussions.

## Summary

**Total Phases:** 11
**Estimated Time:** [X] hours
**Files to Create:** ~[X] new files
**Test Coverage Target:** ≥80% overall, ≥95% domain

## Design Decisions (As You Approved)
✅ Data Model: [Your choice]
✅ State Management: [Your choice]
✅ Offline Support: [Your choice]
✅ UI Flow: [Your choice]

## What Happens Next

If you approve this plan:

1. ✅ I'll write it to `PLAN.md`
2. 📋 You can review the complete plan anytime in `PLAN.md`
3. 🚀 Run `/execute-plan` to begin implementation
4. 📊 `PLAN.md` updates automatically as tasks complete:
   - Task status: ⏳ → 🚧 → ✅
   - Phase progress tracking
   - Overall completion percentage
   - Git commits recorded

## Your Options

Please choose:
- ✅ **Approve** - Write plan to PLAN.md and proceed
- 🔄 **Adjust** - Make specific changes (tell me what)
- 💬 **Discuss** - Review specific phases in detail
- ❌ **Restart** - Different approach entirely
```

---

## Step 6: Get User Approval

Wait for explicit user approval before proceeding.

**Do NOT write the plan without approval.**

---

## Step 7: Ask Where to Save the Plan

After user approves the plan content, ask where to save it using AskUserQuestion:

```
Question: "Where should I save this development plan?"
Header: "Plan file"
Options:
- Label: "PLAN.md (Recommended)"
  Description: "Create or replace PLAN.md - standard location for /execute-plan command"
- Label: "Add to existing PLAN.md"
  Description: "Append this plan to the existing PLAN.md file (useful for multi-feature planning)"
- Label: "Separate file with custom name"
  Description: "Create a new file like plans/feature-name.md - useful for archiving or parallel plans"
```

**If user chooses "Separate file with custom name":**
```
Follow-up question: "What should I name the plan file?"
Suggest: plans/[feature-name-kebab-case].md

Example suggestions based on feature:
- "User Profile Management" → plans/user-profile-management.md
- "Authentication Flow" → plans/authentication-flow.md
- "Dashboard Widgets" → plans/dashboard-widgets.md
```

---

## Step 8: Write Plan to Selected Location

After approval and file location selection:

**Option A: PLAN.md (new/replace)**
```markdown
Use the Write tool to create/overwrite PLAN.md with the complete plan.
```

**Option B: Add to existing PLAN.md**
```markdown
1. Read existing PLAN.md
2. Add a separator and the new plan:
   ---

   # [NEW PLAN BELOW - Added on DATE]

   ---

   [New plan content]
3. Write the combined content back to PLAN.md
```

**Option C: Separate file**
```markdown
1. Create the plans/ directory if it doesn't exist
2. Write the plan to the specified path (e.g., plans/feature-name.md)
3. Note: /execute-plan defaults to PLAN.md, so inform user how to execute:
   - Either: move/copy to PLAN.md when ready to execute
   - Or: manually specify the file path when running execute-plan
```

---

## Step 9: Completion Message

Adjust the completion message based on where the plan was saved:

**If saved to PLAN.md:**
```markdown
✅ **Development Plan Created Successfully**

**File:** `PLAN.md`
**Status:** 📋 Approved - Ready for execution
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Next Steps

1. **Review the plan:** Open `PLAN.md` to see complete details
2. **Start execution:** Run `/execute-plan` when ready
3. **Track progress:** `PLAN.md` updates automatically with:
   - Real-time task status
   - Phase completion
   - Git commits made
   - Overall progress percentage

4. **Pause/Resume:** Stop anytime, resume later with `/execute-plan`
5. **Make changes:** Edit `PLAN.md` manually if needed

Ready to begin? Run `/execute-plan`
```

**If added to existing PLAN.md:**
```markdown
✅ **Development Plan Added Successfully**

**File:** `PLAN.md` (appended to existing plans)
**Status:** 📋 Approved - Ready for execution
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Next Steps

1. **Review the plan:** Open `PLAN.md` and scroll to the new plan section
2. **Start execution:** Run `/execute-plan` when ready
3. **Note:** Multiple plans in PLAN.md - /execute-plan will work on incomplete tasks

Ready to begin? Run `/execute-plan`
```

**If saved to separate file:**
```markdown
✅ **Development Plan Created Successfully**

**File:** `[chosen-path]` (e.g., `plans/feature-name.md`)
**Status:** 📋 Approved - Ready for execution
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Next Steps

1. **Review the plan:** Open `[chosen-path]` to see complete details
2. **To execute this plan, choose one option:**
   - **Option A:** Copy to PLAN.md when ready: `cp [chosen-path] PLAN.md`
   - **Option B:** Keep as archive and manually track progress

3. **Why separate file?**
   - Useful for planning multiple features in parallel
   - Good for archiving completed plans
   - Allows review before making it the "active" plan

## Available Commands

- `/execute-plan` - Execute PLAN.md (copy your plan there first)
- `/plan` - Create another plan
- `/implement` - Skip planning, streamlined workflow

Ready to execute? Copy to PLAN.md first: `cp [chosen-path] PLAN.md`
```

---

## Important Guidelines

### Always Involve the User

- ✅ Present architecture options, don't assume
- ✅ Show UI/UX alternatives for user choice
- ✅ Explain trade-offs of each approach
- ✅ Get explicit approval before finalizing
- ❌ Never make major decisions unilaterally

### Plan Quality Standards

- Break down into granular tasks (not too broad)
- Include specific file paths for each task
- Provide realistic time estimates
- Include complete git commit messages
- Identify risks and mitigation strategies
- Clear status indicators for tracking

### Flexibility

- Allow iterative refinement
- Accept user modifications
- Be open to alternative approaches
- Document rationale for decisions

---

## Usage

```bash
# Invoke this command
/plan

# Then you will:
# 1. Describe what you want to build
# 2. Answer design questions (presented as options)
# 3. Review the proposed plan
# 4. Approve, adjust, or discuss
# 5. Plan written to PLAN.md
# 6. Run /execute-plan to start implementation

# Example:
You: /plan
Claude: "What would you like to build?"
You: "User profile management"
Claude: [Asks clarifying questions with options]
You: [Choose options]
Claude: [Presents complete plan]
You: "Looks good, approve"
Claude: [Writes to PLAN.md]
You: /execute-plan
Claude: [Begins implementation, updates PLAN.md]
```

---

This command creates a **transparent, collaborative development process** where you maintain control of design decisions while leveraging systematic, high-quality implementation.
