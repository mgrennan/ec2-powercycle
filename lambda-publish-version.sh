#!/bin/bash

# Script creates a new version of the $LATEST Lambda job
# Lambda alias can then be linked to specific version 
# More information: http://docs.aws.amazon.com/cli/latest/reference/lambda/publish-version.html
#
# USAGE:
# ./lambda-publish-version.sh <function_name>

source functions.sh

function publishVersion() {
    aws lambda publish-version  --function-name ${SETTINGS[AWS_LAMBDA_FUNCTION]}
}

if [[ ! -z "$1" ]]; then
    AWS_LAMBDA_FUNCTION="$1"
fi

processCredentials

echo -e "\e[31mExporting settings\e[0m"
exportSettings
echo -e "\e[31mVerifying Lambda function\e[0m"
verifyLambdaFunction && echo -e "\e[31mLambda function access OK\e[0m" || errorAndExit "Failed to access function ${SETTINGS[AWS_LAMBDA_FUNCTION]}" 1
publishVersion && echo -e "\e[31mNew version created successfully\e[0m" || errorAndExit "Failed to create new version for ${SETTINGS[AWS_LAMBDA_FUNCTION]}" 1