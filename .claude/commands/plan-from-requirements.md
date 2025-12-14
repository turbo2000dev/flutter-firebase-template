# Plan from Requirements File

**Description:** Create a detailed development plan from a requirements specification file, with user involvement in design decisions.

---

You are creating a comprehensive development plan based on requirements documented in a file. This command reads the requirements, asks design questions, and creates a detailed plan in PLAN.md. This is a crucial and very important element in the project execution. Therefore, read carefully the requirements, take proper time to analyze and ultrathink to produce the final result. 

## Your Task

1. **Read the requirements file** to understand what needs to be built
2. **Analyze the codebase** to understand existing architecture
3. **Present design decisions** for user approval
4. **Create a detailed plan** broken down into phases and tasks
5. **Write the approved plan** to `PLAN.md`

---

## Step 1: Read Requirements File

First, ask the user for the requirements file path (or use default):

```markdown
📋 **Plan from Requirements**

Please provide the path to your requirements file.

**Default:** `requirements.md` or `specs/00_index.md` (press Enter to use default)
**Or specify:** Path to your requirements file (e.g., `specs/feature-x.md`, `docs/requirements/user-profiles.md`)

Enter path:
```

Then read the specified file:

```bash
# Use Read tool to read the requirements file
Read: [specified_path or requirements.md or specs/00_index.md]
```

If file doesn't exist:
```markdown
❌ **Requirements File Not Found**

The file `[path]` does not exist.

Please either:
1. Create the file with your requirements
2. Specify a different path
3. Use `/plan` command to describe requirements interactively

Example requirements.md structure:
```markdown
# Feature: [Feature Name]

## Overview
[Brief description of what you want to build]

## Goals
- [Goal 1]
- [Goal 2]

## Requirements

### Functional Requirements
- [Requirement 1]
- [Requirement 2]

### Non-Functional Requirements
- Performance: [targets]
- Security: [considerations]
- Usability: [requirements]

## User Stories (optional)
- As a [user type], I want [goal] so that [benefit]

## Constraints (optional)
- [Constraint 1]
- [Constraint 2]

## Out of Scope (optional)
- [What is NOT included]
```

Would you like to create this file now?
```

---

## Step 2: Understand Requirements

After reading the requirements file:

1. **Parse and understand:**
   - Feature name and overview
   - Functional requirements
   - Non-functional requirements
   - User stories (if provided)
   - Constraints
   - What's out of scope

2. **Summarize back to user:**
   ```markdown
   📋 **Requirements Summary**

   Based on `[file_path]`:

   **Feature:** [Feature Name]

   **Overview:**
   [Summary of what will be built]

   **Key Requirements:**
   - [Requirement 1]
   - [Requirement 2]
   - [Requirement 3]

   **Constraints:**
   - [Constraint 1]
   - [Constraint 2]

   **Quality Targets:**
   - Performance: [targets from requirements]
   - Security: [requirements]
   - Test Coverage: [if specified, or default ≥80%]

   Does this match your understanding? (yes/no/adjust)
   ```

3. **Wait for confirmation** before proceeding

---

## Step 3: Ask Clarifying Questions

If requirements are unclear or incomplete, ask clarifying questions:

```markdown
I have a few questions to clarify the requirements:

Use AskUserQuestion tool with questions like:
- "The requirements mention [X] but don't specify [Y]. What should we do?"
- "Should [feature aspect] include [option A] or [option B]?"
- "The requirements don't mention [important aspect]. Should we include it?"
```

---

## Step 4: Analyze Codebase

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

  Requirements summary:
  [Include parsed requirements from Step 2]

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

## Step 5: Design Review - User Involvement

**IMPORTANT:** Present ALL major design decisions to the user for approval.

### Architecture Decisions to Present

Use AskUserQuestion to present options:

