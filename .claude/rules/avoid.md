# Extract, Don't Explore

## Problem
Reading whole files wastes context. Broad searches waste tokens. The goal is surgical extraction.

## Rule
Retrieve just what you need from the part of the file you need. Never read or search everything.

### Core Principle

**Extract specific portions, don't explore broadly.**

Bad: Read entire file to find one function
Good: Grep for function name, read only those lines

Bad: Search entire codebase for a pattern
Good: Search specific directory, check count first, filter aggressively

### Before Any Read or Search

1. **Check count first** - Use Grep `output_mode="count"` before `"content"`
2. **Check file size** - `wc -l` or `ls -lh` before reading large files
3. **If count >50** - Your pattern is too broad, add filters
4. **If file >500 lines** - Use offset/limit, never read whole

### Never Read Whole

These directories - skip entirely:
- `node_modules/`, `dist/`, `build/`, `.next/`, `vendor/`, `.git/`, `coverage/`

These file types - skip or extract specific portions:
- `*.log`, `*.lock`, `*.min.js`, `*.map`, large `*.json`/`*.csv`

### Large Config Files

For files like `.claude.json`, `package.json`, large configs:
1. **Never read entire file**
2. Grep for the specific key/section you need
3. Read only that portion with offset/limit
4. One targeted extraction > reading everything

### Search Strategy

**Smallest, most specific first:**
1. Exact string: `"functionName"` not `function`
2. Specific file: `--glob "src/auth/*.ts"` not `**/*.ts`
3. Limited results: `head_limit=5`
4. Check count before content

**Expand only if zero results:**
- Broaden pattern slightly
- Remove one filter
- Try alternative naming

### Extraction Patterns

| Need | Do | Don't |
|------|-----|-------|
| One function | Grep name, read those lines | Read whole file |
| Config value | Grep key, read that section | Read entire config |
| Class definition | Grep `class Name`, read with limit | Read 1000+ line file |
| Multiple files | Grep files_with_matches first | Read all candidates |

### Red Flags - Stop Immediately

- About to read file >500 lines whole
- Search returns >50 matches unfiltered
- Reading same file twice in session
- Pattern matches too broadly
- No count check before content read

## Complements
- `explore.md` - Use Explore agent for truly open-ended questions
- `verify.md` - File:line references for efficiency
- `minimize.md` - Minimalism applies to file access too
