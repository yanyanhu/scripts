#!/bin/bash
#
# This is a script to deploy lambda functions and cloudfront
# distribution using serverless and cloudformation cmds
#


# Set region to us-east-1 since it is the only region support
# lambda with cloudfront event.
export REGION=us-east-1
export STACK_TEMPLATE=./stack-template.yml
export STACK_TEMPLATE_UPDATED=./stack-template-to-update.yml


# Deploy lambda functions and cloudfront distributions using serverless cli.
# This will generate a cloudformation stack which will be updated further.
echo "--------- serverless deploy --stage prod --verbose --region $REGION --output json | tee deploy.log"
serverless deploy --stage prod --verbose --region $REGION --output json | tee deploy.log

# Extract the ID of cloudfront and cloudformation from deploy log
export CloudFrontID=$(cat deploy.log | grep "CloudFrontDistribution:" | awk '{print $2}')
echo $CloudFrontID
if grep -iq "CloudFormation - CREATE_COMPLETE - AWS::CloudFormation::Stack" deploy.log
then
    STACKID=$(grep -i "CloudFormation - CREATE_COMPLETE - AWS::CloudFormation::Stack" deploy.log | awk '{print $7}')
    echo "$STACKID CREATE_COMPLETE"
else
    STACKID=$(grep -i "CloudFormation - UPDATE_COMPLETE - AWS::CloudFormation::Stack" deploy.log | awk '{print $7}')
    echo "$STACKID UPDATE_COMPLETE"
fi

# Fetch the original stack template, update the configuration
# and update the stack.
echo "--------- aws cloudformation get-template --stack-name $STACKID --region $REGION | jq '.TemplateBody' > $STACK_TEMPLATE"
aws cloudformation get-template --stack-name $STACKID --region $REGION | jq '.TemplateBody' > $STACK_TEMPLATE

# Review the original stack template
echo "--------- $STACK_TEMPLATE ---------"
cat $STACK_TEMPLATE
echo "------------------ End ---------------------"

# Reconfigure viewer protocol policy of all cache behaviors from "allow-all"
# to "redirect-to-https"
sed -i 's/allow-all/redirect-to-https/g' $STACK_TEMPLATE

# For the behavior of "/api/*, reconfigure the following options:
#  - "Allowed HTTP Methods" to all HTTP methods
#  - "Cache Based on Selected Request Headers" from "None" to "All"
#  - "Query String Forwarding and Caching" from "None" to "Forward all, cache based on all"
# Also create a custom error response for the distribution, setting the response page path for
# all 403 errors to /surveys/index.html
#
node ./scripts/update-cf-template.js

# Review the updated stack template
echo "--------- $STACK_TEMPLATE_UPDATED ---------"
cat $STACK_TEMPLATE_UPDATED
echo "------------------ End ---------------------"

# Update stack to adopt the above changes
echo "--------- aws cloudformation update-stack --stack-name $STACKID --region $REGION --template-body file://$STACK_TEMPLATE_UPDATED --capabilities CAPABILITY_NAMED_IAM"
aws cloudformation update-stack --stack-name $STACKID --region $REGION --template-body file://$STACK_TEMPLATE_UPDATED --capabilities CAPABILITY_NAMED_IAM

# TODO(Add stack creation/update status check)
./scripts/cf_stack_check.sh update $STACKID $REGION 600 30
