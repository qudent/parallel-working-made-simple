# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository provides a Claude Code skill for managing git worktrees in a hierarchical, recursive structure. It enables parallel development workflows where multiple agents/tasks can work simultaneously in isolated worktrees.

## Repository Structure

```
parallel-worktrees/      # The skill (copy to ~/.claude/skills/)
├── SKILL.md             # Skill metadata and instructions
└── worktrees.sh         # Shell functions
```

## Key Concepts

- **Recursive worktree structure**: Worktrees are created at `<repo_path>.worktrees/<branch_name>`, and can be nested for subtask/subagent hierarchies
- **Parent-child relationships**: The path hierarchy (`*.worktrees/*`) defines parent-child relationships between worktrees
- **Assumption**: No directory ending in `.worktrees` exists in the repo except those managed by these functions

## Shell Functions (worktrees.sh)

| Function | Purpose |
|----------|---------|
| `worktree_create <branch>` | Create worktree at `<toplevel>.worktrees/<branch>`, cd into it, run `pnpm install` if package.json exists |
| `worktree_cd_to_parent` | Navigate to parent worktree (sets `$CHILD_PATH` as side effect) |
| `worktree_merge_to_parent` | Merge current branch into parent worktree's branch |
| `worktree_merge_from_parent` | Merge parent's branch into current worktree |
| `worktree_abort` | Delete worktree and branch, cd to parent (discards uncommitted changes) |
| `worktree_finish` | Merge to parent then abort (combines both operations) |
