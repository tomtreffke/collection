# Github Self-hosted Runners

Challenge originally came from: [MSFT/Azure - Tutorial: Run Self-Hosted Agents on Event-Triggered Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions)

Learnings:
- event-triggered, ephemeral Runners should not only be registered, but also unregistered.
- Github has a limit of ~ 10k Runners on a Repo. (December 2024)
- misconfigured or badly build Container Images can lead to excessive amounts of registered (but destroyed) runners
- dealing with dead runners in GitHub can be time consuming

## Overview

- Example Terraform Deployment for the Tutorial
- modified container image file
- modified entrypoint.sh to cleanup (unregister the spawned runner)
- cleanup script in case something is misconfigured during the deployment and you need to get rid of runners in your Github Project

## Deleting Dead Runners from a Github Repo

use collection/github/gh-delete.sh

```
chmod +x ./gh-delete.sh
./gh-delete.sh
```

if you reached 10k runners, make it a cronjob (e.g. execution every 5min)

```
>> crontab -e

*/5 * * * * /<absolute path to script>/gh-delete.sh
```
