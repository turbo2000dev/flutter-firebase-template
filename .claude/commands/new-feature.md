# New Feature Development

**Description:** Complete end-to-end feature development workflow from architecture design through implementation, testing, and code review.

---

## Alternative: Plan-Based Development

**Consider using `/plan` + `/execute-plan` instead if you want to:**
- Control architecture decisions before implementation
- See and approve a detailed plan first
- Track real-time progress in PLAN.md
- Pause and resume development
- Have complete documentation of design decisions

**To use plan-based approach:** Run `/plan` instead of this command.

**To continue with traditional approach:** Continue below.

---

You are orchestrating the complete development of a new feature for the application. Execute the following workflow systematically, using specialized agents for each phase.

## Workflow

### Phase 1: Architecture & Design

Launch the **Architect Agent** to create a comprehensive technical specification:

1. First, read the architect agent definition:
```
Read .claude/agents/architect.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Architecture design for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/architect.md, then add:
  "Now design the technical architecture for [FEATURE_NAME].
  Create a complete specification including domain models, data layer design, state management approach, Firebase structure, security considerations, and implementation guidance.
  Consider domain-specific and regulatory requirements."
```

**Wait for architect agent to complete** and review the technical specification produced.

**Checkpoint:** Verify the architecture specification includes:
- Clear domain model definitions
- Repository interfaces and implementations design
- State management approach with Riverpod providers
- Firebase collection structure
- Security considerations
- Performance considerations
- Testing strategy

If specification is incomplete or unclear, ask the user for clarification before proceeding.

**Git Commit:** Save the technical specification:
```bash
git add docs/ specs/
git commit -m "docs([FEATURE_SCOPE]): add technical specification

Architecture design by Architect Agent:
- Domain models defined
- Repository interfaces specified
- State management approach documented
- Firebase structure planned
- Security considerations outlined
- Performance targets set

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 2: Implementation

Launch the **Developer Agent** to implement the feature according to the specification:

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
  "Now implement [FEATURE_NAME] following the technical specification from the architect agent.
  Implement in order: domain layer → data layer → application layer → presentation layer.
  Run code generation with build_runner after implementing entities and providers.
  Write unit tests as you implement each layer."
```

**Wait for developer agent to complete** the implementation.

**Checkpoint:** Verify implementation includes:
- All layers implemented (domain/data/application/presentation)
- Code generation completed successfully
- Basic unit tests written
- No compilation errors

**Git Commits:** Commit each layer as implemented:

```bash
# After domain layer
git add lib/features/*/domain/
git commit -m "feat([FEATURE_SCOPE]): implement domain layer

- Add entities with Freezed
- Define repository interfaces
- Add value objects and exceptions

🤖 Generated with Claude Code"

# After data layer
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/data/
git commit -m "feat([FEATURE_SCOPE]): implement data layer

- Add DTOs with JSON serialization
- Implement repositories
- Add data sources (remote/local)
- Include offline support

🤖 Generated with Claude Code"

# After application layer
flutter pub run build_runner build --delete-conflicting-outputs
git add lib/features/*/application/
git commit -m "feat([FEATURE_SCOPE]): implement application layer

- Add Riverpod providers with code generation
- Implement controllers/notifiers
- Add state classes with Freezed
- Include form validation

🤖 Generated with Claude Code"

# After presentation layer
git add lib/features/*/presentation/
git commit -m "feat([FEATURE_SCOPE]): implement presentation layer

- Add screens and widgets
- Implement forms with validation
- Add loading/error states
- Include navigation

🤖 Generated with Claude Code"

git push origin [BRANCH_NAME]
```

---

### Phase 3: Comprehensive Testing

Launch the **Tester Agent** to create comprehensive test coverage:

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
  "Now create comprehensive test coverage for [FEATURE_NAME].
  Write unit tests for domain and data layers (targeting 95%+ coverage), widget tests for presentation layer, and integration tests for the complete feature workflow.
  Ensure all edge cases and error scenarios are tested.
  Run tests and generate coverage report."
