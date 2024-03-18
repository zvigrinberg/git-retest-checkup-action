#!/bin/bash

echo "current directory:"
echo $(pwd)
echo "HEAD_BRANCH=$HEAD_BRANCH"
echo "$BASE_BRANCH=$BASE_BRANCH"
git branch -av
git request-pull "$HEAD_BRANCH" ./ "$BASE_BRANCH"
HEAD_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "The following changes since commit" | awk '{print $6}' | awk -F : '{print $1}')
BASE_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "for you to fetch changes up to" | awk '{print $8}' | awk -F : '{print $1}')
echo "HEAD_REF= $HEAD_REF"
echo "BASE_REF= $BASE_REF"
if [[ "${HEAD_REF}" == "${BASE_REF}" ]]; then
      echo "result=false" >> "$GITHUB_OUTPUT"
  else
    echo "result=true" >> "$GITHUB_OUTPUT"
fi