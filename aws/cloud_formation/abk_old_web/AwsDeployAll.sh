#!/bin/bash

EXPECTED_NUMBER_OF_PARAMS=2
ABK_COMMON_LIB_FILE="./CommonLib.sh"

EXIT_CODE=0
PrintUsageAndExitWithCode ()
{
    echo ""
    echo "$0 run all scripts to create an infrastructure for ABK Web Aws project"
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMS parameters."
    echo "Usage: $0 <profile> <region>"
    echo "  <profile>:          - profile name, could be:  abk-dev,   ci-dev,"
    echo "                                                 abk-test,  ci-test"
    echo "                                                 abk-prod,  ci-prod"
    echo "  <region>:           - region to deploy to:     us-east-1, us-east-2, us-west-2"
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
CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMS $@ || PrintUsageAndExitWithCode $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS

PROFILE=$1
REGION=$2

# validate profile
IsPredefinedParameterValid $PROFILE "${PROFILE_ARRAY[@]}" || PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER

# validate region
IsPredefinedParameterValid $REGION "${REGION_ARRAY[@]}" || PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER

#execute sub scripts
SCRIPT_FILES=$(ls [0-9][0-9][0-9]*.{cf,sls}.sh | sort)
for SCRIPT in ${SCRIPT_FILES[@]}; do
    echo ""
    echo "about to execute $SCRIPT "
    ./$SCRIPT $PROFILE $REGION || exit $?
done

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