```

**Wait for tester agent to complete** and review the test coverage report.

**Checkpoint:** Verify testing includes:
- Unit test coverage ≥80% (≥95% for critical paths)
- Widget tests for all screens/widgets
- Integration tests for workflows
- All tests passing
- Coverage report generated

**Git Commit:** Save the test suite:
```bash
git add test/
git commit -m "test([FEATURE_SCOPE]): add comprehensive test coverage

- Unit tests for domain/data layers (95%+ coverage)
- Widget tests for presentation layer
- Integration tests for workflows
- Edge cases and error scenarios covered

Total coverage: [X]%

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 4: Security Audit

Launch the **Security Agent** to audit the implementation:

1. First, read the security agent definition:
```
Read .claude/agents/security.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Security audit for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/security.md, then add:
  "Now conduct a comprehensive security audit of [FEATURE_NAME].
  Check for authentication/authorization issues, input validation, data protection, Firebase security, and common OWASP vulnerabilities.
  Verify compliance with security guidelines.
  Provide a detailed security report with any vulnerabilities found."
```

**Wait for security agent to complete** and review the security audit report.

**Checkpoint:** Verify no critical or high-severity security issues found. If issues found, developer agent must fix before proceeding.

**Git Commit (if fixes applied):**
```bash
git add lib/ test/
git commit -m "security([FEATURE_SCOPE]): address security audit findings

- Fix input validation issues
- Add data encryption for sensitive fields
- Update authentication checks
- Add audit logging

Security Audit: ✅ Passed (0 critical, 0 high)

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 5: Performance Review

Launch the **Performance Agent** to analyze and optimize:

1. First, read the performance agent definition:
```
Read .claude/agents/performance.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Performance optimization for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/performance.md, then add:
  "Now analyze the performance of [FEATURE_NAME].
  Check for rendering performance issues (const usage, widget optimization), memory leaks (disposal), network optimization (caching, pagination), and database performance (indexes, queries).
  Provide performance report with any issues and optimizations applied."
```

**Wait for performance agent to complete** and review the performance report.

**Checkpoint:** Verify performance meets targets (60fps, <100MB memory). Apply recommended optimizations if needed.

**Git Commit (if optimizations applied):**
```bash
git add lib/
git commit -m "perf([FEATURE_SCOPE]): optimize performance

- Add const constructors ([X] widgets)
- Implement RepaintBoundary in lists
- Add selective watching with .select()
- Optimize image loading with cache dimensions

Performance improvements:
- Frame time: [BEFORE]ms → [AFTER]ms
- Memory: -[X]MB
- Rebuild count: -[X]%

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 6: Code Review

Launch the **Reviewer Agent** for final code review:

1. First, read the reviewer agent definition:
```
Read .claude/agents/reviewer.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Code review for [FEATURE_NAME]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/reviewer.md, then add:
  "Now conduct a comprehensive code review of [FEATURE_NAME].
  Verify architecture compliance, code quality, state management best practices, test coverage, and adherence to coding standards.
  Check that all previous agent recommendations have been addressed.
  Provide a detailed review report with approval status."
```

**Wait for reviewer agent to complete** and review the code review report.

**Checkpoint:** Verify:
- No critical or major issues
- All coding standards followed
- Architecture principles maintained
- Previous agent issues addressed
- Tests comprehensive and passing

**Git Commit (if review fixes applied):**
```bash
git add lib/ test/
git commit -m "refactor([FEATURE_SCOPE]): address code review feedback

- Extract large widgets into smaller components
- Add missing error handling
- Improve documentation
- Fix naming inconsistencies

Code Review: ✅ Approved

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin [BRANCH_NAME]
```

---

### Phase 7: Final Verification

Run final checks:

1. **Analyze code:**
```bash
flutter analyze
```

2. **Run all tests:**
```bash
flutter test --coverage
```

3. **Check coverage:**
```bash
lcov --summary coverage/lcov.info
```

4. **Build app:**
```bash
flutter build apk --release --flavor dev
```