**1. Data Model Structure**
```
Question: "Based on the requirements, how should we structure the data model for [feature]?"
Options:
- Single entity with nested data (simpler, less flexible)
  Description: All data in one model, easier to start with, harder to extend
- Separate entities with relationships (normalized, more complex)
  Description: Multiple models with references, more flexible, better separation
- Hybrid approach (balance of both)
  Description: Main entity with some nested data and some relationships
```

**2. State Management Approach**
```
Question: "What state management approach for [feature]?"
Options:
- Local state (simple, screen-specific)
  Description: State lives in individual screens/widgets, not shared
- Global state with providers (shared across app)
  Description: State accessible from anywhere, persists across navigation
- Mixed approach (local + global where needed)
  Description: Most state is local, only shared data is global
```

**3. Offline Support Strategy** (if requirements mention offline)
```
Question: "What offline support should [feature] have?"
Options:
- Full offline support (local cache, sync)
  Description: Works completely offline, syncs when online
- Read-only offline (cached data, no edits)
  Description: View cached data offline, edits require connection
- Online-only (requires connection)
  Description: Simpler implementation, no offline complexity
```

**4. UI/UX Flow** (if applicable)
```
Question: "Based on the requirements, what should the user flow be for [feature]?"
Options:
- Single screen with sections
  Description: All functionality on one screen, simpler navigation
- Multi-step wizard
  Description: Break into steps, better for complex flows
- Tab-based navigation
  Description: Related sections in tabs, easy switching
- Modal/bottom sheet
  Description: Overlay on current screen, contextual actions
```

**5. Additional Technical Choices**
- Which libraries or packages to use (if new ones needed)
- Navigation patterns to follow
- Form structure and validation approach
- Error handling strategy
- Caching approach

---

## Step 6: Create Development Plan

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

  Requirements:
  [Include full requirements from Step 2]

  Codebase Analysis Results:
  [Include findings from Step 4]

  User-Approved Design Decisions:
  [Include all decisions from Step 5]

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
  - Requirements traceability (map each requirement to implementation tasks)

  Output the complete plan in markdown format ready to be written to PLAN.md."
```

**Wait for architect agent to complete** and review the generated plan.

The plan should follow the structure from `/plan` command:

The plan should include:

### Header
```markdown
# Development Plan: [Feature Name]

**Created:** [Date]
**Status:** 📋 Approved
**Last Updated:** [Date]
**Overall Progress:** 0%
**Requirements Source:** [file_path]

---
```

### Overview Section
```markdown
## 1. Overview

### Feature Description
[From requirements file]

### Goals
[From requirements file]

### Success Criteria
[From requirements file, converted to checkboxes]
- [ ] [Criterion 1]
- [ ] [Criterion 2]

---
```

### Design Decisions Section
```markdown
## 2. Design Decisions (User Approved)

