# Prime

Load essential project context quickly by reading key files and understanding structure.

## Usage

```
/prime [target]
```

## Process

### 1. Read Core Documentation
   - README.md for project overview
   - CONTRIBUTING.md for development guidelines
   - Any .claude/CLAUDE.md for AI-specific instructions

### 2. Explore Project Structure
   - Identify main directories
   - Locate source code, tests, configs
   - Note any unusual patterns

### 3. Understand Tech Stack
   - Package files (package.json, requirements.txt, etc.)
   - Config files (tsconfig.json, .eslintrc, etc.)
   - Build tools and scripts

### 4. Identify Key Patterns
   - Code organization
   - Naming conventions
   - Testing approach

## Output Format

```markdown
## Project Context Summary

### Overview
Brief project description

### Tech Stack
- Languages: ...
- Frameworks: ...
- Tools: ...

### Structure
- src/: Main source code
- tests/: Test files
- ...

### Commands
- Run: `npm start`
- Test: `npm test`
- Build: `npm build`

### Key Patterns
- Architecture style
- Testing approach
- Code conventions
```

## Example

```
User: /prime

Claude: Loading project context...

## Project Context Summary

### Overview
E-commerce platform built with React and Node.js

### Tech Stack
- Languages: TypeScript, JavaScript
- Frameworks: React, Express, Tailwind
- Tools: Webpack, Jest, Docker

### Structure
- client/: React frontend
- server/: Express API
- shared/: Common types and utils
- tests/: Integration and unit tests

[continues...]
```

## Best Practices

- Skip node_modules, .git, dist
- Focus on source code structure
- Note unusual patterns
- Identify testing approach