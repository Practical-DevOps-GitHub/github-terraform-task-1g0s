# Task Completion Instructions

This document contains step-by-step instructions to complete the GitHub Terraform task.

## What Has Been Prepared

✅ Terraform configuration in `src/main.tf`:
- Collaborator: `softservedata`
- Default branch: `develop`
- Branch protection for `main` and `develop`
- CODEOWNERS file
- Pull request template
- Deploy key: `DEPLOY_KEY`
- Actions secret: `PAT`

✅ SSH deploy key generated in `keys/`
✅ Workflow updated to pass PAT as Terraform variable

## Required Steps

### Step 1: Create a Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Direct link: https://github.com/settings/tokens

2. Click "Generate new token" → "Generate new token (classic)"

3. Configure the token:
   - **Note**: `Terraform Task PAT`
   - **Expiration**: Choose appropriate expiration
   - **Scopes** (check these):
     - ✅ `repo` (Full control of private repositories) - ALL sub-options
     - ✅ `workflow` (Update GitHub Action workflows)
     - ✅ `admin:org` (Full control of orgs and teams) - ALL sub-options
     - ✅ `admin:repo_hook` (Full control of repository hooks)

4. Click "Generate token"

5. **COPY THE TOKEN** - You won't be able to see it again!
   - Format: `ghp_` followed by 36 characters
   - Example: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Step 2: Add PAT to Repository Secrets

You can use either the GitHub UI or the automated script:

#### Option A: Using GitHub UI

1. Go to: https://github.com/Practical-DevOps-GitHub/github-terraform-task-1g0s/settings/secrets/actions

2. Click "New repository secret"

3. Add the PAT secret:
   - **Name**: `PAT`
   - **Value**: Paste your PAT token (ghp_...)

4. Click "Add secret"

#### Option B: Using Script (requires gh CLI)

```bash
# Install gh CLI if needed (Ubuntu/Debian)
sudo apt update && sudo apt install gh -y

# Authenticate
gh auth login

# Navigate to repository directory
cd /home/igor/devops/adv09/github-terraform-task-1g0s

# Set your PAT as environment variable
export GITHUB_PAT="ghp_your_token_here"

# Run the setup script
bash setup_secrets.sh
```

### Step 3: Add Terraform Code to TERRAFORM Secret

The Terraform configuration needs to be stored in a repository secret named `TERRAFORM`.

#### Option A: Using GitHub UI

1. Go to: https://github.com/Practical-DevOps-GitHub/github-terraform-task-1g0s/settings/secrets/actions

2. Click "New repository secret"

3. Add the Terraform code:
   - **Name**: `TERRAFORM`
   - **Value**: Copy the entire content of `src/main.tf` file

4. Click "Add secret"

#### Option B: Using gh CLI

```bash
# Navigate to repository
cd /home/igor/devops/adv09/github-terraform-task-1g0s

# Add TERRAFORM secret from file
gh secret set TERRAFORM --body-file src/main.tf --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

### Step 4: Commit and Push Changes

```bash
cd /home/igor/devops/adv09/github-terraform-task-1g0s

# Stage changes
git add .github/workflows/ruby.yml

# Commit
git commit -m "Update workflow to pass PAT variable to Terraform"

# Push to main branch
git push origin main
```

### Step 5: Trigger and Monitor Workflow

The workflow should trigger automatically on push. To monitor:

```bash
# View workflow runs
gh run list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Watch the latest run
gh run watch --repo Practical-DevOps-GitHub/github-terraform-task-1g0s

# Or view in browser
gh run view --web --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

Or manually trigger:
```bash
gh workflow run ruby.yml --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
```

## Verification

The workflow will execute and verify:

### Terraform Tests:
✅ `github_branch_default` - develop branch is default
✅ `github_repository_collaborator` - softservedata is collaborator
✅ `github_branch_protection` (develop) - requires 2 approvals
✅ `github_branch_protection` (main) - requires code owner review
✅ `github_actions_secret` - PAT secret exists
✅ `github_repository_deploy_key` - DEPLOY_KEY exists

### Ruby Tests:
✅ PAT token format is valid (ghp_XXXXX)
✅ Deploy key exists with title "DEPLOY_KEY"
✅ Branches main and develop exist and are protected
✅ develop is the default branch
✅ CODEOWNERS file exists on main branch with softservedata
✅ CODEOWNERS doesn't exist on develop branch
✅ Pull request template exists
✅ Branch protection rules configured correctly

## Troubleshooting

### PAT Not Found
```bash
# Verify secrets are set
gh secret list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
# Should show: PAT, TERRAFORM
```

### Invalid PAT Format
The PAT must match the pattern: `ghp_` followed by exactly 36 alphanumeric characters.

### Terraform Plan Fails
Check the workflow logs for specific errors:
```bash
gh run list --repo Practical-DevOps-GitHub/github-terraform-task-1g0s
gh run view <run-id> --log
```

### Permission Denied
Ensure your PAT has all required scopes:
- repo (all)
- workflow
- admin:org (all)
- admin:repo_hook (all)

## Additional Notes

### Deploy Key Location
- Private key: `keys/deploy_key` (keep secure, do not commit!)
- Public key: `keys/deploy_key.pub` (already embedded in Terraform code)

### Terraform Variable
The workflow now passes the PAT to Terraform via:
```yaml
env:
  TF_VAR_pat_token: ${{ secrets.PAT }}
  GITHUB_TOKEN: ${{ steps.my-app.outputs.token }}
```

This allows Terraform to create/manage the PAT secret in the repository.

## Next Steps After Success

Once all tests pass:
1. ✅ Verify develop is now the default branch
2. ✅ Test creating a pull request to main or develop
3. ✅ Verify branch protection rules work as expected
4. ✅ Check that CODEOWNERS file requires review from softservedata
