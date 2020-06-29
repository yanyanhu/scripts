#!/bin/bash
#
# This is a script to deploy lambda functions and cloudfront
# distribution
#


# Set region to us-east-1 since it is the only region support
# lambda with cloudfront event.
export REGION=us-east-1
export STACK_TEMPLATE=stack-template.yml
export STACK_TEMPLATE_TO_UPDATE=stack-template-to-update.yml


# Deploy lambda functions and cloudfront distributions using serverless cli.
# This will generate a cloudformation stack which will be updated further.
echo "--------- serverless deploy --stage test --verbose --region $REGION --output json | tee deploy.log"
serverless deploy --stage test --verbose --region $REGION --output json | tee deploy.log

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

# For the behavior of "/api/*, reconfigure "Allowed HTTP Methods"
# to all HTTP methods if it has not been configured
if grep -q "AllowedMethods" $STACK_TEMPLATE
then
   echo "Allowed HTTP Methods has been configured."
   cat $STACK_TEMPLATE > $STACK_TEMPLATE_TO_UPDATE
else
   echo "Allowed HTTP Methods has not been configured. Set it to the full list of all HTTP methods."
   sed '/.*PathPattern.*\/api\/\*/i \              "AllowedMethods": ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"],' $STACK_TEMPLATE > $STACK_TEMPLATE_TO_UPDATE
fi

# For the behavior of "/api/*, reconfigure "Cache Based on Selected Request
# Headers" from "None" to "All" and reconfigure "Query String Forwarding and
# Caching" from "None" to "Forward all, cache based on all"
#
# Didn't find related configurations in cloudformation template for the above
# update. Need further exploration.
# Refer to: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-cachebehavior.html

# Review the updated stack template
echo "--------- $STACK_TEMPLATE_TO_UPDATE ---------"
cat $STACK_TEMPLATE_TO_UPDATE
echo "------------------ End ---------------------"

# Update stack to adopt the above changes
echo "--------- aws cloudformation update-stack --stack-name $STACKID --region $REGION --template-body file://$STACK_TEMPLATE_TO_UPDATE --capabilities CAPABILITY_NAMED_IAM"
aws cloudformation update-stack --stack-name $STACKID --region $REGION --template-body file://$STACK_TEMPLATE_TO_UPDATE --capabilities CAPABILITY_NAMED_IAM

# TODO(Add stack creation/update status check)
./scripts/cf_stack_check.sh update $STACKID $REGION 600 30
