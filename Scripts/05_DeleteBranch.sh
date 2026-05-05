#!/bin/bash
set -euo pipefail

# Octopus project variable 'BranchName' should be bound to:
# #{Octopus.Action[Create Branch].Output.BranchName}
export GH_TOKEN=$(get_octopusvariable "GithubAuth")

REPO="tleed5/OctopusVCSTest"
REPO2="tleed5/ArgoCDTestSource"
BRANCH_NAME=$(get_octopusvariable "Octopus.Action[Create Target Revision Branch].Output.BranchName")

echo "Deleting branch '$BRANCH_NAME' from $REPO..."
gh api "repos/$REPO/git/refs/heads/$BRANCH_NAME" --method DELETE
echo "Branch '$BRANCH_NAME' deleted successfully from $REPO."

echo "Deleting branch '$BRANCH_NAME' from $REPO2..."
gh api "repos/$REPO2/git/refs/heads/$BRANCH_NAME" --method DELETE
echo "Branch '$BRANCH_NAME' deleted successfully from $REPO2."
