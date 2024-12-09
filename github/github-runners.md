# Github Self-hosted Runners

Challenge originally came from: [MSFT/Azure - Tutorial: Run Self-Hosted Agents on Event-Triggered Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions)

Learnings:
- event-triggered, ephemeral Runners should not only be registered, but also unregistered.
- Github has a limit of ~ 10k Runners on a Repo. 
- misconfigured or badly build Container Images can lead to excessive amounts of registered (but destroyed) runners
- dealing with dead runners in GitHub can be time consuming

