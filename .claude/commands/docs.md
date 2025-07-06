# Docs

Generate or update project documentation intelligently based on the codebase.

## Usage

```
/docs [target]
```

## Process

### 1. Analyze Existing Docs
   - Check for README.md, docs/, wiki/
   - Identify documentation gaps
   - Note outdated sections

### 2. Document Structure
```markdown
   # Project Name
   
   ## Overview
   Brief description of what the project does
   
   ## Installation
   Step-by-step setup instructions
   
   ## Usage
   Basic usage examples
   
   ## API Reference
   Key functions/classes with examples
   
   ## Configuration
   Available options and settings
   
   ## Contributing
   How to contribute to the project
   ```

### 3. Code Documentation
   - Extract docstrings/comments
   - Generate API documentation
   - Include usage examples
   - Document edge cases

### 4. Keep It Current
   - Update when APIs change
   - Reflect new features
   - Remove deprecated content
   - Maintain accuracy

## Output Format

```markdown
## Documentation Report

### Current State
- Existing docs: ...
- Coverage: X%
- Last updated: ...

### Updates Made
- [ ] Updated README.md
- [ ] Created API reference
- [ ] Added examples
- [ ] Fixed outdated sections

### Documentation Structure
- README.md - Overview
- API.md - Reference
- ARCHITECTURE.md - Design
- CONTRIBUTING.md - Guidelines
```

## Example

```
User: /docs api endpoints

Claude: Analyzing API documentation...

## Documentation Report

### Current State
- Existing docs: README.md (outdated)
- Coverage: 30%
- Last updated: 3 months ago

### Updates Made
- [x] Created comprehensive API.md
- [x] Added request/response examples
- [x] Documented error codes
- [x] Added authentication guide

### Sample Update
```markdown
# API Reference

## Authentication
All requests require Bearer token:
```
Authorization: Bearer <token>
```

## Endpoints

### GET /users
Retrieve user list

**Response:**
```json
{
  "users": [...],
  "total": 100
}
```
[continues...]
```

## Best Practices

- Clear, simple language
- Include code examples
- Keep concise but complete
- Update with code changes
- Skip implementation details