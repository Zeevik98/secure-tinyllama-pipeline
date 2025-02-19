#!/usr/bin/env bash
################################################################################
# deploy_sagemaker.sh
#
# A script invoked by GitHub Actions to do more granular steps for SageMaker.
# Example usage:
#   ./deploy_sagemaker.sh <MODEL_S3_PATH> <ENDPOINT_NAME>
################################################################################

set -euo pipefail

MODEL_S3_PATH="$1"
ENDPOINT_NAME="$2"

echo "Deploying model from S3 path: $MODEL_S3_PATH to SageMaker endpoint: $ENDPOINT_NAME"

# Example of packaging a model or calling AWS CLI for SageMaker:
aws sagemaker create-model \
  --model-name "${ENDPOINT_NAME}-model" \
  --primary-container Image="123456789012.dkr.ecr.us-east-1.amazonaws.com/tinyllama:latest",ModelDataUrl="${MODEL_S3_PATH}" \
  --execution-role-arn "arn:aws:iam::123456789012:role/SageMakerExecutionRole" \
  --region "us-east-1"

# Then create an endpoint config
aws sagemaker create-endpoint-config \
  --endpoint-config-name "${ENDPOINT_NAME}-config" \
  --production-variants VariantName="AllTraffic",ModelName="${ENDPOINT_NAME}-model",InitialInstanceCount=1,InstanceType="ml.m5.large"

# Finally create or update the endpoint
aws sagemaker create-endpoint \
  --endpoint-name "${ENDPOINT_NAME}" \
  --endpoint-config-name "${ENDPOINT_NAME}-config"

echo "SageMaker endpoint deployment initiated."
echo "You can check status with: aws sagemaker describe-endpoint --endpoint-name ${ENDPOINT_NAME}"
