terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "pat_token" {
  description = "Personal Access Token to store in repository secrets"
  type        = string
  sensitive   = true
}

provider "github" {
  owner = "Practical-DevOps-GitHub"
}

data "github_repository" "repo" {
  full_name = "Practical-DevOps-GitHub/github-terraform-task-1g0s"
}

resource "github_branch" "develop" {
  repository    = data.github_repository.repo.name
  branch        = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default" {
  repository = data.github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_repository_collaborator" "collaborator" {
  repository = data.github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch_protection" "develop_protection" {
  repository_id = data.github_repository.repo.node_id
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
    dismiss_stale_reviews           = true
  }

  enforce_admins = false

  depends_on = [github_branch.develop]
}

resource "github_branch_protection" "main_protection" {
  repository_id = data.github_repository.repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 0
    require_code_owner_reviews      = true
  }

  enforce_admins = false
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = data.github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrGXJtwO5LIZVluoYN1VQ3p6UA43RuEoKfeFmTWkOYv deploy-key-github-terraform"
  read_only  = true
}

resource "github_actions_secret" "pat_secret" {
  repository      = data.github_repository.repo.name
  secret_name     = "PAT"
  plaintext_value = var.pat_token
}

resource "github_repository_file" "codeowners" {
  repository          = data.github_repository.repo.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata\n"
  commit_message      = "Add CODEOWNERS file"
  overwrite_on_create = true
}

resource "github_repository_file" "pr_template" {
  repository          = data.github_repository.repo.name
  branch              = "main"
  file                = ".github/pull_request_template.md"
  content             = <<-EOT
## Describe your changes

## Issue ticket number and link

## Checklist before requesting a review
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOT
  commit_message      = "Add pull request template"
  overwrite_on_create = true
}
