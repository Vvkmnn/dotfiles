# Write Beautiful Code

## Problem
Imperative, mutation-heavy code is hard to reason about. Clever code impresses the author but punishes every future reader. AI-generated code specifically tends to over-engineer, skip edge cases, and look correct while being subtly wrong.

## Rule
Write the best possible code. Research best-in-class approaches before implementing. Optimize for the next reader, not the current author. Break any rule when the language, domain, or performance demands it.

### Research First

Before writing non-trivial code, research the best approach:
- **Data structures:** Choose based on access patterns, not familiarity. HashMap for lookups, not linear search. Set for membership tests, not array `.includes()`. The wrong data structure makes correct code slow.
- **Algorithms:** Know the problem class. Is it a search, sort, graph traversal, dynamic programming? The naive approach is often O(n^2) when O(n log n) or O(n) exists.
- **Patterns:** Check if the problem has a well-known solution. Don't reinvent what the standard library provides. Check Context7 docs before writing library-specific code.
- **Libraries:** Never assume a library is available — even a famous one. Check the manifest/lockfile (package.json, pyproject.toml, Cargo.toml) before importing; match the installed major version's API.
- **Existing code:** Grep the codebase for similar patterns before writing new ones. Reuse > reinvent.
- For unfamiliar territory, use the research protocol in `orchestrate.md` (3 parallel subagents: local/docs/online).

### Core Principles

**Pure functions by default:**
- Same input, same output, no side effects
- Push I/O, mutation, and logging to the edges (functional core, imperative shell)
- Why: understand each function in isolation, test without setup

**Immutability by default, mutation opt-in:**
- Create new objects: `{ ...obj, key: newVal }` not `obj.key = newVal`
- `const` / `val` / `final` everywhere — `let` is a code smell
- When mutation is necessary (performance, API constraints), make it obvious and contained
- Why: eliminates aliasing bugs and hidden state dependencies

**Composition over inheritance:**
- Combine small functions, don't grow large objects
- Functions take data, return data — avoid classes that hide state
- One abstraction level per function: orchestrators call, implementors implement — never both
- Why: composed functions are independently testable and replaceable

**Declarative over imperative:**
- Express WHAT, not HOW: `users.filter(isActive).map(toName)` over loops with accumulators
- When a pipeline exceeds 4-5 steps, break into named intermediate values
- Why: declarative code reads as a description of intent

**Guard clauses and early returns:**
- Invert conditions to exit early — don't nest the happy path
- Merge related guards (e.g., both auth checks into one)
- Extract complex conditions into named predicates: `if (isEligible(user))` not `if (user.age > 18 && user.verified)`
- Why: each guard eliminates one condition from the reader's mental stack

**Cognitive load budget:**
- Every function has a reader's mental stack budget — spend it deliberately
- Complexity signals: >3 parameters, >2 levels of nesting, >1 abstraction level per function
- The test: can a reader understand this unit in isolation in <30 seconds?
- Prefer deep modules: small interface, substantial implementation (Ousterhout) — an interface as complex as its implementation adds surface without hiding anything
- Why: correctness is necessary but not sufficient; maintainability requires shallow stacks

**No flag parameters:**
- A boolean arg that changes behavior = two functions — split them
- `renderUser(user)` and `renderAdmin(user)` not `renderUser(user, isAdmin)`
- Why: callers and readers understand one mode, not two

**Expressions over statements:**
- Prefer things that evaluate to a value
- Early returns over if/else assignment chains
- Ternaries for simple conditionals, guard clauses for complex ones
- Why: expressions compose; statements don't

**Explicit error handling:**
- Never silently swallow errors — fail loudly at point of failure
- Separate error handling from business logic
- Command-Query Separation: queries return values (no side effects), commands cause effects (no return)
- Why: hidden failures compound into debugging nightmares

**Total functions — handle all inputs:**
- Every function should have defined behavior for all possible inputs, not just expected ones
- No silent `null`/`None`/`undefined` returns for edge cases — return typed optionals or raise explicitly
- Pattern match exhaustively — if adding a new enum variant silently breaks behavior, the match is non-total
- Why: partial functions are the primary source of "works in testing, fails in production"

**Types as documentation:**
- Use types to make impossible states unrepresentable (discriminated unions, branded types, enums)
- Typed interfaces over loose dicts: `User` not `Dict[str, Any]`, `Config` not `Record<string, unknown>`
- Type signatures are machine-checked documentation that never goes stale
- Why: readers understand the contract without reading the implementation

**Data-oriented design:**
- Choose data structures based on access patterns: HashMap for O(1) lookups, Set for membership, sorted array for binary search
- Prefer flat data over deeply nested structures
- Separate data from behavior — plain structs/records + functions beat class hierarchies
- Why: the right data structure makes the algorithm obvious; the wrong one makes every operation a fight

### Documentation Policy

Converged practice across frontier coding tools (Cursor/Devin/Windsurf system prompts) + Google eng-practices:

- **Default is zero comments.** Add one only for: non-obvious complexity, a decision/trade-off (why this approach), or a footgun (race, timing, quirk)
- **WHY, never WHAT.** A comment restating the next line is noise; self-documenting names carry the WHAT
- **Verify every comment you write** — LLM-generated comments are wrong ~20% of the time (arXiv 2406.14836); a wrong comment is worse than none
- **LSP docstrings are the contract, not the HOW**: purpose, params, return, raises — never implementation narration
- **No unprompted doc files.** Never create README/DESIGN/NOTES files unless asked

### Completion Discipline

- Code isn't done until verified with a fresh run (full protocol: `verify.md`)
- **Never modify a test to make it pass** — fix the code; if the test itself is wrong, say so explicitly and get agreement (`test.md`)

