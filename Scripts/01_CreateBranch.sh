#!/bin/bash
set -euo pipefail

export GH_TOKEN=$(get_octopusvariable "GithubAuth")

REPO="tleed5/OctopusVCSTest"
BASE_BRANCH="main"
BRANCH_NAME="release/test-$(date +%Y%m%d-%H%M%S)"

echo "Creating branch '$BRANCH_NAME' from '$BASE_BRANCH' in $REPO..."

BASE_SHA=$(gh api "repos/$REPO/git/ref/heads/$BASE_BRANCH" --jq '.object.sha')
echo "Base SHA: $BASE_SHA"

gh api "repos/$REPO/git/refs" \
  --method POST \
  --field "ref=refs/heads/$BRANCH_NAME" \
  --field "sha=$BASE_SHA"

echo "Branch '$BRANCH_NAME' created successfully."

set_octopusvariable "BranchName" "$BRANCH_NAME"
echo "Output variable 'BranchName' set to: $BRANCH_NAME"
