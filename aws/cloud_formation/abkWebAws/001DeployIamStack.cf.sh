#!/bin/bash

EXPECTED_NUMBER_OF_PARAMETERS=2
ABK_COMMON_LIB_FILE="./CommonLib.sh"
ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE="WebsitesIam.cf.yaml"
ABK_ADMIN_PROFILE="abk"

PrintUsageAndExitWithCode ()
{
    echo ""
    echo "$0 will create the master stack for Luxor."
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMETERS parameters."
    echo "Usage: $0 <profile> <region>"
    echo "  <profile>:          - profile name, could be:  abk-dev,  ci-dev,"
    echo "                                                 abk-test, ci-test"
    echo "                                                 abk-prod, ci-prod"
    echo "  <region>:           - region to deploy to:     us-east-1, us-east-2, us-west-1, us-west-2"
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
STACK_PREFIX_ALL_LOWERCASE=${STACKS_DIR%-*}
STACK_PREFIX_ALL_LOWERCASE=$(tr '[:upper:]' '[:lower:]' <<< $STACK_PREFIX_ALL_LOWERCASE)
STACK_PREFIX=$(tr '[:lower:]' '[:upper:]' <<< ${STACK_PREFIX_ALL_LOWERCASE:0:1})${STACK_PREFIX_ALL_LOWERCASE:1}
TEMPLATE_NAME_WITHOUT_SUFFIX=${ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE%%.*}
STACK_NAME=$STACK_PREFIX${TEMPLATE_NAME_WITHOUT_SUFFIX}
# TEMPLATE_NAME_SUFFIX=${ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE#*.}
MASTER_STACK_NAME=$STACK_PREFIX${STACK_TEMPLATE_FILE%%.*}
DOMAIN_NAME=${WEBSITES_DIR%-*}
echo "PROFILE                                   =   $PROFILE"
echo "REGION                                    =   $REGION"
echo "STACKS_DIR                                =   $STACKS_DIR"
echo "ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE =   $ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE"
echo "STACK_PREFIX                              =   $STACK_PREFIX"
echo "STACK_PREFIX_ALL_LOWERCASE                =   $STACK_PREFIX_ALL_LOWERCASE"
echo "TEMPLATE_NAME_WITHOUT_SUFFIX              =   $TEMPLATE_NAME_WITHOUT_SUFFIX"
echo "STACK_NAME                                =   $STACK_NAME"
# echo "TEMPLATE_NAME_SUFFIX                      =   $TEMPLATE_NAME_SUFFIX"
echo "DOMAIN_NAME                               =   $DOMAIN_NAME"

MODIFY_STACK=$FALSE
GetStackState CURRENT_STACK_STATE $ABK_ADMIN_PROFILE $REGION $STACK_NAME-$ENVIRONMENT
echo "CURRENT_STACK_STATE=$CURRENT_STACK_STATE"
DecideStackAction MODIFY_STACK $CURRENT_STACK_STATE || exit $?
echo "MODIFY_STACK=$MODIFY_STACK"

echo "aws cloudformation $MODIFY_STACK \
--profile $ABK_ADMIN_PROFILE \
--region $REGION \
--stack-name $STACK_NAME-$ENVIRONMENT \
--template-body file://$STACKS_DIR/$ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
ParameterKey=Prefix,ParameterValue=$STACK_PREFIX_ALL_LOWERCASE \
ParameterKey=UserName,ParameterValue=$PROFILE \
ParameterKey=MasterStackName,ParameterValue=$MASTER_STACK_NAME \
ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME"
aws cloudformation $MODIFY_STACK \
--profile $ABK_ADMIN_PROFILE \
--region $REGION \
--stack-name $STACK_NAME-$ENVIRONMENT \
--template-body file://$STACKS_DIR/$ABK_WEBSITES_IAM_USER_GROUP_POLICIES_FILE \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
ParameterKey=Prefix,ParameterValue=$STACK_PREFIX_ALL_LOWERCASE \
ParameterKey=UserName,ParameterValue=$PROFILE \
ParameterKey=MasterStackName,ParameterValue=$MASTER_STACK_NAME \
ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME

WaitForStackToComplite $ABK_ADMIN_PROFILE $REGION $STACK_NAME-$ENVIRONMENT
EXIT_CODE=$?

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
