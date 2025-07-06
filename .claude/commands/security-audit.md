# Security Audit

Perform comprehensive security analysis on the codebase or specific features.

## Usage

```
/security-audit [target]
```

## Process

### 1. Code Analysis
- Scan for hardcoded secrets and credentials
- Check for SQL injection vulnerabilities
- Review input validation and sanitization
- Identify potential XSS attack vectors
- Check authentication and authorization logic

### 2. Dependency Audit
- Review third-party dependencies for known vulnerabilities
- Check for outdated packages with security patches
- Validate dependency licenses

### 3. Configuration Review
- Verify secure defaults
- Check environment variable usage
- Review CORS and security headers
- Validate SSL/TLS configuration

### 4. OWASP Top 10 Check
- Injection flaws
- Broken authentication
- Sensitive data exposure
- XML external entities (XXE)
- Broken access control
- Security misconfiguration
- Cross-site scripting (XSS)
- Insecure deserialization
- Using components with known vulnerabilities
- Insufficient logging and monitoring

## Output Format

```markdown
## Security Audit Report - [Date]

### Critical Issues
- [ ] Issue description and location
- [ ] Recommended fix

### High Priority
- [ ] Issue description and location
- [ ] Recommended fix

### Medium Priority
- [ ] Issue description and location
- [ ] Recommended fix

### Recommendations
- Security best practices to implement
- Preventive measures for the future
```

## Example

```
User: /security-audit auth module

Claude: Performing security audit on authentication module...

## Security Audit Report - 2025-07-06

### Critical Issues
- [ ] Passwords stored in plain text at auth.py:45
  - Fix: Implement bcrypt hashing with salt
- [ ] No rate limiting on login endpoint
  - Fix: Add rate limiting with exponential backoff

### High Priority
- [ ] JWT tokens don't expire
  - Fix: Set 15-minute expiry with refresh tokens
- [ ] Missing CSRF protection
  - Fix: Implement CSRF tokens for state-changing operations

[continues...]
```