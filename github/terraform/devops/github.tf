data "azurerm_key_vault_secret" "gh-repo-url" {
  key_vault_id = "/subscriptions/abc123/resourceGroups/kvrg/providers/Microsoft.KeyVault/vaults/devopskv"
  name         = "gh-repo-url"
}
data "azurerm_key_vault_secret" "gh-pat-token" {
  key_vault_id = "/subscriptions/abc123/resourceGroups/kvrg/providers/Microsoft.KeyVault/vaults/devopskv"
  name         = "gh-token"
}

locals {
  repo_url     = data.azurerm_key_vault_secret.gh-repo-url.value
  gh-token     = data.azurerm_key_vault_secret.gh-pat-token.value
  owner        = "<your organization>" # is either the github organization or username, whoever owns the Repo
  repo         = "<repo-name>"
  githubAPIURL = "https://api.github.com" # default, only needs to be changed if you're hosting a GitHub Enterprise instance
}

resource "azurerm_resource_group" "devops-rg" {
  name     = "devops-rg"
  location = local.location
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = "devops-law"
  location            = local.location
  resource_group_name = azurerm_resource_group.hub-devops-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}

resource "azurerm_container_app_job" "caj-gh-sh" {
  name                         = "caj-gh-sh"
  location                     = local.location
  resource_group_name          = azurerm_resource_group.devops-rg.name
  container_app_environment_id = azurerm_container_app_environment.devops-cae.id

  replica_timeout_in_seconds = 120
  replica_retry_limit        = 0

  secret {
    name  = "personal-access-token"
    value = data.azurerm_key_vault_secret.gh-pat-token.value
  }
  secret {
    name  = "repo-url"
    value = data.azurerm_key_vault_secret.gh-repo-url.value
  }


  event_trigger_config {
    parallelism              = 1
    replica_completion_count = 1


    scale {
      min_executions              = 0
      max_executions              = 10
      polling_interval_in_seconds = 30

      rules {
        name             = "github-runner"
        custom_rule_type = "github-runner"
        metadata = {
          "githubAPIURL"              = local.githubAPIURL
          "owner"                     = local.owner
          "runnerScope"               = "repo"
          "repos"                     = local.repo
          "targetWorkflowQueueLength" = "1"

        }
        authentication {
          secret_name = "personal-access-token" # reference to the secret saved above here in the Container Apps Job

          # this is one is a little tricky, because it references a configuration option in KEDA
          # in KEDA, this would be the reference on the TriggerAuthentication.spec.secretTargetRef.parameter Object
          # see keda-ghsh-scaler.yml for an example
          trigger_parameter = "personalAccessToken"
        }
      }
    }
  }




  template {
    container {
      name   = "github-runner"                           # container name, not image
      image  = "<your acr>/<cr-repo>/<image-name>:<tag>" # e.g. corp123.azurecr.io/devops-images/gh-runner:v0.2
      cpu    = 1
      memory = "2Gi"

      env {
        name  = "GITHUB_PAT"
        value = data.azurerm_key_vault_secret.gh-pat-token.value
      }
      env {
        name  = "GH_URL"
        value = data.azurerm_key_vault_secret.gh-repo-url.value
      }
      # or save it as a config key/secret to the keyvault, whatever suits you
      env {
        name  = "REGISTRATION_TOKEN_API_URL"
        value = "${local.githubAPIURL}/repos/${local.owner}/${local.repo}/actions/runners/registration-token"
      }
    }
  }

}

resource "azurerm_container_app_environment" "devops-cae" {
  name                       = "cae-devops"
  location                   = local.location
  resource_group_name        = azurerm_resource_group.devops-rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id

}
