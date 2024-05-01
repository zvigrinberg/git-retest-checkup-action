import base64
import os
import re

thereIsAChange = os.environ.get("INTERMEDIATE_RESULT")
changedFiles = os.environ.get("CHANGED_FILES")
pattern = os.environ.get("FILE_PATTERN_REGEX").strip()
result = False
if thereIsAChange == 'true' and pattern.strip() != '':
    files = base64.b64decode(changedFiles).decode('utf-8')
    listOfFiles = files.splitlines()
    for file in listOfFiles:
        if re.search(pattern, file):
            result = True
            break

if "GITHUB_OUTPUT" in os.environ:
    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
        print("{0}={1}".format("result", "true" if result or (thereIsAChange == 'true' and pattern.strip() == '') else "false"), file=f)
