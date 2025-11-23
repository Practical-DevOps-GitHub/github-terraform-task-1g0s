#!/bin/bash

# Setup script for adding GitHub repository secrets
# Usage: ./setup_secrets.sh

set -e

REPO="Practical-DevOps-GitHub/github-terraform-task-1g0s"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==================================="
echo "GitHub Terraform Task - Setup"
echo "==================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  macOS: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub."
    echo "Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Check if PAT token is provided
if [ -z "$GITHUB_PAT" ]; then
    echo "⚠️  Warning: GITHUB_PAT environment variable is not set."
    echo ""
    read -p "Enter your GitHub Personal Access Token (PAT): " PAT_INPUT
    GITHUB_PAT="$PAT_INPUT"
fi

# Validate PAT format
if ! echo "$GITHUB_PAT" | grep -qE '^ghp_[a-zA-Z0-9]{36}$'; then
    echo "❌ Error: Invalid PAT format. Should be ghp_ followed by 36 alphanumeric characters."
    echo "Example: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    exit 1
fi

echo "✅ Valid PAT format detected"
echo ""

# Add PAT to repository secrets
echo "📝 Adding PAT to repository secrets..."
if gh secret set PAT --body "$GITHUB_PAT" --repo "$REPO"; then
    echo "✅ PAT secret added successfully"
else
    echo "❌ Failed to add PAT secret"
    exit 1
fi

# Check if Terraform file exists
if [ ! -f "$SCRIPT_DIR/src/main.tf" ]; then
    echo "❌ Error: Terraform file not found at $SCRIPT_DIR/src/main.tf"
    exit 1
fi

# Add Terraform code to TERRAFORM secret
echo "📝 Adding Terraform code to TERRAFORM secret..."
if gh secret set TERRAFORM --body-file "$SCRIPT_DIR/src/main.tf" --repo "$REPO"; then
    echo "✅ TERRAFORM secret added successfully"
else
    echo "❌ Failed to add TERRAFORM secret"
    exit 1
fi

echo ""
echo "==================================="
echo "✅ Setup completed successfully!"
echo "==================================="
echo ""
echo "Secrets added to repository:"
gh secret list --repo "$REPO"
echo ""
echo "Next steps:"
echo "1. Commit and push your changes:"
echo "   git add ."
echo "   git commit -m \"Add Terraform configuration\""
echo "   git push origin main"
echo ""
echo "2. Trigger the workflow:"
echo "   gh workflow run ruby.yml --repo $REPO"
echo ""
echo "3. Monitor the workflow:"
echo "   gh run watch --repo $REPO"
echo ""
