#!/usr/bin/env bash
#
# Update all library submodules to their latest upstream versions.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Updating all library submodules..."
cd "$REPO_ROOT"

git submodule update --init --recursive
git submodule foreach --recursive 'git fetch origin && git checkout $(git remote show origin | grep "HEAD branch" | sed "s/.*: //") && git pull origin $(git remote show origin | grep "HEAD branch" | sed "s/.*: //")'

echo ""
echo "Done. Submodule status:"
git submodule status
echo ""
echo "Review changes with: git diff --submodule"
echo "Commit with:         git add libraries/ && git commit -m 'Update library submodules'"
