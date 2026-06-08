#!/bin/bash
set -euo pipefail

ENV=$1
ACCOUNT_ID=$(aws sts get-caller-identity --profile "$ENV" --query Account --output text)
BUCKET="tf-state-appointease-${ENV}-${ACCOUNT_ID}"
TABLE="tf-locks-appointease-${ENV}"
REGION="ap-south-1"

echo "=== Bootstrapping AppointEase $ENV ==="
echo "Account : $ACCOUNT_ID"
echo "Bucket  : $BUCKET"
echo "Table   : $TABLE"

aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  --profile "$ENV"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled \
  --profile "$ENV"

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile "$ENV"

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
  --profile "$ENV"

aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  --profile "$ENV"

echo "=== Done: $ENV ==="
echo "Bucket  : $BUCKET"
echo "Table   : $TABLE"
