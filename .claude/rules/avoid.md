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

**High-volume directories** (avoid broad searches, extract specific files only):
- **Dependencies**: `node_modules/`, `venv/`, `.venv/`, `env/`, `__pycache__/`, `vendor/`, `packages/`
- **Build artifacts**: `dist/`, `build/`, `out/`, `target/`, `.next/`, `.nuxt/`
- **Infrastructure**: `.terraform/`, `.serverless/`, `cdk.out/`
- **IDE/tooling**: `.idea/`, `.vscode/`, `.vs/`, `.fleet/`
- **Git internals**: `.git/objects/`, `.git/index`
- **Logs/data**: `logs/`, `data/`, `datasets/`
- **Coverage/cache**: `coverage/`, `.nyc_output/`, `htmlcov/`, `.pytest_cache/`

**File types** (extract specific lines/sections, never read whole):
- **Logs**: `*.log` (grep for error, read those lines only)
- **Compiled**: `*.pyc`, `*.class`, `*.o`, `*.so`, `*.dll` (usually no value)
- **Package locks**: `*-lock.json`, `*.lock`, `.terraform.lock.hcl` (grep for package name if needed)
- **Minified**: `*.min.js`, `*.map` (readable source exists elsewhere)
- **Large data**: `*.csv`, `*.parquet`, `*.db`, `*.sqlite` (sample with head/tail)
- **Sensitive**: `*.env*`, `*.pem`, `*.key` (security risk, usually irrelevant to task)

### Forbidden Search Paths

**Never search these paths without strict file filters:**
- `/Users/*` or `~` (home directory)
- `/` (root)
- Any path containing: `node_modules`, `.git`, `Library`, `Applications`

**For shell init files, use known paths directly:**
```bash
# Good - direct file access
cat ~/.zshrc ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null

# Bad - directory search
Grep(pattern, path="/Users/v", glob=".z*")  # Traverses entire home!
```

**Common user config locations:**
| Config | Path | Never Search |
|--------|------|--------------|
| Shell init | `~/.zshrc`, `~/.bashrc` | `~/` or `/Users/` |
| Git | `~/.gitconfig` | home directory |
| SSH | `~/.ssh/config` | home directory |
| Claude | `~/.claude/` | parent directories |

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

### Zero-Result Verification

Glob/Grep have documented reliability issues. Zero results may mean tool failure, not pattern mismatch.

**Verify before broadening:**
```bash
# Glob alternative
find /path -name "*.ext" -type f 2>/dev/null | head -5

# Grep alternative
grep -r "pattern" /path --include="*.ext" 2>/dev/null | head -5
```

**Decision:**
1. Glob/Grep returns 0 → Run bash fallback
2. Bash finds matches → Use bash (tool failed)
3. Bash finds nothing → Broaden pattern (search was too narrow)

| Tool Call | Bash Equivalent |
|-----------|-----------------|
| `Glob("**/*.ts")` | `find . -name "*.ts" -type f` |
| `Grep(pattern, glob="*.ts")` | `grep -r "pattern" --include="*.ts"` |
| `Grep(pattern, path="src/")` | `grep -r "pattern" src/` |

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
- Trusting zero results without bash verification

## Complements
- `explore.md` - Use Explore agent for truly open-ended questions
- `verify.md` - File:line references for efficiency
- `minimize.md` - Minimalism applies to file access too
