Run all project checks without making any commits.

**DO NOT** commit any code.
**DO NOT** change version numbers.
**DO NOT** push to remote.

## Steps:

1. Run the appropriate check command for the project:
   - `npm run check` (Node.js)
   - `cargo check` (Rust)
   - `go vet ./...` (Go)
   - `python -m pytest` (Python)
   - `mix test` (Elixir)

2. If errors are found:
   - Report each error clearly
   - Suggest fixes but don't apply automatically
   - Prioritize by severity

3. If all checks pass:
   - Confirm success
   - Note any warnings

This ensures code quality before manual review and commit.