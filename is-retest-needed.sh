#!/bin/bash

echo "current directory:"
echo $(pwd)
echo "HEAD_BRANCH=$HEAD_BRANCH"
echo "BASE_BRANCH=$BASE_BRANCH"
CHECKED_OUT_REF=$(git rev-parse  --abbrev-ref HEAD)
# Save original checked out branch name
HEAD_BRANCH_REMOTE=$(git branch -av | grep -v "*" |grep $HEAD_BRANCH -m 1| awk '{print $1}')
git branch -av
echo "HEAD_BRANCH_REMOTE=$HEAD_BRANCH_REMOTE"
git checkout $HEAD_BRANCH_REMOTE
git branch $HEAD_BRANCH
git request-pull "$HEAD_BRANCH" ./ "$BASE_BRANCH"
HEAD_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "The following changes since commit" | awk '{print $6}' | awk -F : '{print $1}')
BASE_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "for you to fetch changes up to" | awk '{print $8}' | awk -F : '{print $1}')
echo "HEAD_REF= $HEAD_REF"
echo "BASE_REF= $BASE_REF"
# check out back to original branch name
git checkout $CHECKED_OUT_REF
if [[ "${HEAD_REF}" == "${BASE_REF}" ]]; then
      echo "result=false" >> "$GITHUB_OUTPUT"
  else
    echo "result=true" >> "$GITHUB_OUTPUT"
fi