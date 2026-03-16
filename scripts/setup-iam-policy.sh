#!/usr/bin/env bash
# =============================================================================
# setup-iam-policy.sh
# Creates/updates an IAM policy for the GitHub Actions user so it can
# manage ECR, App Runner, and the required IAM role — all from CI.
# Usage:  AWS_IAM_USER=github-actions-ecr bash scripts/setup-iam-policy.sh
# =============================================================================
set -euo pipefail

IAM_USER="${AWS_IAM_USER:?AWS_IAM_USER is required (your IAM username)}"
POLICY_NAME="GitHubActionsECRAppRunnerPolicy"

POLICY_DOC='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRFullAccess",
      "Effect": "Allow",
      "Action": "ecr:*",
      "Resource": "*"
    },
    {
      "Sid": "ECRAuth",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Sid": "AppRunnerFullAccess",
      "Effect": "Allow",
      "Action": "apprunner:*",
      "Resource": "*"
    },
    {
      "Sid": "IAMRoleForAppRunner",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:AttachRolePolicy",
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/AppRunnerECRAccessRole"
    },
    {
      "Sid": "STSIdentity",
      "Effect": "Allow",
      "Action": "sts:GetCallerIdentity",
      "Resource": "*"
    }
  ]
}'

echo "📋 Creating/updating inline policy '${POLICY_NAME}' on user '${IAM_USER}'..."

aws iam put-user-policy \
  --user-name "${IAM_USER}" \
  --policy-name "${POLICY_NAME}" \
  --policy-document "${POLICY_DOC}"

echo "✅ Policy '${POLICY_NAME}' applied to user '${IAM_USER}'."
echo ""
echo "The user now has permissions for: ECR, App Runner, and IAM role management."
