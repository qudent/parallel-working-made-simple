# Parallel Working Made Simple

A Claude Code skill for managing hierarchical git worktrees, enabling parallel agent workflows.

Agents find it much easier to make comparisons across all branches without sequentially making git commits! Case in point:
```
>  can you compare the mock data structure from all extant branches (by find . in the worktrees)? which of them is the newest
   one?

⛬  I'll compare the mock data structure across all branches in the worktrees to find the newest one.


 EXECUTE  (find /Users/name/ChatGIT-wails.worktrees -name "mock-data.json" -o -name "types.ts" | head -20, impact: low)
 ↳ Exit code: 0. Output: 12 lines.

⛬  Now let me check the git status and timestamps for each mock-data.json file to determine which is newest:


 EXECUTE
(ls -la /Users/name/ChatGIT-wails.worktrees/frontend-designs/mock-data/mock-data.json
/Users/name/ChatGIT-wails.worktrees/backend-go-wails-svelte/mock-data/mock-data.json /Users/name/ChatGIT-wails.worktrees/frontend
-designs.worktrees/svelte-vite-factory-glm6-aisdkclone.worktrees/svelte-vite-codex-aisdkclone/mock-data/mock-data.json
/Users/name/ChatGIT-wails.worktrees/frontend-designs.worktrees/svelte-vite-factory-glm6-aisdkclone/mock-data/mock-data.json
/Users/name/ChatGIT-wails.worktrees/backend-go-wails-svelte.worktrees/backend-go-wails-svelte-claude/mock-data/mock-data.json,
allowlisted)
 ↳ Exit code: 0. Output: 6 lines.

⛬  The newest file is svelte-vite-codex-aisdkclone/mock-data/mock-data.json (Oct 15 22:40, 16045 bytes). Let me compare it
   with the others:
```

## Repository Structure

```
parallel-worktrees/      # The skill to copy to ~/.claude/skills/
├── SKILL.md             # Skill metadata and instructions
└── worktrees.sh         # Shell functions
```

## Installation

Copy the `parallel-worktrees` folder to your Claude Code skills directory:

```bash
# Personal (works across all projects)
cp -r parallel-worktrees ~/.claude/skills/

# Or project-level (for a specific repo)
cp -r parallel-worktrees /path/to/your/repo/.claude/skills/
```

## Usage

Once installed, Claude will automatically offer to use this skill when you mention worktrees. You can also invoke it manually with `/parallel-worktrees`.

### Commands

| Command | Purpose |
|---------|---------|
| `worktree_create <branch>` | Create worktree, cd into it, run pnpm install if needed |
| `worktree_merge_to_parent` | Merge current branch into parent's branch |
| `worktree_merge_from_parent` | Pull parent's changes into current worktree |
| `worktree_abort` | Delete worktree and branch, return to parent |
| `worktree_finish` | Merge to parent then abort |

### Typical Workflow

```bash
worktree_create feature-x    # Start isolated work
# ... work on feature ...
worktree_finish              # Merge up and clean up
```

## Key Concepts

- **Recursive structure**: Worktrees can nest (`repo.worktrees/a.worktrees/b`) for subtask hierarchies
- **Parent-child merges**: Directory hierarchy defines merge relationships
- **Assumption**: No directory ending in `.worktrees` exists in your repo except those managed by these functions
