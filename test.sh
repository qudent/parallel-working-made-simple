#!/bin/bash
# End-to-end tests for parallel-worktrees skill
# Creates temp repos, tests all workflows, verifies correctness, cleans up

# Don't use set -e so we can see all failures
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR=$(mktemp -d)
PASS_COUNT=0
FAIL_COUNT=0

echo "=== Parallel Worktrees Test Suite ==="
echo "Test directory: $TEST_DIR"
echo ""

# Source the functions
source "$SCRIPT_DIR/parallel-worktrees/worktrees.sh"

# Helper functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS_COUNT++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL_COUNT++))
}

assert_dir_exists() {
    if [[ -d "$1" ]]; then
        pass "$2"
    else
        fail "$2 (directory '$1' not found)"
    fi
}

assert_dir_not_exists() {
    if [[ ! -d "$1" ]]; then
        pass "$2"
    else
        fail "$2 (directory '$1' still exists)"
    fi
}

assert_file_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        pass "$3"
    else
        fail "$3 (file '$1' doesn't contain '$2')"
    fi
}

assert_branch_exists() {
    if git branch --list "$1" | grep -q "$1"; then
        pass "$2"
    else
        fail "$2 (branch '$1' not found)"
    fi
}

assert_branch_not_exists() {
    if ! git branch --list "$1" | grep -q "$1"; then
        pass "$2"
    else
        fail "$2 (branch '$1' still exists)"
    fi
}

assert_pwd_ends_with() {
    if [[ "$PWD" == *"$1" ]]; then
        pass "$2"
    else
        fail "$2 (pwd is '$PWD', expected to end with '$1')"
    fi
}

cleanup() {
    echo ""
    echo "=== Cleanup ==="
    cd /
    rm -rf "$TEST_DIR"
    echo "Removed $TEST_DIR"
}
trap cleanup EXIT

# =============================================================================
# Test 1: Basic worktree_create
# =============================================================================
echo "--- Test 1: worktree_create ---"

cd "$TEST_DIR"
mkdir test-repo && cd test-repo
git init
git config user.email "test@test.com"
git config user.name "Test User"
echo "initial content" > file.txt
git add file.txt
git commit -m "initial commit"

worktree_create feature-a

assert_dir_exists "$TEST_DIR/test-repo.worktrees/feature-a" "Worktree directory created"
assert_pwd_ends_with "feature-a" "cd'd into worktree"
assert_branch_exists "feature-a" "Branch created"

# =============================================================================
# Test 2: worktree_cd_to_parent
# =============================================================================
echo ""
echo "--- Test 2: worktree_cd_to_parent ---"

worktree_cd_to_parent

assert_pwd_ends_with "test-repo" "cd'd back to parent"
if [[ "$CHILD_PATH" == *"feature-a" ]]; then
    pass "CHILD_PATH set correctly"
else
    fail "CHILD_PATH not set (got '$CHILD_PATH')"
fi

# =============================================================================
# Test 3: worktree_merge_to_parent
# =============================================================================
echo ""
echo "--- Test 3: worktree_merge_to_parent ---"

cd "$TEST_DIR/test-repo.worktrees/feature-a"
echo "feature-a change" > feature-a.txt
git add feature-a.txt
git commit -m "add feature-a"

worktree_merge_to_parent

# Verify we're still in child
assert_pwd_ends_with "feature-a" "Still in child worktree after merge"

# Check parent has the change
cd "$TEST_DIR/test-repo"
assert_file_contains "$TEST_DIR/test-repo/feature-a.txt" "feature-a change" "Parent has merged changes"

# =============================================================================
# Test 4: worktree_merge_from_parent
# =============================================================================
echo ""
echo "--- Test 4: worktree_merge_from_parent ---"

# Make a change in parent
cd "$TEST_DIR/test-repo"
echo "parent update" > parent-update.txt
git add parent-update.txt
git commit -m "parent update"

# Merge into child
cd "$TEST_DIR/test-repo.worktrees/feature-a"
worktree_merge_from_parent

