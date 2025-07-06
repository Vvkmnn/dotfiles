Create git worktrees for parallel development on multiple branches.

## Create Worktrees for All Open PRs

```bash
# Ensure GitHub CLI is authenticated
gh auth status || (echo "Please run 'gh auth login' first" && exit 1)

# Create tree directory
mkdir -p ./tree

# Create worktree for each open PR
gh pr list --json headRefName --jq '.[].headRefName' | while read branch; do
  branch_path="./tree/${branch}"
  
  # Handle branch names with slashes
  if [[ "$branch" == */* ]]; then
    mkdir -p "$(dirname "$branch_path")"
  fi

  # Create worktree if it doesn't exist
  if [ ! -d "$branch_path" ]; then
    echo "Creating worktree for $branch"
    git worktree add "$branch_path" "$branch"
  else
    echo "Worktree for $branch already exists"
  fi
done

# Show all worktrees
echo -e "\nActive worktrees:"
git worktree list
```

## Benefits
- Work on multiple features simultaneously
- Switch contexts instantly
- No stashing required
- Isolated environments per branch

## Cleanup
```bash
# Remove specific worktree
git worktree remove tree/branch-name

# Remove all worktrees
git worktree list | grep -v "bare" | awk '{print $1}' | xargs -I {} git worktree remove {}
```