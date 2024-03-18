#!/bin/bash

echo "current directory:"
echo $(pwd)
HEAD_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "The following changes since commit" | awk '{print $6}' | awk -F : '{print $1}')
BASE_REF=$(git request-pull -p "$HEAD_BRANCH" ./ "$BASE_BRANCH" | grep "for you to fetch changes up to" | awk '{print $8}' | awk -F : '{print $1}')
if [[ "${HEAD_REF}" == "${BASE_REF}" ]]; then
      echo "result=false" >> "$GITHUB_OUTPUT"
  else
    echo "result=true" >> "$GITHUB_OUTPUT"
fi