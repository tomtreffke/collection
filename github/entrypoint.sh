#!/bin/sh -l

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $GITHUB_PAT" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"

./config.sh --url $GH_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh

# decommission the agent from Github after ./run.sh has finished executing
# happens when the even-triggered job finishes as either error or success
if [ -z "$REGISTRATION_TOKEN" != "" ]; then
    ./config.sh remove $REGISTRATION_TOKEN
else
    ./config.sh remove $PAT
fi