# Parallel Working Made Simple

Super-simple Claude skill to manage parallel working in worktrees.

## What is this?

Spin up isolated git worktrees, run multiple Claude/Codex agents in parallel, merge the results. Five shell functions, zero complexity.

- [SKILL.md](parallel-worktrees/SKILL.md) - command reference
- [gitingest.com/qudent/parallel-working-made-simple](https://gitingest.com/qudent/parallel-working-made-simple) - paste into any AI to explain the code

## Example Workflows

### Fix two bugs in parallel

```bash
# Source the skill
source ~/.claude/skills/parallel-worktrees/worktrees.sh

# Create worktree for first bug (this cd's into it)
worktree_create fix-auth-bug
# macOS: osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"' && claude \"fix the authentication timeout bug\""'
# Linux: xterm -e "cd $(pwd) && claude 'fix the authentication timeout bug'" &

# Return to parent repo, create another worktree
worktree_cd_to_parent
worktree_create fix-button-styling
# macOS: osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"' && claude \"fix the submit button styling\""'
# Linux: xterm -e "cd $(pwd) && claude 'fix the submit button styling'" &

# When each agent finishes, in its terminal:
worktree_finish  # merges to parent and cleans up
```

### Race different approaches

```bash
source ~/.claude/skills/parallel-worktrees/worktrees.sh

# Try three different agents on the same problem
worktree_create approach-claude
# macOS: osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"' && claude \"implement the caching layer\""'
# Linux: xterm -e "cd $(pwd) && claude 'implement the caching layer'" &

worktree_cd_to_parent
worktree_create approach-codex
# macOS: osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"' && codex \"implement the caching layer\""'
# Linux: xterm -e "cd $(pwd) && codex 'implement the caching layer'" &

worktree_cd_to_parent
worktree_create approach-gemini
# macOS: osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"' && gemini \"implement the caching layer\""'
# Linux: xterm -e "cd $(pwd) && gemini 'implement the caching layer'" &

# Compare results across worktrees (from approach-gemini, siblings are at ../):
# diff -r ../approach-claude/src ../approach-codex/src

# Keep the best one:
cd ../approach-claude
worktree_finish  # now back in /repo

# Discard the others (use .worktrees paths from repo root):
cd *.worktrees/approach-codex && worktree_abort
cd *.worktrees/approach-gemini && worktree_abort
```

### Nested subtasks

```bash
source ~/.claude/skills/parallel-worktrees/worktrees.sh

# Main feature branch
worktree_create new-dashboard

# Spawn subtasks from within the feature branch
worktree_create dashboard-api      # creates new-dashboard.worktrees/dashboard-api
worktree_cd_to_parent              # back to new-dashboard
worktree_create dashboard-ui       # creates new-dashboard.worktrees/dashboard-ui

# Each subtask merges up to the feature branch
worktree_finish  # dashboard-ui -> new-dashboard

# Back in new-dashboard, finish dashboard-api too
cd ../new-dashboard.worktrees/dashboard-api
worktree_finish  # dashboard-api -> new-dashboard

# Feature branch merges up to main
worktree_finish  # new-dashboard -> main
```

## Installation

```bash
# Personal (all projects)
cp -r parallel-worktrees ~/.claude/skills/

# Or project-level
cp -r parallel-worktrees /path/to/your/repo/.claude/skills/
```

Then invoke with `/parallel-worktrees` or just mention "worktree" to Claude.
