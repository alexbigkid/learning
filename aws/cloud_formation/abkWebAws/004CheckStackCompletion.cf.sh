#!/bin/bash

EXPECTED_NUMBER_OF_PARAMETERS=2
ABK_COMMON_LIB_FILE="./CommonLib.sh"
CI_STATE_SUCCESS=0
CI_STATE_FAIL=1
CI_STATE_WAIT=2
DELAY_TIME_IN_SECONDS=5
RETRIES=24


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

DecideCiStateBasedOnStackStatus ()
{
    echo "-> DecideCiStateBasedOnStackStatus ($@)"
    local LOCAL_CURRENT_STACK_STATE=$1
    local LOCAL_EXIT_CODE=${CI_STATE[$CI_WAIT]}

    case $LOCAL_CURRENT_STACK_STATE in
        ${STACK_STATES[$CREATE_COMPLETE]}| \
        ${STACK_STATES[$UPDATE_COMPLETE]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - CI_STATE_SUCCESS"
            LOCAL_EXIT_CODE=$CI_STATE_SUCCESS
            ;;
        ${STACK_STATES[$NO_STACK]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_COMPLETE]}| \
        ${STACK_STATES[$ROLLBACK_COMPLETE]}| \
        ${STACK_STATES[$DELETE_COMPLETE]}| \
        ${STACK_STATES[$CREATE_FAILED]}| \
        ${STACK_STATES[$ROLLBACK_FAILED]}| \
        ${STACK_STATES[$DELETE_FAILED]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_FAILED]}| \
        ${STACK_STATES[$NOT_VALID_STATE]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - CI_STATE_FAIL"
            LOCAL_EXIT_CODE=$CI_STATE_FAIL
            ;;
        ${STACK_STATES[$CREATE_IN_PROGRESS]}| \
        ${STACK_STATES[$ROLLBACK_IN_PROGRESS]}| \
        ${STACK_STATES[$DELETE_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_COMPLETE_CLEANUP_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS]}| \
        ${STACK_STATES[$REVIEW_IN_PROGRESS]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - CI_STATE_WAIT"
            LOCAL_EXIT_CODE=$CI_STATE_WAIT
            ;;
        *)
            echo "ERROR: Not known state, exit with error and investigate"
            LOCAL_EXIT_CODE=$CI_STATE_FAIL
            ;;
    esac
    echo "<- DecideCiStateBasedOnStackStatus (\$LOCAL_EXIT_CODE=$LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
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

PROFILE=$1
REGION=$2
STACK_PREFIX_ALL_LOWERCASE=${STACKS_DIR%-*}
STACK_PREFIX_ALL_LOWERCASE=$(tr '[:upper:]' '[:lower:]' <<< $STACK_PREFIX_ALL_LOWERCASE)
STACK_PREFIX=$(tr '[:lower:]' '[:upper:]' <<< ${STACK_PREFIX_ALL_LOWERCASE:0:1})${STACK_PREFIX_ALL_LOWERCASE:1}
STACK_NAME=$STACK_PREFIX${STACK_TEMPLATE_FILE%%.*}
echo "PROFILE=$PROFILE"
echo "REGION=$REGION"
echo "STACKS_DIR=$STACKS_DIR"
echo "STACK_TEMPLATE_FILE=$STACK_TEMPLATE_FILE"
echo "STACK_PREFIX=$STACK_PREFIX"
echo "STACK_PREFIX_ALL_LOWERCASE=$STACK_PREFIX_ALL_LOWERCASE"
echo "STACK_NAME=$STACK_NAME"

CURRENT_CI_STATE=$CI_STATE_WAIT
for (( i = 0; i < $RETRIES && $CURRENT_CI_STATE >= $CI_STATE_WAIT; i++)); do
    GetStackState CURRENT_STACK_STATE $PROFILE $REGION $STACK_NAME
    echo "CURRENT_STACK_STATE=$CURRENT_STACK_STATE"
    DecideCiStateBasedOnStackStatus $CURRENT_STACK_STATE
    CURRENT_CI_STATE=$?
    echo "\$CURRENT_CI_STATE[$i]=$CURRENT_CI_STATE"
    [ "$CURRENT_CI_STATE" -ge "$CI_STATE_WAIT" ] && sleep $DELAY_TIME_IN_SECONDS
done

EXIT_CODE=$CURRENT_CI_STATE

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