### Anti-Patterns

| Don't | Do |
|-------|-----|
| Mutate input parameters | Return new objects |
| Boolean flag parameters | Separate functions |
| Loops with accumulator mutation | map/filter/reduce pipelines |
| Class with hidden state | Pure functions over plain data |
| Comments explaining WHAT | Self-documenting names |
| `let` / `var` everywhere | `const` / `val` / `final` default |
| Swallowing errors silently | Fail loudly at point of failure |
| Generic names (`data`, `tmp`, `val`) | Intent-revealing names scaled to scope |
| Deep nesting (>3 levels) | Guard clauses + extraction |
| One function doing N things | Extract until each unit is obvious |
| `Dict[str, Any]` / untyped maps | Typed interfaces, dataclasses, structs |
| Linear search through array | HashMap/Set for lookups and membership |
| Reinventing existing patterns | Grep codebase + check stdlib first |
| Magic strings/numbers inline | Named constants or enums |
| Returning null/None for errors or missing | Typed Option/Result or raise explicitly |
| >3 function parameters | Parameter object or builder |
| Stringly-typed APIs (`"admin"`, `"read"`) | Enums or tagged types |
| Writing code without researching | Research best-in-class approach first |

### Language Idioms

Apply functional principles through each language's idioms, not against them:

**Python:** Comprehensions over `map`+lambda. `@dataclass(frozen=True)` for value objects. Generator pipelines for large data. `functools` for memoization/partial application. Exception handling is idiomatic — don't fight it with `Result` types.

**TypeScript:** `as const`, `readonly`, `Readonly<T>` at boundaries. Array method chains (`.filter().map().sort()`). Spread for immutable updates. ES2023 `.toSorted()` / `.toReversed()` over mutating methods. Plain TS + readonly gets 80% of fp-ts benefit at 10% learning curve.

**Go:** Value receivers for non-mutating methods. Functional options pattern for constructors. Table-driven tests. Small interfaces + composition. `if err != nil` is idiomatic — don't force monadic error handling. `for` loops are fine.

**Bash:** `set -euo pipefail` always. Pipes ARE functional composition. `local` for all function variables. `readonly` for constants. ShellCheck on everything. >50 lines of complex logic → rewrite in Python.

**Rust:** Ownership IS immutability enforcement. Iterator chains (`.filter().map().collect()`). Pattern matching for declarative control flow. `?` operator for error propagation. Explicit `for` loops when body is complex — they compile to the same assembly.

**C:** `const` on every non-mutated parameter. `static` for all internal functions. Cleanup goto for multi-resource teardown. Opaque types (forward-declare in header, define in `.c`) for encapsulation. Functions <=25 lines. No typedef structs — `struct foo *` is clearer. 3 levels of nesting max.

**C++:** RAII for all resources — no raw `new`/`delete`. Rule of Zero (if members are RAII types, don't write special members). `unique_ptr` default, `shared_ptr` only for genuinely shared ownership. `string_view`/`span` for non-owning references. Algorithms and ranges over raw loops (Sean Parent). `const`/`constexpr` by default. Structured bindings, `optional`, `variant`, `expected` (C++23) over sentinel values. Concepts for readable generics.

**Swift:** Struct-first (value types by default, class only for shared mutable state). Protocol-oriented composition over class hierarchies. `guard let` for early exit — keep happy path at column 0. Enum + associated values for discriminated unions — make illegal states unrepresentable. Structured concurrency (`async/await`, `TaskGroup`, `actor`) — never raw GCD in new code. Mark types `Sendable` for concurrency safety. Swift API Design Guidelines for naming.

### When to Break These Rules

Rules describe trade-offs, not absolutes. Break them when you can articulate why:

**Use mutation when:**
- Profiler shows this is a performance hotspot
- In-place buffer processing (parsers, audio, image, physics)
- State machines with frequent transitions
- The language has no practical immutability support (Go structs)

**Use loops over pipelines when:**
- Early exit needed with accumulated state
- Multiple values computed in one pass (min + max + sum)
- Complex conditional logic that's clearer as if/else in a loop
- Debugging: step-debuggers trace loops better than dense chains

**Use classes when:**
- Stateful long-lived services (connection pools, caches, rate limiters)
- DI frameworks require class instantiation (NestJS, Spring, Angular)
- Game entities, protocol state machines, complex UI components
- The codebase already uses classes consistently — match existing style

**Don't over-decompose when:**
- Hot path called millions of times (call overhead, cache misses)
- A sequential procedure reads naturally as one unit
- Decomposition would scatter related logic across files with no reuse benefit

**Always profile before breaking rules for performance:**
- "This might be slow" is not justification — profiler output is
- Document the measurement: `// ~3x speedup over immutable version (benchmarked 2026-03)`

**Match existing codebase style over ideal style:**
- Consistent "wrong" style > inconsistent mix of "right" and "wrong"
- Don't refactor surrounding code when making a targeted fix
- Apply new style to new code; don't rewrite old code uninvited

## Complements
- `minimize.md` — Size limits, file focus, iteration strategy, no scope creep
- `orchestrate.md` — Research protocol (3 parallel subagents) for unfamiliar territory
- `verify.md` — Evidence-based claims, run tests before claiming done
- `test.md` — Testing gates, security checks, edge case coverage

<!-- Sources (2026-07-05 research pass): elder-plinius/CL4R1T4S (CURSOR/DEVIN/WINDSURF system prompts — converged coding directives),
     google/eng-practices (reviewer standard: code health over perfection, small CLs, Nit: convention),
     ciembor/agent-rules-books (SE-book distillations; deep modules per Ousterhout, A Philosophy of Software Design),
     arXiv 2406.14836 (LLM comment accuracy ~80%) -->

