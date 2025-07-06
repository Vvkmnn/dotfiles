# Test-Driven Development

Follow strict TDD methodology to ensure code quality and prevent regressions.

## Usage

```
/tdd [feature description]
```

## Process

### 1. Requirements Analysis
- Understand the feature requirements
- Identify edge cases and error scenarios
- Define clear success criteria
- Plan test structure

### 2. Red Phase - Write Failing Tests
- Write comprehensive test suite FIRST
- Include happy path and edge cases
- Verify tests fail (no implementation yet)
- Use descriptive test names

### 3. Green Phase - Minimal Implementation
- Write ONLY enough code to pass tests
- No premature optimization
- Follow existing code patterns
- Focus on making tests green

### 4. Refactor Phase
- Improve code quality
- Extract common patterns
- Enhance readability
- Ensure tests remain green

### 5. Iterate
- Add more tests for new requirements
- Repeat red-green-refactor cycle
- Build feature incrementally

## Output Format

```markdown
## TDD Implementation: [Feature]

### Test Plan
- [ ] Test 1: Description
- [ ] Test 2: Description
- [ ] Test 3: Edge case

### Red Phase
```language
# Failing tests code
```

### Green Phase
```language
# Minimal implementation
```

### Refactor Phase
```language
# Improved implementation
```

### Coverage Report
- Lines: X%
- Branches: X%
- Functions: X%
```

## Example

```
User: /tdd user authentication

Claude: Starting TDD cycle for user authentication...

## TDD Implementation: User Authentication

### Test Plan
- [ ] Test successful login with valid credentials
- [ ] Test login failure with invalid password
- [ ] Test login failure with non-existent user
- [ ] Test rate limiting after 5 failed attempts

### Red Phase
```python
def test_successful_login():
    user = User(email="test@example.com", password="hashed_pass")
    result = authenticate(email="test@example.com", password="correct_pass")
    assert result.success == True
    assert result.user.email == "test@example.com"

def test_invalid_password():
    user = User(email="test@example.com", password="hashed_pass")
    result = authenticate(email="test@example.com", password="wrong_pass")
    assert result.success == False
    assert result.error == "Invalid credentials"
```
[continues...]
```

## Best Practices

- TDD is most effective against AI hallucination
- One test at a time
- Test behavior, not implementation
- Keep tests fast and isolated
- Mock external dependencies