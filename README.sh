#!/bin/zsh
# Functions for parallel worktree operations

# worktree_create <new_branch_name> creates a new worktree with the given branch, cd's into it, and runs pnpm install if package.json is present
# the new worktree is at the <current_path>.worktrees/<branch_name> path. This permits a recursive structure of worktrees,
# which correspond to tasks/agents and subagents. merge_to_parent and merge_from parent are made to keep these in sync,
# if you  want to merge from the main branch directly, just use git merge main as usual.

# We try to set up the env as much as possible, so if package.json is present, we run pnpm install.
# pnpm install is better than npm because it uses the pnpm store and hard links to save space and time

# the commands cds into the new worktree and we can start vibing immediately: `worktree_create <branch_name>; claude`` # or `code .`` for vscode, droid, codex, gemini...
# For `code .` on Mac, you might need to install the 'code' command in PATH from the Command Palette: Shift + Command + P, type 'shell command' to find the option.
worktree_create() {
  local NEWBRANCH="$1"
  local NEWWORKTREE="$(git rev-parse --show-toplevel).worktrees/$NEWBRANCH"
  git worktree add "$NEWWORKTREE"
  cd "$NEWWORKTREE"
  if [[ -f package.json ]]; then
    pnpm install || echo "pnpm failed"
  fi
}

# worktree_merge_to_parent merges the current state of the branch in the current worktree into the "parent worktree" and goes back to the working branch
worktree_merge_to_parent() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git merge --no-edit "$BRANCHTOMERGE"
  cd "$CURRENT_PATH"
}

# worktree_merge_from_parent merges the parent worktree's current branch into the current worktree, if the parent has updated
worktree_merge_from_parent() {
    local CURRENT_PATH="$(pwd)"
    cd "${CURRENT_PATH%%.worktrees/*}"
    local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
    cd "$CURRENT_PATH"
    git merge --no-edit $BRANCHTOMERGE
}

# worktree_abort_branch "aborts" the branch: deletes branch and worktree, and ends up in the "parent" worktree.
# Ignores uncommitted changes and unmerged commits!
worktree_abort_branch() {
  local BRANCHTOMERGE="$(git rev-parse --abbrev-ref HEAD)"
  local CURRENT_PATH="$(pwd)"
  cd "${CURRENT_PATH%%.worktrees/*}"
  git worktree remove --force "$CURRENT_PATH"
  git branch -D "$BRANCHTOMERGE"
}

# worktree_finish_branch is a simple wrapper to merge to parent and then abort branch
# still, uncommitted changes will be lost!
worktree_finish_branch() {
  worktree_merge_to_parent
  worktree_abort_branch
}
