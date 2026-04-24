#!/bin/bash
set -euo pipefail

# Octopus project variable 'BranchName' should be bound to:
# #{Octopus.Action[Create Branch].Output.BranchName}
export GH_TOKEN=$(get_octopusvariable "GithubAuth")

REPO="tleed5/OctopusVCSTest"
BRANCH_NAME=$(get_octopusvariable "BranchName")

echo "Deleting branch '$BRANCH_NAME' from $REPO..."

gh api "repos/$REPO/git/refs/heads/$BRANCH_NAME" --method DELETE

echo "Branch '$BRANCH_NAME' deleted successfully."
