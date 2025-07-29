#!/bin/bash

EXPECTED_NUMBER_OF_PARAMETERS=2
ABK_COMMON_LIB_FILE="./CommonLib.sh"
STACKS_DIR=""
STACKS_DIR_SUFFIX="stacks"
S3_STACKS_DIR=""
EXIT_CODE=0


PrintUsageAndExitWithCode ()
{
    echo ""
    echo "$0 will sync a local directory with an S3 bucket."
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

IsParameterHelp ()
{
    echo "-> IsParameterHelp ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        echo "<- IsParameterHelp (TRUE)"
        return $TRUE
    else
        echo "<- IsParameterHelp (FALSE)"
        return $FALSE
    fi
}

CreateS3BucketIfNotExist ()
{
    echo "-> CreateS3BucketIfnotExist ($@)"
    local LOCAL_PROFILE=$1
    local LOCAL_REGION=$2
    local LOCAL_STACK_DIR=$3
    local LOCAL_ENVIRONMENT=${LOCAL_PROFILE##*-}
    local EXIT_CODE=0
    echo "checking s3 bucket: $LOCAL_STACK_DIR"
    aws s3api head-bucket --bucket $LOCAL_STACK_DIR --profile $LOCAL_PROFILE --region $LOCAL_REGION
    DIR_EXISTS=$?
    if [ $DIR_EXISTS -ne $TRUE ]; then
        echo "creating s3 bucket: $LOCAL_STACK_DIR"
        aws s3 mb s3://$LOCAL_STACK_DIR --profile $LOCAL_PROFILE --region $LOCAL_REGION
        EXIT_CODE=$?
    else
        echo "s3 bucket: $LOCAL_STACK_DIR already exist"
    fi

    echo "<- CreateS3BucketIfnotExist ($EXIT_CODE)"
    return $EXIT_CODE
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
echo "STACKS_DIR = $STACKS_DIR"

PROFILE=$1
REGION=$2
ENVIRONMENT=${PROFILE##*-}
# S3_STACKS_DIR="$STACKS_DIR-$ENVIRONMENT"
S3_STACKS_DIR="$STACKS_DIR"

echo "\$ENVIRONMENT = $ENVIRONMENT"
echo "\$STACKS_DIR = $STACKS_DIR"
echo "\$S3_STACKS_DIR = $S3_STACKS_DIR"

CreateS3BucketIfNotExist $PROFILE $REGION ${STACKS_DIR[0]}

# List local stack directory, S3 bucket need to sync to.
echo ""
echo "Contents of local directory $STACKS_DIR:"
echo "-------------------------------------------"
ls -la $STACKS_DIR
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Exit code from aws s3 ls operation:  $EXIT_CODE"
    exit $EXIT_CODE
fi

# List initial contents of S3 bucket
echo ""
echo "Contents of $S3_STACKS_DIR before sync:"
echo "-------------------------------------------"
aws s3 ls s3://$S3_STACKS_DIR --profile $PROFILE
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Exit code from aws s3 ls operation:  $EXIT_CODE"
    exit $EXIT_CODE
fi

# Sync local files with aws exclude all hidden files and also delete files which do not contain in local dir
# when syncing compare only by files size since we don't want to sync when the time stamp is different
echo ""
echo "Syncing S3 Bucket: $S3_STACKS_DIR"
echo "-------------------------------------------"
OUTPUT=$(aws s3 sync --delete --exclude ".*" ./$STACKS_DIR s3://$S3_STACKS_DIR --profile $PROFILE)
EXIT_CODE=$?
echo $OUTPUT
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Exit code from aws s3 sync operation:  $EXIT_CODE"
    exit $EXIT_CODE
fi

echo ""
echo "Contents of $S3_STACKS_DIR after sync:"
echo "-------------------------------------------"
aws s3 ls s3://$S3_STACKS_DIR --profile $PROFILE
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Exit code from aws s3 ls operation:  $EXIT_CODE"
    exit $EXIT_CODE
fi

echo ""
if [ "$OUTPUT" == "" ]; then
    echo "No updates to S3 buckets."
fi

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
