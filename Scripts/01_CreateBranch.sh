#!/bin/bash
set -euo pipefail

export GH_TOKEN=$(get_octopusvariable "GithubAuth")

REPO="tleed5/OctopusVCSTest"
REPO2="tleed5/ArgoCDTestSource"
BASE_BRANCH="main"
BRANCH_NAME="release/test-$(date +%Y%m%d-%H%M%S)"

echo "Creating branch '$BRANCH_NAME' from '$BASE_BRANCH' in $REPO..."

BASE_SHA=$(gh api "repos/$REPO/git/ref/heads/$BASE_BRANCH" --jq '.object.sha')
echo "Base SHA: $BASE_SHA"

gh api "repos/$REPO/git/refs" \
  --method POST \
  --field "ref=refs/heads/$BRANCH_NAME" \
  --field "sha=$BASE_SHA"

echo "Branch '$BRANCH_NAME' created successfully in $REPO."

echo "Creating branch '$BRANCH_NAME' from '$BASE_BRANCH' in $REPO2..."

BASE_SHA2=$(gh api "repos/$REPO2/git/ref/heads/$BASE_BRANCH" --jq '.object.sha')
echo "Base SHA: $BASE_SHA2"

gh api "repos/$REPO2/git/refs" \
  --method POST \
  --field "ref=refs/heads/$BRANCH_NAME" \
  --field "sha=$BASE_SHA2"

echo "Branch '$BRANCH_NAME' created successfully in $REPO2."

set_octopusvariable "BranchName" "$BRANCH_NAME"
echo "Output variable 'BranchName' set to: $BRANCH_NAME"