All checks must pass before feature is complete.

---

### Phase 8: Create Pull Request

Create a pull request on GitHub:

```bash
# Ensure all changes are pushed
git push origin [BRANCH_NAME]

# Create PR using GitHub CLI (or use GitHub web interface)
gh pr create --title "feat([FEATURE_SCOPE]): [FEATURE_NAME]" --body "## Description
[Brief description of the feature]

## Type of Change
- [x] New feature

## Agent Workflow
- [x] Architecture designed (Architect Agent)
- [x] Implementation completed (Developer Agent)
- [x] Tests written (Tester Agent) - [X]% coverage
- [x] Security audit passed (Security Agent)
- [x] Performance optimized (Performance Agent)
- [x] Code review approved (Reviewer Agent)

## Quality Assurance

### Testing
- Unit tests: [X]% coverage
- Widget tests: ✅ Passing
- Integration tests: ✅ Passing
- All tests passing: ✅ [X]/[X]

### Security
- Security audit: ✅ No critical/high issues
- Input validation: ✅ Present
- Authentication: ✅ Verified
- Data protection: ✅ Encrypted

### Performance
- Frame rate: ✅ [X]fps (target 60fps)
- Memory usage: ✅ [X]MB (target <100MB)
- Initial load: ✅ [X]s (target <3s)

## Agent Reports
- Technical Specification: [link or attached]
- Test Coverage Report: [link or attached]
- Security Audit: [link or attached]
- Performance Report: [link or attached]
- Code Review: [link or attached]

## Related Issues
Closes #[ISSUE_NUMBER]

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# PR will automatically trigger CI/CD pipeline
# Wait for all checks to pass before merging
```

---

## Completion Report

After all phases complete successfully, provide a summary to the user:

```markdown
# Feature Development Complete: [FEATURE_NAME]

## Summary
✓ Architecture designed and documented
✓ Implementation completed across all layers
✓ Comprehensive tests written and passing
✓ Security audit passed (no critical/high issues)
✓ Performance optimized (meets all targets)
✓ Code review approved
✓ All changes committed and pushed
✓ Pull request created

## Metrics
- Test Coverage: X%
- Tests Passing: X/X
- Security Issues: X critical, X high, X medium, X low
- Performance: X fps, X MB memory
- Files Changed: X
- Commits: X

## Git Information
- Branch: [BRANCH_NAME]
- Commits: [X] commits pushed
- Pull Request: #[PR_NUMBER]
- CI/CD Status: Pending/Running

## Next Steps
1. ✅ Wait for CI/CD pipeline to complete (GitHub Actions)
2. ✅ Address any CI/CD failures if they occur
3. ✅ Request code review from team members
4. ✅ Address review feedback if any
5. ✅ Merge PR after approval and passing checks
6. ✅ Verify deployment to Firebase Hosting (if main branch)
7. ✅ Close related issues

## CI/CD Pipeline
The following checks will run automatically:
- Code Quality (formatting, analysis)
- Code Generation (build_runner)
- Tests (with coverage check ≥80%)
- Security Audit (vulnerability scan)
- Build (Android, iOS, Web)
- Deploy (Firebase Hosting on main branch)

## Pull Request Link
[https://github.com/[ORG]/[REPO]/pull/[PR_NUMBER]]

## Documentation
- Technical specification: [location]
- Test report: [location]
- Security audit: [location]
- Performance report: [location]
- Code review: [location]

---
Monitor CI/CD progress at: [GitHub Actions URL]
```

---

## Notes

- Each phase builds on the previous phase's output
- Do not skip phases even if they seem unnecessary
- If any agent reports blocking issues, address them before proceeding
- User can request to skip specific phases (e.g., security audit for minor UI changes)
- All agent outputs should be saved for reference

## Usage

```bash
# Invoke this command
/new-feature

# You will be prompted for:
# - Feature name
# - Feature description
# - Any special considerations
```

This command ensures systematic, high-quality feature development with proper architecture, implementation, testing, security, performance, and review.
