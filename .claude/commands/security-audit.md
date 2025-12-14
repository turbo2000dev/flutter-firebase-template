# Security Audit

**Description:** Comprehensive security audit using the Security agent to identify vulnerabilities and ensure secure coding practices.

---

You are conducting a security audit of the application to identify vulnerabilities, security risks, and compliance issues.

## Usage

```bash
/security-audit [optional: specific feature or files to audit]
```

## Workflow

### Phase 1: Scope Definition

Determine audit scope:

**Full Application Audit:**
- All authentication and authorization code
- All data handling (input/output)
- All network operations
- Firebase configuration and security rules
- Sensitive data storage

**Feature-Specific Audit:**
- Focused on specific feature or files
- Related data flows
- Relevant security controls

Ask user for scope if not specified.

---

### Phase 2: Security Audit

Launch the **Security Agent** to conduct comprehensive audit:

1. First, read the security agent definition:
```
Read .claude/agents/security.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Security audit of [SCOPE]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/security.md, then add:
  "Now conduct a comprehensive security audit of [SCOPE].
  Check for OWASP Top 10 vulnerabilities and provide detailed findings.
  Provide your security audit report following the format specified in your agent definition.
  Scope: [SCOPE_DESCRIPTION]"
```

**Wait for security agent to complete** and review the audit report.

---

### Phase 3: Automated Security Checks

Run automated security analysis:

```bash
echo "=== Automated Security Checks ==="

# 1. Check for hardcoded secrets
echo -e "\n1. Checking for hardcoded secrets..."
grep -r -i "apikey\s*=\s*['\"]" --include="*.dart" lib/ && echo "⚠️  Found potential hardcoded API keys" || echo "✓ No hardcoded API keys found"

grep -r -i "password\s*=\s*['\"][^'\"]*['\"]" --include="*.dart" lib/ && echo "⚠️  Found potential hardcoded passwords" || echo "✓ No hardcoded passwords found"

grep -r -i "secret\s*=\s*['\"]" --include="*.dart" lib/ && echo "⚠️  Found potential hardcoded secrets" || echo "✓ No hardcoded secrets found"

# 2. Check for insecure Random usage
echo -e "\n2. Checking for insecure random number generation..."
grep -r "Random()" --include="*.dart" lib/ | grep -v "Random.secure()" && echo "⚠️  Found insecure Random() usage" || echo "✓ No insecure Random usage"

# 3. Check for SQL injection risks
echo -e "\n3. Checking for SQL injection risks..."
grep -r "rawQuery.*\$" --include="*.dart" lib/ && echo "⚠️  Found potential SQL injection vector" || echo "✓ No SQL injection risks found"

# 4. Check for missing input validation
echo -e "\n4. Checking for missing input validation..."
grep -r "fromJson" --include="*.dart" lib/ | head -5
echo "(Review above to ensure validation is present)"

# 5. Check for logging sensitive data
echo -e "\n5. Checking for sensitive data in logs..."
grep -r "print(" --include="*.dart" lib/ | grep -i "password\|token\|secret" && echo "⚠️  Found potential sensitive data logging" || echo "✓ No sensitive data logging found"

# 6. Check for missing controller disposal
echo -e "\n6. Checking for missing disposal..."
grep -r "Controller()" --include="*.dart" lib/ | wc -l | xargs echo "Controllers found:"
echo "(Verify all are properly disposed)"

# 7. Check for HTTP (non-HTTPS) usage
echo -e "\n7. Checking for insecure HTTP usage..."
grep -r "http://" --include="*.dart" lib/ && echo "⚠️  Found HTTP (non-HTTPS) URLs" || echo "✓ No insecure HTTP found"

echo -e "\n=== Security Checks Complete ===\n"
```

---

### Phase 4: Security Report

Provide comprehensive security report to user:

```markdown
# Security Audit Report

## Executive Summary

**Security Posture:** 🔴 Critical Risk / 🟡 High Risk / 🟢 Acceptable / ✅ Excellent

**Audit Scope:** [Description of what was audited]

**Vulnerabilities Found:**
- 🔴 Critical: X (Must fix immediately)
- 🟡 High: X (Fix urgently)
- 🟢 Medium: X (Fix soon)
- ℹ️ Low: X (Consider fixing)

**Compliance Status:**
- PIPEDA: ✓ Compliant / ⚠️ Issues
- Security Guidelines: ✓ Compliant / ⚠️ Issues
- OWASP Top 10: ✓ Secure / ⚠️ Vulnerabilities

---

## Critical Vulnerabilities 🔴

### 1. [Vulnerability Title]

**Severity:** Critical
**CVSS Score:** X.X (Base score)
**Location:** `file.dart:line`

**Vulnerability Description:**
[What the vulnerability is]

**Attack Vector:**
[How an attacker could exploit this]

**Exploitation Difficulty:** Easy / Medium / Hard
**Attack Complexity:** Low / High

**Impact:**
- Confidentiality: High / Medium / Low
- Integrity: High / Medium / Low
- Availability: High / Medium / Low

**Potential Damage:**
[What could happen if exploited]

**Affected Components:**
- [List of affected components]

**Proof of Concept:**
```dart
// Example of how vulnerability could be exploited
[attack code or scenario]
```

**Remediation:**

**Priority:** Immediate

**Steps to Fix:**
1. [Specific action]
2. [Specific action]
3. [Specific action]

**Fixed Code:**
```dart
// Before (vulnerable)
[vulnerable code]