### Architecture
- **Data Model:** [User's choice - explain decision]
- **State Management:** [User's choice - explain decision]
- **Offline Support:** [User's choice - explain decision]

### Technical Choices
- **New Packages:** [List if any, with justification]
- **Navigation:** [User's choice - explain decision]
- **UI Flow:** [User's choice - explain decision]

### Rationale
[Explain why these decisions make sense for this feature]

### Requirements Coverage
How these decisions satisfy the requirements:
- [Requirement 1] → [Satisfied by X decision]
- [Requirement 2] → [Satisfied by Y decision]

---
```

### Implementation Phases
Use the same 11-phase structure as `/plan` command:
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

For each phase:
- Specific tasks derived from requirements
- File paths based on feature name
- Deliverables aligned with requirements
- Git commit messages

### Additional Sections
```markdown
## 4. File Structure
[Complete tree of files to create based on requirements]

## 5. Dependencies
[New packages needed to satisfy requirements]

## 6. Risk Assessment
[Risks identified from requirements and decisions]

## 7. Timeline Estimate
[Time breakdown by phase]

## 8. Progress Tracking
[Real-time status tracking]

## 9. Notes
### Requirements Traceability
Map requirements to implementation:
- Requirement 1 → Implemented in Phase X, Task Y
- Requirement 2 → Implemented in Phase X, Task Y

### Open Questions
- [ ] [Any questions from requirements that need answering]
```

---

## Step 7: Present Plan for User Approval

Present the plan summary:

```markdown
# Development Plan Ready: [Feature Name]

I've created a comprehensive development plan based on the requirements in `[file_path]`.

## Summary

**Requirements Source:** `[file_path]`
**Total Phases:** 11
**Estimated Time:** [X] hours
**Files to Create:** ~[X] new files
**Test Coverage Target:** ≥80% overall, ≥95% domain

## Requirements Coverage

All requirements from the file are addressed:
- ✅ [Requirement 1] - Covered in Phase X
- ✅ [Requirement 2] - Covered in Phase X
- ✅ [Requirement 3] - Covered in Phase X

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
- 📝 **Update Requirements** - Modify requirements file and restart
- ❌ **Cancel** - Don't create plan
```

---

## Step 8: Get User Approval

Wait for explicit user approval before proceeding.

**Do NOT write the plan without approval.**

If user requests adjustments:
- Make the changes
- Present updated plan
- Get approval again

---

## Step 9: Ask Where to Save the Plan

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

## Step 10: Write Plan to Selected Location

After approval and file location selection:

**Option A: PLAN.md (new/replace)**
```markdown
Use the Write tool to create/overwrite PLAN.md with the complete plan.

Include at the top:
**Requirements Source:** [file_path]
**Requirements Last Modified:** [file modification date]
```

**Option B: Add to existing PLAN.md**
```markdown
1. Read existing PLAN.md
2. Add a separator and the new plan:
   ---

   # [NEW PLAN BELOW - Added on DATE]
   # Requirements Source: [file_path]

   ---

   [New plan content]
3. Write the combined content back to PLAN.md
```

**Option C: Separate file**
```markdown
1. Create the plans/ directory if it doesn't exist
2. Write the plan to the specified path (e.g., plans/feature-name.md)
3. Include requirements source reference in the plan header
4. Note: /execute-plan defaults to PLAN.md, so inform user how to execute:
   - Either: move/copy to PLAN.md when ready to execute
   - Or: manually specify the file path when running execute-plan
```

---

## Step 11: Link Requirements File

Add a reference to the requirements file in the plan:

```markdown
## Requirements Document

This plan was created from: `[file_path]`

**Requirements can be found at:** [file_path]

**If requirements change:**
1. Update the requirements file
2. Run `/plan-from-requirements` again
3. Review changes in the new plan
4. Decide: start new plan or adjust existing one
```

---

## Step 12: Completion Message

Adjust the completion message based on where the plan was saved:

**If saved to PLAN.md:**
```markdown
✅ **Development Plan Created Successfully**

**File:** `PLAN.md`
**Status:** 📋 Approved - Ready for execution
**Requirements Source:** `[file_path]`
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Plan Summary

All requirements from `[file_path]` have been incorporated into the plan.

**Requirements Coverage:**
- [X] requirements addressed
- [X] design decisions made
- [X] phases planned
- [X] tasks defined

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

## Requirements Traceability

The plan includes a "Requirements Traceability" section showing:
- Which requirement is implemented in which phase
- How each requirement is satisfied
- Test coverage for each requirement

Ready to begin? Run `/execute-plan`
```

**If added to existing PLAN.md:**
```markdown
✅ **Development Plan Added Successfully**

**File:** `PLAN.md` (appended to existing plans)
**Status:** 📋 Approved - Ready for execution
**Requirements Source:** `[file_path]`
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Plan Summary

All requirements from `[file_path]` have been incorporated into the plan.

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
**Requirements Source:** `[file_path]`
**Total Phases:** 11
**Estimated Duration:** [X] hours

## Plan Summary

All requirements from `[file_path]` have been incorporated into the plan.

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
- `/plan-from-requirements` - Create another plan from requirements
- `/plan` - Create plan interactively

Ready to execute? Copy to PLAN.md first: `cp [chosen-path] PLAN.md`
```

---

## Important Guidelines

### Always Involve the User

- ✅ Present design options, don't assume
- ✅ Explain trade-offs of each approach
- ✅ Get explicit approval before finalizing
- ✅ Confirm understanding of requirements
- ❌ Never make major decisions unilaterally

### Requirements Fidelity

- ✅ Cover ALL requirements from the file
- ✅ Ask about missing information
- ✅ Clarify ambiguous requirements
- ✅ Document requirements-to-implementation mapping
- ✅ Include requirements source in plan

### Plan Quality Standards

- Break down into granular tasks
- Include specific file paths
- Provide realistic time estimates
- Include complete git commit messages
- Map requirements to tasks
- Identify risks from requirements
- Clear status indicators for tracking

### Flexibility

- Allow iterative refinement
- Accept user modifications
- Support updated requirements
- Be open to alternative approaches
- Document rationale for decisions

---

## Handling Requirements Updates

If user says requirements have changed:

```markdown
📝 **Requirements Updated**

I see the requirements file has been updated.

**Options:**
1. **Create new plan** - Start fresh with updated requirements
2. **Update existing plan** - Modify PLAN.md to incorporate changes
3. **Show diff** - Compare old vs new requirements first

What would you like to do?

If creating new plan:
- Old PLAN.md will be overwritten
- Consider backing it up first: `cp PLAN.md PLAN.md.backup`
- Or commit current plan to git before updating
```

---

## Usage

```bash
# Invoke this command
/plan-from-requirements

# You will then:
# 1. Provide path to requirements file (or use default: requirements.md)
# 2. Confirm understanding of requirements
# 3. Answer design questions
# 4. Review the proposed plan
# 5. Approve or request adjustments
# 6. Plan is written to PLAN.md
# 7. Run /execute-plan to begin
```

---

## Example Requirements File

If the user doesn't have a requirements file yet, suggest this template:

```markdown
# Feature: [Feature Name]

## Overview
Brief description of what you want to build and why.

## Goals
- Primary goal 1
- Primary goal 2
- Primary goal 3

## Success Criteria
How will we know this feature is successful?
- Measurable criterion 1
- Measurable criterion 2
- Measurable criterion 3

## Functional Requirements

### Must Have
- Requirement 1
- Requirement 2
- Requirement 3

### Should Have
- Requirement 4
- Requirement 5

### Nice to Have
- Requirement 6

## Non-Functional Requirements

### Performance
- Target load time: <3s
- Target frame rate: 60fps
- Memory limit: <100MB

### Security
- Authentication required: Yes/No
- Data encryption: Required for [specify fields]
- Compliance: GDPR, PIPEDA, etc.

### Usability
- Mobile-first design
- Accessibility: WCAG 2.1 Level AA
- Offline support: [Full/Read-only/Online-only]

### Testing
- Test coverage target: ≥80%
- Critical path coverage: 100%

## User Stories

### Story 1
**As a** [user type]
**I want** [goal]
**So that** [benefit]

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

### Story 2
[repeat as needed]

## Technical Constraints
- Must integrate with: [existing systems]
- Must use: [specific technologies]
- Cannot use: [prohibited technologies]
- Performance budget: [specific limits]

## Dependencies
- Dependent on: [other features/systems]
- Blocks: [what depends on this]

## Out of Scope
Explicitly what is NOT included:
- [Thing 1]
- [Thing 2]

## Open Questions
- [ ] Question 1 that needs answering
- [ ] Question 2 that needs answering

## References
- Design mockups: [link]
- User research: [link]
- Related documentation: [link]
```

---

This command creates a **requirements-driven, transparent development process** where you document requirements first, maintain design control, and get systematic implementation with full traceability from requirements to code.
