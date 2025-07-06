# Refactor

Intelligently refactor code to improve quality, maintainability, and performance.

## Usage

```
/refactor [target]
```

## Process

### 1. Code Analysis
- Identify code smells and duplication
- Find complex functions that need splitting
- Detect poor naming conventions
- Locate tightly coupled components

### 2. Refactoring Strategy
- Extract common patterns into utilities
- Simplify complex conditionals
- Improve variable and function names
- Apply SOLID principles
- Reduce cyclomatic complexity

### 3. Safety Measures
- Ensure tests exist before refactoring
- Make incremental changes
- Verify tests pass after each change
- Maintain backward compatibility

### 4. Optimization
- Remove dead code
- Optimize algorithms
- Reduce memory usage
- Improve time complexity

## Output Format

```markdown
## Refactoring Plan

### Overview
Brief description of refactoring goals

### Changes
1. **[Component/Function]**
   - Current issue: ...
   - Proposed change: ...
   - Benefits: ...

### Implementation Steps
- [ ] Step 1: Description
- [ ] Step 2: Description
- [ ] Step 3: Description

### Risk Assessment
- Potential breaking changes
- Migration requirements
```

## Example

```
User: /refactor user service

Claude: Analyzing user service for refactoring opportunities...

## Refactoring Plan

### Overview
Refactor UserService to improve maintainability and reduce complexity

### Changes
1. **getUserData() function (150 lines)**
   - Current issue: Does too many things - fetching, validation, transformation
   - Proposed change: Split into fetchUser(), validateUser(), transformUser()
   - Benefits: Single responsibility, easier testing, reusable components

2. **Duplicate error handling**
   - Current issue: Same try-catch pattern in 8 methods
   - Proposed change: Extract to @handleErrors decorator
   - Benefits: DRY principle, consistent error handling

[continues...]
```