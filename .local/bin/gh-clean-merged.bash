#!/usr/bin/env bash
set -o errexit  # -e: exit on uncaught error
set -o nounset  # -u: error on unset vars
set -o pipefail # fail a pipeline if any command fails
IFS=$'\n\t'     # safer word-splitting (no split on space)

readonly PR_LIMIT=1000

# Query repoitory's metadata: default branch and owner/repo name
repo_view=$(gh repo view --json defaultBranchRef,nameWithOwner)
main_branch=$(jq --raw-output '.defaultBranchRef.name' <<<"$repo_view")
name_with_owner=$(jq --raw-output '.nameWithOwner' <<<"$repo_view")
owner=${repo_name_with_owner%/*}

if [[ $# -ge 1 ]]; then
    since_date=$1
else
    if date --version >/dev/null 2>&1; then
        # GNU date
        since_date=$(date -d "6 months ago" +%Y-%m-%d)
    else
        # BSD date (macOS)
        since_date=$(date -v -6m +%Y-%m-%d)
    fi
fi

# Update local knowledge of remote branches, remove stale refs
git fetch --prune

# For each merged PR branch, get its name and the merged commit
gh pr list --state merged --base "$main_branch" \
    --search "merged:>=2024-01-01" --limit $PR_LIMIT \
    --json headRefName,headRefOid \
    --jq '.[] | [.headRefName, .headRefOid] | @tsv' |
    while IFS=$'\t' read -r branch pr_head; do
        # Remote branch no longer exists (already deleted)
        if ! git show-ref --verify --quiet refs/remotes/origin/$branch; then
            continue
        fi

        # Current commit that the remote branch points to
        branch_commit=$(git rev-parse origin/$branch)

        # Delete the branch if:
        #  1. Its current commit is contained in main’s history
        #     (normal fast-forward merge case), OR
        #  2. Its current commit matches the PR head commit
        #     (squash/rebase merge cases)
        if git merge-base --is-ancestor "$branch_commit" origin/$main_branch ||
            [[ "$branch_commit" == "$pr_head" ]]; then
            git push origin --delete "$branch"
        fi
    done