// After (secure)
[secure code]
```

**Verification:**
[How to verify the fix works]

**References:**
- [CWE-XXX: Vulnerability Name]
- [OWASP: Related Guidance]

---

## High Priority Vulnerabilities 🟡

[List high-severity issues requiring urgent attention]

---

## Medium Priority Issues 🟢

[List medium-severity issues to address soon]

---

## Low Priority Observations ℹ️

[List minor security improvements]

---

## OWASP Top 10 Assessment

1. **A01: Broken Access Control** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

2. **A02: Cryptographic Failures** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

3. **A03: Injection** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

4. **A04: Insecure Design** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

5. **A05: Security Misconfiguration** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

6. **A06: Vulnerable Components** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

7. **A07: Authentication Failures** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

8. **A08: Data Integrity Failures** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

9. **A09: Logging Failures** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
   - [Findings]

10. **A10: SSRF** - ✓ Secure / ⚠️ Issues / 🔴 Vulnerable
    - [Findings]

---

## Compliance Assessment

### PIPEDA (Canadian Privacy Law)
- [ ] Consent obtained for data collection
- [ ] Privacy policy present and accessible
- [ ] Data minimization practiced
- [ ] Right to access implemented
- [ ] Right to deletion implemented
- [ ] Data portability supported
- [ ] Breach notification process defined

**Status:** ✓ Compliant / ⚠️ Issues Found

**Issues:** [List any issues]

### Security Guidelines Compliance
- [ ] Authentication requirements met
- [ ] Input validation implemented
- [ ] Data encryption at rest
- [ ] Data encryption in transit
- [ ] Audit logging present
- [ ] Session management secure

**Status:** ✓ Compliant / ⚠️ Issues Found

**Issues:** [List any issues]

---

## Automated Checks Results

```
Hardcoded Secrets: ✓ None found / ⚠️ X found
Insecure Random: ✓ None found / ⚠️ X found
SQL Injection Risks: ✓ None found / ⚠️ X found
Sensitive Data Logging: ✓ None found / ⚠️ X found
HTTP Usage: ✓ None found / ⚠️ X found
```

---

## Remediation Plan

### Immediate Actions (Fix Now)
1. [Critical vulnerability fix]
2. [Critical vulnerability fix]

**Timeline:** Within 24 hours

### Urgent Actions (Fix This Week)
1. [High-priority fix]
2. [High-priority fix]

**Timeline:** Within 7 days

### Short-term Actions (Fix This Sprint)
1. [Medium-priority fix]
2. [Medium-priority fix]

**Timeline:** Within 2 weeks

### Long-term Improvements (Plan for Future)
1. [Security enhancement]
2. [Security enhancement]

**Timeline:** Next quarter

---

## Security Best Practices Observed ✅

- ✓ [Good security practice found]
- ✓ [Proper implementation noted]
- ✓ [Excellent security control]

---

## Recommendations

### Process Improvements
1. [Recommendation for development process]
2. [Recommendation for security practices]

### Technical Improvements
1. [Technical security enhancement]
2. [Architecture security improvement]

### Training Needs
1. [Security training recommendation]
2. [Awareness improvement]

---

## Re-audit Requirements

**Re-audit Needed:** Yes / No

**If Yes, When:** After critical fixes applied

**Focus Areas:** [Specific areas to re-check]

---

## Appendix

### Security Tools Used
- Manual code review by Security Agent
- Automated pattern matching
- Vulnerability database checks

### References
- [OWASP Mobile Security Testing Guide]
- [CWE/SANS Top 25 Most Dangerous Software Errors]
- [NIST Cybersecurity Framework]

```

---

### Phase 5: Remediation Assistance

If vulnerabilities found, offer to help fix them:

1. For critical issues, provide immediate fixes
2. For high-priority issues, guide developer on fixes
3. Offer to re-run audit after fixes applied

---

## When to Use

Use `/security-audit` for:
- Before releasing new features
- After implementing authentication/authorization
- When handling sensitive user data
- Before deployment to production
- Periodically (quarterly) for ongoing security
- After security incident
- Before security compliance review

---

## Audit Scope Options

```bash
# Full application audit
/security-audit

# Feature-specific audit
/security-audit features/auth

# Focus on specific security aspects
/security-audit --input-validation
/security-audit --authentication
/security-audit --data-protection
/security-audit --firebase-rules

# Quick security check
/security-audit --quick
```

---

## {{TARGET_REGION}}-Specific Security

For {{TARGET_REGION}} financial data:
- PIPEDA compliance verification
- Financial data protection standards
- Bilingual privacy policy check
- {{TARGET_REGION}}-specific regulations

---

This command ensures the application is secure and protects sensitive user financial data from threats and vulnerabilities.
