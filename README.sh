#!/bin/zsh
# Functions for parallel worktree operations
# This adds a new worktree for the given branch, cd's into it, and runs pnpm install if package.json is present
# pnpm install is better than npm because it uses the pnpm store and hard links to save space and time
add_worktree() {
  local NEWBRANCH="$1"
  local NEWWORKTREE="$(git rev-parse --show-toplevel).worktrees/$NEWBRANCH"
  git worktree add "$NEWWORKTREE"
  cd "$NEWWORKTREE"
  if [[ -f package.json ]]; then
    pnpm install || echo "pnpm failed"
}

# This merges the current state of the branch in the current worktree into the "parent worktree" and goes back to the working branch
merge_to_parent() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git merge --no-edit "$BRANCHTOMERGE"
  cd "$CURRENT_PATH"
}

# This merges the parent worktree's current branch into the current worktree, if the parent has updated
merge_from_parent() {
    local CURRENT_PATH="$(pwd)"
    cd "${CURRENT_PATH%%.worktrees/*}"
    local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
    cd "$CURRENT_PATH"
    git merge --no-edit $BRANCHTOMERGE
}

# this "aborts" the branch: deletes branch and worktree, and ends up in the "parent" worktree. git worktree remove --force and git branch -D to force delete even with unmerged commits
abort_branch() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git worktree remove --force "$CURRENT_PATH"
  git branch -D "$BRANCHTOMERGE"
}
