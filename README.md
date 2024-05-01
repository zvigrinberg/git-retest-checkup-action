# Git retest checkup action

This is a Github Action that checks if re-test of application in a workflow is needed.

## Background

The Idea behind this action is to check if PR' tests before merge or deployment needs additional tests, that is, if combining the code and tests Of the head branch ( source branch) together with base branch tests and code that are not present at head branch, then after the merge from head to base branch, it's possible that one of the tests might break, thus re-test of everything is needed before merging or before staging/releasing.


## Usage

<!-- start usage -->
```yaml
- name: Check if re-test is needed
  uses: zvigrinberg/git-retest-checkup-action@v1
  with:
     # The base branch of the PR Event
    base-ref: ''
     # The head or source branch of the PR Event
    pr-ref: ' '
```
<!-- end usage -->

## Inputs

| Key                   | Description                                                                                                                        | Default value  |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------|----------------|
| `base-ref`            | Base ref commit branch, tag or sha digest, usually the upstream branch                                                             | `HEAD`         |
| `pr-ref`              | Head ref commit branch, tag or sha digest, usually a PR head branch                                                                | `HEAD`         |
| `file-pattern-regex`  | String Regex pattern to trigger testing ( return true result for re-testing) only if one of the changed files matches that pattern | `HEAD`         |


## Outputs

| Key                    | Description                                                   | Example |
|------------------------|---------------------------------------------------------------|---------|
| `retest-is-needed`     | Returns true if re-test is needed, otherwise, returns false   | `true`  |



## Scenarios


Two use cases:

1. When Opening A PR and testing head branch (PR branch) , then use this action to check if 
   it required to re-test with additional content from base branch ( if exists), this happens when the head branch is forked from the base branch, and before merged back to base branch, another branch merged into base.
   whenever it happens, it's desirable to know if you need to re-test with additional content from base branch, before allowing merging head branch.

Example usage:

```yaml
name: Pull Request Review

on:
   pull_request:

      branches: [ "main" ]

   workflow_dispatch:

jobs:
   build:
      runs-on: ubuntu-latest

      steps:

         # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
         - name: Checkout git Repo
           uses: actions/checkout@v4
           with:
             fetch-depth: 0

         - name: Setup Java 17
           uses: actions/setup-java@v3
           with:
              distribution: temurin
              java-version: 17
              cache: maven


         - name: Test Java

           run: mvn clean test

         - name: Check if re-test is needed
           id: test-check
           uses: zvigrinberg/git-retest-checkup-action@v1
           with:
              base-ref: ${{ github.base_ref }}
              pr-ref: ${{ github.head_ref }}

         - name: re-test with additional content from base branch
           if: ${{ steps.test-check.outputs.retest-is-needed == "true" }}
           env:
              RETEST_IS_NECESSARY: ${{ steps.test-check.outputs.retest-is-needed }}
              BASE_BRANCH: ${{ github.base_ref }}
           run: |
              git merge $BASE_BRANCH --squash
              mvn clean test
```


2. When Merging A PR, then use this action to check if it's required to re-test the base branch after merge, this could happen when the head branch is forked from the base branch, and before merged back to base branch, another branch merged into base.
whenever it happens, it's desirable to know if you need to re-test the base branch ( now containing also content from head branch after it has been merged), before allowing staging/releasing the application.

Example usage:

```yaml
name: CI Staging workflow

on:
  pull_request_target:
    types:
      - closed
    branches: [ "main" ]


  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - name: Checkout git Repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Java 17
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: 17
          cache: maven

      - name: Check if re-test is needed
        id: test-check
        uses: zvigrinberg/git-retest-checkup-action@v1
        with:
          base-ref: ${{ github.base_ref }}
          pr-ref: ${{ github.head_ref }}
          # only trigger retesting if any file in src directory of repo was changed. 
          file-pattern-regex: "^src/.*"


      - name: Install Java
        env:
          RETEST_IS_NECESSARY: ${{ steps.test-check.outputs.retest-is-needed}}
        run: |
          if [[ $RETEST_IS_NECESSARY == "true" ]]; then
             mvn clean install
          else
             mvn clean install -DskipTests=true
          fi
```
