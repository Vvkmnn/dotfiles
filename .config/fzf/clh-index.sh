#!/opt/homebrew/bin/bash
# clh-index.sh — index all Claude Code sessions, cached by mtime
# Output: TSV sorted by mtime desc (newest first)
# Format: uuid\tmtime\tcwd\tslug\tbranch\tfirst_prompt
set -euo pipefail

PROJECTS_DIR="$HOME/.claude/projects"
CACHE_FILE="$HOME/.cache/clh-sessions.tsv"

[ -d "$PROJECTS_DIR" ] || exit 0
mkdir -p "$HOME/.cache"

# Fast path: nothing newer than cache → output as-is
if [ -f "$CACHE_FILE" ]; then
  mapfile -t newer_files < <(find "$PROJECTS_DIR" -name "*.jsonl" -newer "$CACHE_FILE" -maxdepth 2 2>/dev/null)
  if [ ${#newer_files[@]} -eq 0 ]; then
    cut -f1-6 "$CACHE_FILE"
    exit 0
  fi
else
  # Cold cache: all files are "newer"
  mapfile -t newer_files < <(find "$PROJECTS_DIR" -maxdepth 2 -name "*.jsonl" -type f 2>/dev/null)
fi

# Parse metadata from a JSONL file
parse_session() {
  local f="$1"
  local mtime
  mtime=$(stat -f "%m" "$f" 2>/dev/null) || return

  local head_block
  head_block=$(head -50 "$f")

  local meta
  meta=$(printf '%s' "$head_block" | jq -rs '
    (map(select(.sessionId != null)) | first // {} | {sessionId, cwd, gitBranch}) +
    {slug: (map(select(.slug != null and .slug != "")) | first | .slug // "")} +
    {prompt: (map(select(.type == "user" and .message.content != null))
      | first
      | .message.content
      | if type == "array" then
          (map(select(.type == "text" and .text != null)) | first | .text // "")
        else . // "" end
      | .[:100]
    )}
    | [(.sessionId // "-"), (.slug // "-"), (.cwd // "-"), (if .gitBranch == "" or .gitBranch == null then "-" else .gitBranch end), (.prompt // "-")]
    | @tsv
  ' 2>/dev/null) || return

  local uuid slug cwd branch prompt
  IFS=$'\t' read -r uuid slug cwd branch prompt <<< "$meta"
  [ -z "$uuid" ] || [ "$uuid" = "-" ] && return

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$uuid" "$mtime" "$cwd" "$slug" "$branch" "$prompt" "$f"
}

tmpfile="$CACHE_FILE.tmp.$$"
trap 'rm -f "$tmpfile"' EXIT

# Build set of newer filepaths for fast lookup
declare -A newer_set
for f in "${newer_files[@]}"; do
  newer_set["$f"]=1
done

# Copy unchanged lines from existing cache
if [ -f "$CACHE_FILE" ]; then
  while IFS= read -r line; do
    local_path="${line##*$'\t'}"
    if [ -z "${newer_set["$local_path"]:-}" ]; then
      printf '%s\n' "$line"
    fi
  done < "$CACHE_FILE" >> "$tmpfile"
fi

# Parse only the newer/new files
for f in "${newer_files[@]}"; do
  parse_session "$f"
done >> "$tmpfile"

# Sort by mtime descending, deduplicate by UUID (keep newest), atomically replace
sort -t$'\t' -k2 -rn "$tmpfile" | awk -F'\t' '!seen[$1]++' > "$CACHE_FILE"
rm -f "$tmpfile"
trap - EXIT

cut -f1-6 "$CACHE_FILE"
