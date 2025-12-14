# Implement Feature

**Description:** Implement a feature with an existing technical specification. Includes implementation and testing, skips architecture design and full review cycle.

---

## Alternative: Plan-Based Development

**Consider using `/plan` + `/execute-plan` instead if you want to:**
- Control implementation decisions
- See and approve a detailed plan first
- Track real-time progress in PLAN.md
- Pause and resume development
- Have complete documentation of implementation steps

**To use plan-based approach:** Run `/plan` instead of this command.

**To continue with traditional approach:** Continue below.

---

You are implementing a feature that already has a technical specification. This is faster than `/new-feature` as it skips architecture design and uses a lighter review process.

## Prerequisites

Ensure you have:
- Technical specification or clear requirements
- Understanding of where this fits in the architecture
- Any design mockups or examples needed

## Workflow

### Phase 1: Implementation

Launch the **Developer Agent** to implement the feature:

1. First, read the developer agent definition:
```
Read .claude/agents/developer.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Implementation of [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/developer.md, then add:
  "Now implement [FEATURE_NAME] according to the provided specification or requirements.
  Implement in order: domain layer → data layer → application layer → presentation layer.
  Run code generation with build_runner after implementing entities and providers.
  Write unit tests for domain and data layers as you implement.
  Specification: [SPECIFICATION_DETAILS]"
```

**Wait for developer agent to complete** the implementation.

**Checkpoint:** Verify:
- All layers implemented correctly
- Code generation run successfully (no errors from build_runner)
- Basic unit tests written for domain/data layers
- Code compiles without errors

**Git Commits:** Commit implementation phases:

```bash
# After domain + data layers
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/domain/ lib/features/*/data/
git commit -m "feat([FEATURE_SCOPE]): implement domain and data layers

- Add entities and DTOs with Freezed/JSON serialization
- Implement repositories
- Add data sources with offline support

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

# After application + presentation layers
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/application/ lib/features/*/presentation/
git commit -m "feat([FEATURE_SCOPE]): implement application and presentation layers

- Add Riverpod providers and controllers
- Implement screens and widgets
- Add form validation and state management

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin [BRANCH_NAME]
```

---

### Phase 2: Testing

Launch the **Tester Agent** to ensure adequate test coverage:

1. First, read the tester agent definition:
```
Read .claude/agents/tester.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Testing for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/tester.md, then add:
  "Now create test coverage for [FEATURE_NAME].
  Write unit tests for business logic, widget tests for UI components, and at least one integration test for the main workflow.
  Target 80%+ overall coverage with 95%+ for domain layer.
  Run tests and generate coverage report."
```

**Wait for tester agent to complete** and review coverage report.

**Checkpoint:** Verify:
- Test coverage ≥80% overall
- Domain layer coverage ≥95%
- All tests passing
- Edge cases covered

**Git Commit:** Save tests:

```bash
git add test/
git commit -m "test([FEATURE_SCOPE]): add test coverage

- Unit tests for business logic
- Widget tests for UI components
- Integration test for main workflow

Coverage: [X]%

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 3: Quick Review

Perform automated checks:

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Check test coverage
flutter test --coverage
lcov --summary coverage/lcov.info
```

If issues found, use developer agent to fix them.

**Git Commit (if fixes needed):**

```bash
git add lib/ test/
git commit -m "fix([FEATURE_SCOPE]): address automated check issues

- Fix formatting issues
- Resolve analysis warnings
- Fix failing tests

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 4: Build Verification

Verify the app builds successfully:

```bash
# Development build
flutter build apk --debug --flavor dev
```

---

### Phase 5: Create Pull Request

Create a pull request on GitHub:

```bash
# Ensure all changes are pushed
git push origin [BRANCH_NAME]

# Create PR using GitHub CLI (or use GitHub web interface)
gh pr create --title "feat([FEATURE_SCOPE]): [FEATURE_NAME]" --body "## Description
[Brief description of the feature]

## Type of Change
- [x] New feature / Bug fix / Refactoring

## Implementation
- [x] Implementation completed (Developer Agent)
- [x] Tests written (Tester Agent) - [X]% coverage
- [x] Code analysis passed
- [x] Build verified

## Quality Assurance

### Testing
- Unit tests: [X]% coverage
- Widget tests: ✅ Passing
- Integration tests: ✅ Passing

## Next Steps
- Security review (if handling sensitive data): Run `/security-audit`
- Performance review (if complex): Run `/optimize`
- Full code review: Run `/review`

## Related Issues
Closes #[ISSUE_NUMBER]

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# PR will automatically trigger CI/CD pipeline
```

---

## Completion Report

Provide summary to user:

```markdown
# Implementation Complete: [FEATURE_NAME]

## Summary
✓ Feature implemented across all necessary layers
✓ Tests written and passing
✓ Code analysis passed
✓ Build successful
✓ All changes committed and pushed
✓ Pull request created

## Metrics
- Test Coverage: X%
- Tests Passing: X/X
- Files Changed: X files
- Commits: X
- Build Status: ✓ Success

## Git Information
- Branch: [BRANCH_NAME]
- Commits: [X] commits pushed
- Pull Request: #[PR_NUMBER]
- CI/CD Status: Pending/Running

## What Was Implemented
- Domain: [entities, value objects, repositories]
- Data: [repository implementations, data sources, DTOs]
- Application: [providers, controllers, state classes]
- Presentation: [screens, widgets, forms]

## Testing
- Unit Tests: X tests
- Widget Tests: X tests
- Integration Tests: X tests

## Next Steps
1. ✅ Wait for CI/CD pipeline to complete (GitHub Actions)
2. ✅ Address any CI/CD failures if they occur
3. Manual testing recommended
4. Consider additional reviews:
   - `/security-audit` - If handling sensitive data
   - `/optimize` - If complex UI/calculations
   - `/review` - For full code review before merge
5. ✅ Merge PR after approval and passing checks
6. ✅ Verify deployment (if merged to main)

## CI/CD Pipeline
The following checks will run automatically:
- Code Quality (formatting, analysis)
- Code Generation (build_runner)
- Tests (with coverage check ≥80%)
- Security Audit (vulnerability scan)
- Build (Android, iOS, Web)

## Pull Request Link
[https://github.com/[ORG]/[REPO]/pull/[PR_NUMBER]]

---
Monitor CI/CD progress at: [GitHub Actions URL]
```

---

## When to Use

Use `/implement` instead of `/new-feature` when:
- You have a clear technical specification already
- The feature is straightforward and low-risk
- You want faster iteration
- Full security/performance audits not needed immediately

Use `/new-feature` when:
- Complex or critical feature
- Architecture decisions needed
- Security-sensitive functionality
- Performance-critical code
- High visibility or risk

## Usage

```bash
# Invoke this command
/implement

# You will be prompted for:
# - Feature name
# - Technical specification or requirements
# - Any special considerations
```

This command provides a streamlined implementation workflow while maintaining quality through testing and basic verification.
