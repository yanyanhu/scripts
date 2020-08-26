#!/bin/bash
#
# This is a script to deploy the frontend using aws s3 cmd
#

set -e

ENV=${1:-TEST}

echo "--------- Set up asw env vars for $ENV environment."
export AWS_ACCESS_KEY_ID_TO_USE=AWS_ACCESS_KEY_ID_${ENV}
export AWS_SECRET_ACCESS_KEY_TO_USE=AWS_SECRET_ACCESS_KEY_${ENV}

export AWS_ACCESS_KEY_ID=${!AWS_ACCESS_KEY_ID_TO_USE}
export AWS_SECRET_ACCESS_KEY=${!AWS_SECRET_ACCESS_KEY_TO_USE}

S3_BUCKET_NAME_TO_USE=S3_BUCKET_NAME_${ENV}
export S3_BUCKET_NAME=${!S3_BUCKET_NAME_TO_USE}

# Deploy the frontend by copying the build folder to the S3 bucket.
echo "--------- aws s3 cp ./build/ s3://$S3_BUCKET_NAME/targetfolder/ --recursive"
aws s3 cp ./build/ s3://$S3_BUCKET_NAME/targetfolder/ --recursive

exit 0
