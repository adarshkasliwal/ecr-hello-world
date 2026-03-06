#!/usr/bin/env bash
# =============================================================================
# create-ecr-repo.sh
# Idempotently creates an AWS ECR repository and applies a lifecycle policy.
# Required env vars: AWS_REGION, ECR_REPOSITORY
# =============================================================================
set -euo pipefail

REGION="${AWS_REGION:?AWS_REGION is required}"
REPO_NAME="${ECR_REPOSITORY:?ECR_REPOSITORY is required}"

echo "🔍  Checking for ECR repository: ${REPO_NAME} in ${REGION}..."

# Check if the repository already exists
if aws ecr describe-repositories \
      --repository-names "${REPO_NAME}" \
      --region "${REGION}" \
      --output text &>/dev/null; then
  echo "✅  Repository '${REPO_NAME}' already exists — skipping creation."
else
  echo "🚀  Creating ECR repository: ${REPO_NAME}..."
  aws ecr create-repository \
    --repository-name "${REPO_NAME}" \
    --region "${REGION}" \
    --image-scanning-configuration scanOnPush=true \
    --image-tag-mutability MUTABLE \
    --output json | jq -r '.repository.repositoryUri'
  echo "✅  Repository created."
fi

# Apply / update lifecycle policy (keep at most 10 images)
echo "📋  Applying lifecycle policy (max 10 images)..."

LIFECYCLE_POLICY='{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the 10 most recent images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": { "type": "expire" }
    }
  ]
}'

aws ecr put-lifecycle-policy \
  --repository-name "${REPO_NAME}" \
  --region "${REGION}" \
  --lifecycle-policy-text "${LIFECYCLE_POLICY}" \
  --output text

echo "✅  Lifecycle policy applied."
echo ""
echo "🎉  ECR repository '${REPO_NAME}' is ready in region '${REGION}'."
