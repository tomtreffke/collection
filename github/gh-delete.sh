#!/bin/bash

# modified script from:
# https://github.com/actions/runner/blob/main/scripts/delete.sh

set -e

runner_scope="repos"
repo="<repo name>"
owner="<owner of repo>"
RUNNER_CFG_PAT="<your github pat>"
count=$(curl -s -X GET "https://api.github.com/repos/${owner}/${repo}/actions/runners?per_page=100" -H "accept: application/vnd.github+json" -H "authorization: token ${RUNNER_CFG_PAT}" | jq -r ".total_count")
#echo $count
runner_names=$(curl -s -X GET "https://api.github.com/repos/${owner}/${repo}/actions/runners?per_page=100" -H "accept: application/vnd.github+json" -H "authorization: token ${RUNNER_CFG_PAT}" | jq -r ".runners[].name")
runner_name_count=$(echo "$runner_names" | wc -l )
#echo "number of Runner_names: $runner_name_count"



function fatal() 
{
   echo "error: $1" >&2
   exit 1
}

which curl || fatal "curl required.  Please install in PATH with apt-get, brew, etc"
which jq || fatal "jq required.  Please install in PATH with apt-get, brew, etc"


base_api_url="https://api.github.com/repos"

for runner_name in ${runner_names}; do
    echo "Deleting runner ${runner_name} @ ${owner}/${repo}"
#--------------------------------------
# Ensure offline
#--------------------------------------
    echo "Checking runner status"

    runner_status==$(curl -s -X GET https://api.github.com/repos/${owner}/${repo}/actions/runners -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token ${RUNNER_CFG_PAT}" | jq -M -j ".runners | .[] | select(.name == \"${runner_name}\") | .status")

    if [ -z "${runner_status}" ]; then 
        fatal "Could not find runner with name ${runner_name}"
    fi

    echo "Status: ${runner_status}"

    if [ "${runner_status}" != "offline" ]; then 
        echo "Runner should be offline before removing"
    fi

    #--------------------------------------
    # Get id of runner to remove
    #--------------------------------------
    echo $runner_name
    echo "${base_api_url}/${owner}/${repo}/actions/runners" #?per_page=100
    runner_id=$(curl -s -X GET ${base_api_url}/${owner}/${repo}/actions/runners?per_page=100  -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token ${RUNNER_CFG_PAT}" \
            | jq -M -j ".runners | .[] | select(.name == \"${runner_name}\") | .id")
    #echo "runner_id: ${runner_id}"

    if [ -z "${runner_id}" ]; then 
        echo "Could not find runner with name ${runner_name}"
    fi 

    echo "<< -- Removing id ${runner_id} -- >>"

    #--------------------------------------
    # Remove the runner
    #--------------------------------------
    curl -s -X DELETE ${base_api_url}/${owner}/${repo}/actions/runners/${runner_id} -H "authorization: token ${RUNNER_CFG_PAT}"

    echo " -> Done. <-"
done
