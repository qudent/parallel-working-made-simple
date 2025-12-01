See `README.sh` for the code itself (which is self-explaining or can be very easily explained by any AI). The point is to create a scaffold that makes it very simple to use parallel worktrees to work on features in parallel, or to try different agents/prompts implement the same features. If you do this, you learn more quickly what works and what doesn't.

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
