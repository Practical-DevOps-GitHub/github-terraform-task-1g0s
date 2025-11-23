# Setup Guide for GitHub Terraform Task

This guide explains how to complete the GitHub Terraform task step by step.

## Prerequisites

1. GitHub CLI (`gh`) installed
2. Authenticated with GitHub
3. Access to the repository: `Practical-DevOps-GitHub/github-terraform-task-1g0s`

## Task Requirements

The task requires configuring a GitHub repository using Terraform with the following:

1. ✅ Add collaborator `softservedata`
2. ✅ Create `develop` branch as default
3. ✅ Protect `main` and `develop` branches
4. ✅ Add CODEOWNERS file
5. ✅ Add pull request template
6. ✅ Add deploy key named `DEPLOY_KEY`
7. ✅ Add PAT to repository secrets named `PAT`

## Step 1: Install GitHub CLI (if not installed)

```bash
# On Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
```

## Step 2: Authenticate with GitHub

```bash
gh auth login
```

Choose:
- GitHub.com
- HTTPS
- Authenticate with a token or browser

## Step 3: Create a Personal Access Token (PAT)

You need to create a PAT with the following scopes:
- **repo** (Full control of private repositories)
- **admin:org** (Full control of orgs and teams, read and write org projects)

### Create PAT via GitHub UI:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: `Terraform Task PAT`
4. Select scopes:
   - ✅ repo (all)
   - ✅ workflow
   - ✅ admin:org (all)
   - ✅ admin:repo_hook (all)
5. Generate token
6. **Copy the token** (ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)

### Or create PAT via CLI:

```bash
gh auth refresh -h github.com -s admin:org,repo,workflow,admin:repo_hook
# This will give you a token with the required scopes
```

## Step 4: Add Secrets to Repository

### Method 1: Using the provided script

```bash
# Set your PAT token as environment variable
export GITHUB_PAT="ghp_your_token_here"

# Run the setup script
bash setup_secrets.sh
```

### Method 2: Manual using gh CLI

```bash
# Navigate to repository
cd /home/igor/devops/adv09/github-terraform-task-1g0s

# Add PAT to repository secrets
gh secret set PAT --body "ghp_your_pat_token_here" --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Add Terraform code to TERRAFORM secret
gh secret set TERRAFORM --body-file src/main.tf --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Verify secrets were added
gh secret list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

## Step 5: Trigger the Workflow

```bash
# Push changes to trigger the workflow
git add .
git commit -m "Add Terraform configuration"
git push origin main

# Or manually trigger the workflow
gh workflow run ruby.yml --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

## Step 6: Monitor Workflow Execution

```bash
# Watch workflow runs
gh run watch --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Or view in browser
gh run view --web --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

## Verification

The workflow will:
1. Extract Terraform code from TERRAFORM secret
2. Run `terraform init` and `terraform validate`
3. Run `terraform plan` and verify the configuration
4. Run Ruby tests to verify:
   - PAT token format is correct (ghp_...)
   - Deploy key exists with title "DEPLOY_KEY"
   - Branches main and develop exist and are protected
   - develop is the default branch
   - CODEOWNERS file exists on main branch
   - Pull request template exists
   - Branch protection rules are correctly configured

## Troubleshooting

### Issue: PAT token not found or invalid format

```bash
# Verify the PAT secret is set
gh secret list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Should show: PAT

# Verify the token format (should start with ghp_)
echo $GITHUB_PAT | grep -E '^ghp_[a-zA-Z0-9]{36}$'
```

### Issue: Terraform plan fails

Check the workflow logs:
```bash
gh run list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
gh run view <run-id> --log --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

### Issue: Repository file creation fails

Make sure the GitHub App has write permissions to the repository.

## Files Created

- `src/main.tf` - Main Terraform configuration
- `keys/deploy_key` - Private deploy key (keep secure!)
- `keys/deploy_key.pub` - Public deploy key
- `SETUP.md` - This file
- `setup_secrets.sh` - Helper script for adding secrets

## Next Steps

Once the workflow passes:
1. Verify all tests pass (green checkmark)
2. Check that develop is now the default branch
3. Test creating a pull request
4. Verify branch protection rules work
