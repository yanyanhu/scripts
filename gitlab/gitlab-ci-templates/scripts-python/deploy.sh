#!/bin/bash
#
# This is a script to deploy AWS EB application
#

set -e

source ~/.bashrc

ENV=${1:-TEST}

# Set environment variables to access AWS
echo "--------- Set AWS env vars for $ENV environment."
export AWS_ACCESS_KEY_ID_TO_USE=AWS_ACCESS_KEY_ID_${ENV}
export AWS_SECRET_ACCESS_KEY_TO_USE=AWS_SECRET_ACCESS_KEY_${ENV}
export AWS_ACCESS_KEY_ID=${!AWS_ACCESS_KEY_ID_TO_USE}
export AWS_SECRET_ACCESS_KEY=${!AWS_SECRET_ACCESS_KEY_TO_USE}


# Set environment variables to deploy app
echo "--------- Set APP env vars for $ENV environment."
export APP_NAME_TO_USE=EB_APP_NAME_${ENV}
export ENV_NAME_TO_USE=EB_ENV_NAME_${ENV}
export APP_NAME=${!APP_NAME_TO_USE}
export ENV_NAME=${!ENV_NAME_TO_USE}

export REGION=ap-southeast-1
export TIMEOUT=300


# Deploy APP in the exising environment using eb cli.
echo "--------- eb init -p docker --region $REGION $APP_NAME"
eb init -p docker --region $REGION $APP_NAME

echo "--------- eb use $ENV_NAME --region $REGION"
eb use $ENV_NAME --region $REGION

echo "--------- eb deploy --timeout 300"
eb deploy --timeout $TIMEOUT

exit 0
