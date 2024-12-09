#!/bin/bash

set -e

# modified script from:
# https://github.com/actions/runner/blob/main/scripts/delete.sh

repo=""
owner=""
RUNNER_CFG_PAT=""
#runner_names=$(gh api -H "Accept: application/vnd.github+json" /repos/meowmentum/gh-sh-runner/actions/runners | jq -r '.runners[].name')
count=$(curl -s -X GET "https://api.github.com/repos/${owner}/${repo}/actions/runners?per_page=100" -H "accept: application/vnd.github+json" -H "authorization: token ${RUNNER_CFG_PAT}" | jq -r ".total_count")
echo $count
runner_names=$(curl -s -X GET "https://api.github.com/repos/${owner}/${repo}/actions/runners?per_page=100" -H "accept: application/vnd.github+json" -H "authorization: token ${RUNNER_CFG_PAT}" | jq -r ".runners[].name")
#echo $runner_names




function fatal() 
{
   echo "error: $1" >&2
   exit 1
}

if [ -z "${runner_scope}" ]; then fatal "supply scope as argument 1"; fi
if [ -z "${RUNNER_CFG_PAT}" ]; then fatal "RUNNER_CFG_PAT must be set before calling"; fi

base_api_url="https://api.github.com/repos"

# limit the number of executions because otherwise the rate limit of ~5000 requests/h is exceeded
for ((i = 0, i<100, i++)); do
    echo "iteration $i"

#echo $runner_names
for runner_name in ${runner_names}; do
    echo "Deleting runner ${runner_name} @ ${owner}/${repo}"

    #--------------------------------------
    # Get id of runner to remove
    #--------------------------------------

    runner_id=$(curl -s -X GET ${base_api_url}/${owner}/${repo}/actions/runners?per_page=100  -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token ${RUNNER_CFG_PAT}" \
            | jq -M -j ".runners | .[] | select(.name == \"${runner_name}\") | .id")

    if [ -z "${runner_id}" ]; then 
        fatal "Could not find runner with name ${runner_name}"
    fi 

    #--------------------------------------
    # Remove the runner
    #--------------------------------------
    curl -s -X DELETE ${base_api_url}/${owner}/${repo}/actions/runners/${runner_id} -H "authorization: token ${RUNNER_CFG_PAT}"

    echo "Delete Done."
done

done
