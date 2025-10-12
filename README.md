# This adds a new worktree
NEWBRANCH="frontend-designs"
NEWWORKTREE="$(git rev-parse --show-toplevel).worktrees/$NEWBRANCH"; git worktree add $NEWWORKTREE; cd $NEWWORKTREE; pnpm install || echo "pnpm irrelevant"

# This merges the current state of the branch in the current worktree into the "parent worktree" and goes back to the working branch
BRANCHTOMERGE=$(git rev-parse --abbrev-ref HEAD); CURRENT_PATH=$(pwd); cd "${CURRENT_PATH%%.worktrees/*}"; git merge $BRANCHTOMERGE; cd $CURRENT_PATH

# this "aborts" the branch: deletes branch and worktree, and ends up in the "parent" worktree. git worktree remove --force and git branch -D to force delete even with unmerged commits
BRANCHTOMERGE=$(git rev-parse --abbrev-ref HEAD); CURRENT_PATH=$(pwd); cd "${CURRENT_PATH%%.worktrees/*}"; git worktree remove --force $CURRENT_PATH; git branch -D $BRANCHTOMERGE
