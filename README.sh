#!/bin/zsh
# Functions for parallel worktree operations

# add_worktree <branch_folder_name> adds a new worktree  the given branch, cd's into it, and runs pnpm install if package.json is present
# pnpm install is better than npm because it uses the pnpm store and hard links to save space and time
add_worktree() {
  local NEWBRANCH="$1"
  local NEWWORKTREE="$(git rev-parse --show-toplevel).worktrees/$NEWBRANCH"
  git worktree add "$NEWWORKTREE"
  cd "$NEWWORKTREE"
  if [[ -f package.json ]]; then
    pnpm install || echo "pnpm failed"
}

# merge_to_parent merges the current state of the branch in the current worktree into the "parent worktree" and goes back to the working branch
merge_to_parent() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git merge --no-edit "$BRANCHTOMERGE"
  cd "$CURRENT_PATH"
}

# merge_from_parent merges the parent worktree's current branch into the current worktree, if the parent has updated
merge_from_parent() {
    local CURRENT_PATH="$(pwd)"
    cd "${CURRENT_PATH%%.worktrees/*}"
    local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
    cd "$CURRENT_PATH"
    git merge --no-edit $BRANCHTOMERGE
}

# abort_branch "aborts" the branch: deletes branch and worktree, and ends up in the "parent" worktree.
# Ignores uncommitted changes and unmerged commits!
abort_branch() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git worktree remove --force "$CURRENT_PATH"
  git branch -D "$BRANCHTOMERGE"
}

# finish_branch is a simple wrapper to merge to parent and then abort branch
finish_branch() {
  merge_to_parent
  abort_branch
}
