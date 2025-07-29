#!/bin/bash

EXPECTED_NUMBER_OF_PARAMETERS=2
ABK_COMMON_LIB_FILE="./CommonLib.sh"
WEBSITES_DIR=""

PrintUsageAndExitWithCode ()
{
    echo ""
    echo "$0 will create the master stack for Luxor."
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMETERS parameters."
    echo "Usage: $0 <profile> <region>"
    echo "  <profile>:          - profile name, could be:  abk-dev,  ci-dev,"
    echo "                                                 abk-test, ci-test"
    echo "                                                 abk-prod, ci-prod"
    echo "  <region>:           - region to deploy to:     us-east-1, us-east-2, us-wets-1, us-west-2"
    echo ""
    echo "  $0 --help           - display this info"
    exit $1
}


# ----------
# main
# ----------
echo ""
echo "-> $0 ($@)"

# include common library, fail if does not exist
if [ -f $ABK_COMMON_LIB_FILE ]; then
    source $ABK_COMMON_LIB_FILE
else
    echo "ERROR: $ABK_COMMON_LIB_FILE does not exist in the local directory."
    echo "  $ABK_COMMON_LIB_FILE contains common definitions and functions"
    exit 1
fi

IsParameterHelp $# $1 && PrintUsageAndExitWithCode $EXIT_CODE_SUCCESS
CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $@ || PrintUsageAndExitWithCode $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS
GetFullDirectoryNameFor $STACKS_DIR_SUFFIX STACKS_DIR || PrintUsageAndExitWithCode $EXIT_CODE_FOLDER_NOT_FOUND
# echo "STACKS_DIR = $STACKS_DIR"

GetFullDirectoryNameFor $WEBSITES_DIR_SUFFIX WEBSITES_DIR || PrintUsageAndExitWithCode $EXIT_CODE_FOLDER_NOT_FOUND
# echo "WEBSITES_DIR = $WEBSITES_DIR"



PROFILE=$1
REGION=$2
ENVIRONMENT=${PROFILE##*-}
S3_STACKS_DIR="$STACKS_DIR-$ENVIRONMENT"
STACK_TEMPLATE_FILE="$STACKS_DIR/$STACK_TEMPLATE_FILE"
STACK_PREFIX_ALL_LOWERCASE=${STACKS_DIR%-*}
STACK_PREFIX_ALL_LOWERCASE=$(tr '[:upper:]' '[:lower:]' <<< $STACK_PREFIX_ALL_LOWERCASE)
STACK_PREFIX=$(tr '[:lower:]' '[:upper:]' <<< ${STACK_PREFIX_ALL_LOWERCASE:0:1})${STACK_PREFIX_ALL_LOWERCASE:1}
STACK_NAME=${STACK_TEMPLATE_FILE##*/}
STACK_NAME=$STACK_PREFIX${STACK_NAME%%.*}
DOMAIN_NAME=${WEBSITES_DIR%-*}
echo "PROFILE                                   =   $PROFILE"
echo "REGION                                    =   $REGION"
echo "ENVIRONMENT                               =   $ENVIRONMENT"
echo "STACKS_DIR                                =   $STACKS_DIR"
echo "S3_STACKS_DIR                             =   $S3_STACKS_DIR"
echo "STACK_TEMPLATE_FILE                       =   $STACK_TEMPLATE_FILE"
echo "STACK_PREFIX                              =   $STACK_PREFIX"
echo "STACK_PREFIX_ALL_LOWERCASE                =   $STACK_PREFIX_ALL_LOWERCASE"
echo "STACK_NAME                                =   $STACK_NAME"
echo "DOMAIN_NAME                               =   $DOMAIN_NAME"

# get directories (subdomain names from the website directory)
GetSubDirectoryNames SUB_DIR_ARRAY $WEBSITES_DIR || exit $?


for SUB_DOMAIN in ${SUB_DIR_ARRAY[@]}; do

# modify or create stack
MODIFY_STACK=$FALSE
GetStackState CURRENT_STACK_STATE $PROFILE $REGION $STACK_NAME-$SUB_DOMAIN-$ENVIRONMENT
echo "CURRENT_STACK_STATE=$CURRENT_STACK_STATE"
DecideStackAction MODIFY_STACK $CURRENT_STACK_STATE || exit $?
echo "MODIFY_STACK=$MODIFY_STACK"

echo "aws cloudformation $MODIFY_STACK \
--profile $PROFILE \
--region $REGION \
--stack-name $STACK_NAME-$SUB_DOMAIN-$ENVIRONMENT \
--template-body file://$STACK_TEMPLATE_FILE \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Prefix,ParameterValue=$STACK_PREFIX_ALL_LOWERCASE \
ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME \
ParameterKey=SubDomainName,ParameterValue=$SUB_DOMAIN"
aws cloudformation $MODIFY_STACK \
--profile $PROFILE \
--region $REGION \
--stack-name $STACK_NAME-$SUB_DOMAIN-$ENVIRONMENT \
--template-body file://$STACK_TEMPLATE_FILE \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Prefix,ParameterValue=$STACK_PREFIX_ALL_LOWERCASE \
ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME \
ParameterKey=SubDomainName,ParameterValue=$SUB_DOMAIN
EXIT_CODE=$?
echo ""
done


for SUB_DOMAIN in ${SUB_DIR_ARRAY[@]}; do
echo ""
echo "Waiting for following stacks to complete: $STACK_NAME-$SUB_DOMAIN-$ENVIRONMENT ..."
WaitForStackToComplite $PROFILE $REGION $STACK_NAME-$SUB_DOMAIN-$ENVIRONMENT
done
# parallel WaitForStackToComplite $PROFILE $REGION ::: ${STACKS_ARRAY[@]}

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