assert_file_contains "$TEST_DIR/test-repo.worktrees/feature-a/parent-update.txt" "parent update" "Child received parent changes"

# =============================================================================
# Test 5: worktree_abort
# =============================================================================
echo ""
echo "--- Test 5: worktree_abort ---"

cd "$TEST_DIR/test-repo"
worktree_create feature-to-abort

echo "this will be lost" > doomed.txt
git add doomed.txt
git commit -m "doomed commit"

worktree_abort

assert_pwd_ends_with "test-repo" "cd'd back to parent after abort"
assert_dir_not_exists "$TEST_DIR/test-repo.worktrees/feature-to-abort" "Worktree removed"
assert_branch_not_exists "feature-to-abort" "Branch deleted"

# =============================================================================
# Test 6: worktree_finish
# =============================================================================
echo ""
echo "--- Test 6: worktree_finish ---"

cd "$TEST_DIR/test-repo"
worktree_create feature-to-finish

echo "keeper content" > keeper.txt
git add keeper.txt
git commit -m "keeper commit"

worktree_finish

assert_pwd_ends_with "test-repo" "cd'd back to parent after finish"
assert_dir_not_exists "$TEST_DIR/test-repo.worktrees/feature-to-finish" "Worktree removed after finish"
assert_branch_not_exists "feature-to-finish" "Branch deleted after finish"
assert_file_contains "$TEST_DIR/test-repo/keeper.txt" "keeper content" "Changes merged before cleanup"

# =============================================================================
# Test 7: Nested worktrees (recursive structure)
# =============================================================================
echo ""
echo "--- Test 7: Nested worktrees ---"

cd "$TEST_DIR/test-repo"
worktree_create parent-feature

assert_pwd_ends_with "parent-feature" "In parent-feature worktree"

worktree_create nested-child

assert_dir_exists "$TEST_DIR/test-repo.worktrees/parent-feature.worktrees/nested-child" "Nested worktree created"
assert_pwd_ends_with "nested-child" "cd'd into nested worktree"

# Make change in nested child
echo "nested change" > nested.txt
git add nested.txt
git commit -m "nested commit"

# Finish nested -> should merge to parent-feature
worktree_finish

assert_pwd_ends_with "parent-feature" "Back in parent-feature after nested finish"
assert_file_contains "$TEST_DIR/test-repo.worktrees/parent-feature/nested.txt" "nested change" "Nested changes merged to parent-feature"

# Finish parent-feature -> should merge to main repo
worktree_finish

assert_pwd_ends_with "test-repo" "Back in main repo"
assert_file_contains "$TEST_DIR/test-repo/nested.txt" "nested change" "Nested changes propagated to main repo"

# =============================================================================
# Test 8: pnpm install trigger (mock test)
# =============================================================================
echo ""
echo "--- Test 8: package.json detection ---"

cd "$TEST_DIR"
mkdir npm-repo && cd npm-repo
git init
git config user.email "test@test.com"
git config user.name "Test User"
echo '{"name": "test", "version": "1.0.0"}' > package.json
git add package.json
git commit -m "initial with package.json"

# Shim pnpm so we can detect whether worktree_create invokes it
PNPM_LOG="$TEST_DIR/pnpm-install.log"
FAKE_PNPM_DIR="$TEST_DIR/fake-pnpm"
mkdir -p "$FAKE_PNPM_DIR"
: > "$PNPM_LOG"

cat <<EOF > "$FAKE_PNPM_DIR/pnpm"
#!/bin/bash
echo "\$@" >> "$PNPM_LOG"
exit 0
EOF
chmod +x "$FAKE_PNPM_DIR/pnpm"

ORIGINAL_PATH="$PATH"
PATH="$FAKE_PNPM_DIR:$PATH"

worktree_create pnpm-check

PATH="$ORIGINAL_PATH"

assert_file_contains "$PNPM_LOG" "install" "pnpm install triggered when package.json present"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
