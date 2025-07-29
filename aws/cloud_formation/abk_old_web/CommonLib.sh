#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
declare -r TRUE=0
declare -r FALSE=1
declare -r NOT_AVAILABLE="NotAvailable"
declare -a PROFILE_ARRAY=("abk-dev"
                          "abk-test"
                          "abk-prod"
                          "ci-dev"
                          "ci-test"
                          "ci-prod")
declare -a REGION_ARRAY=("us-east-1"
                         "us-east-2"
                         "us-west-1"
                         "us-west-2")

STACK_TEMPLATE_FILE="MasterStack.cf.yaml"
STACKS_DIR_SUFFIX="stacks"
WEBSITES_DIR_SUFFIX="websites"
CI_STATE_SUCCESS=0
CI_STATE_FAIL=1
CI_STATE_WAIT=2
DELAY_TIME_IN_SECONDS=5
RETRIES=24


#---------------------------
# exit error codes
#---------------------------
EXIT_CODE_SUCCESS=0
EXIT_CODE_GENERAL_ERROR=1
EXIT_CODE_NOT_BASH_SHELL=2
EXIT_CODE_REQUIRED_TOOL_IS_NOT_INSTALLED=3
EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS=4
EXIT_CODE_NOT_VALID_PARAMETER=5
EXIT_CODE_FILE_DOES_NOT_EXIST=6
EXIT_CODE_FOLDER_NOT_FOUND=7
EXIT_CODE_NOT_SAFE_STACK_STATE=8
EXIT_CODE=$EXIT_CODE_SUCCESS

STACK_STATES=(NO_STACK
              CREATE_IN_PROGRESS
              CREATE_FAILED
              CREATE_COMPLETE
              ROLLBACK_IN_PROGRESS
              ROLLBACK_FAILED
              ROLLBACK_COMPLETE
              DELETE_IN_PROGRESS
              DELETE_FAILED
              DELETE_COMPLETE
              UPDATE_IN_PROGRESS
              UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
              UPDATE_COMPLETE
              UPDATE_ROLLBACK_IN_PROGRESS
              UPDATE_ROLLBACK_FAILED
              UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
              UPDATE_ROLLBACK_COMPLETE
              REVIEW_IN_PROGRESS
              NOT_VALID_STATE)
NUMBER_OF_STATES=${#STACK_STATES[@]}
for (( i = 0; i < $NUMBER_OF_STATES; i++)); do
    name=${STACK_STATES[i]}
    declare -r ${name}=$i
done

ENVIRONMENTS=(dev stage prod)
NUMBER_OF_ENVIRONMENTS=${#ENVIRONMENTS[@]}
for (( i = 0; i < $NUMBER_OF_ENVIRONMENTS; i++)); do
    name=${ENVIRONMENTS[i]}
    declare -r ${name}=$i
done


#---------------------------
# color definitions
#---------------------------
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color


#---------------------------
# functions
#---------------------------
IsParameterHelp ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        echo "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        echo "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

CheckNumberOfParameters ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_EXPECTED_NUMBER_OF_PARAMS=$1
    local LCL_ALL_PARAMS=($@)
    local LCL_PARAMETERS_PASSED_IN=(${LCL_ALL_PARAMS[@]:1:$#})
    if [ $LCL_EXPECTED_NUMBER_OF_PARAMS -ne ${#LCL_PARAMETERS_PASSED_IN[@]} ]; then
        echo "ERROR: invalid number of parameters."
        echo "  expected number:  $LCL_EXPECTED_NUMBER_OF_PARAMS"
        echo "  passed in number: ${#LCL_PARAMETERS_PASSED_IN[@]}"
        echo "  parameters passed in: ${LCL_PARAMETERS_PASSED_IN[@]}"
        echo "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    else
        echo "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    fi
}

GetFullDirectoryNameFor ()
{    
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_PARTIAL_DIR_NAME=$1
    local LCL_DIR_NAME=$2
    # read all directories ending with -stacks
    local LCL_DIRS=($(ls -d *-$LCL_PARTIAL_DIR_NAME))
    # only one directoy for stacks should be avilable
    if [ ${#LCL_DIRS[@]} -ne 1 ]; then
        echo "ERROR: 1 $LCL_PARTIAL_DIR_NAME directory have to be present!"
        echo "  Number of $LCL_PARTIAL_DIR_NAME directories available: ${#LCL_DIRS[@]}"
        echo "  Name of $LCL_PARTIAL_DIR_NAME directories: ${LCL_DIRS[@]}"
        return $EXIT_CODE_FOLDER_NOT_FOUND
    fi
    echo "<- ${FUNCNAME[0]} (${LCL_DIRS[0]})"
    eval $LCL_DIR_NAME=\${LCL_DIRS[0]}
    return $EXIT_CODE_SUCCESS
}

IsPredefinedParameterValid ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local MATCH_FOUND=$FALSE
    local VALID_PARAMETERS=""
    local PARAMETER=$1
    shift
    local PARAMETER_ARRAY=("$@")
    # echo "\$PARAMETER = $PARAMETER"
    for element in "${PARAMETER_ARRAY[@]}";
    do
        if [ $PARAMETER == $element ]; then
            MATCH_FOUND=$TRUE
        fi
        VALID_PARAMETERS="$VALID_PARAMETERS $element,"
        # echo "VALID PARAMS = $element"
    done

    if [ $MATCH_FOUND -eq $TRUE ]; then
        echo "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        echo -e "${RED}ERROR: Invalid parameter:${NC} ${PURPLE}$PARAMETER${NC}"
        echo -e "${RED}Valid Parameters: $VALID_PARAMETERS ${NC}"
        echo "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

GetStackState ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LOCAL_CURRENT_STACK_STATE=$1
    local LOCAL_PROFILE=$2
    local LOCAL_REGION=$3
    local LOCAL_STACK_NAME=$4
    local LOCAL_EXIT_CODE=$EXIT_CODE_SUCCESS
    local LOCAL_DESCRIBE_OUTPUT=$(aws cloudformation describe-stacks --profile $LOCAL_PROFILE --region $LOCAL_REGION --stack-name $LOCAL_STACK_NAME)

    if [[ $LOCAL_DESCRIBE_OUTPUT == "" ]]; then
        eval $LOCAL_CURRENT_STACK_STATE=\${STACK_STATES[$NO_STACK]}
        echo "<- GetStackState ($LOCAL_EXIT_CODE ${STACK_STATES[$NO_STACK]})"
        return $LOCAL_EXIT_CODE
    fi

    local LOCAL_STACK_STATE=$(echo $LOCAL_DESCRIBE_OUTPUT | jq .Stacks[0].StackStatus)
    LOCAL_STACK_STATE=${LOCAL_STACK_STATE//\"}
    eval $LOCAL_CURRENT_STACK_STATE=\$LOCAL_STACK_STATE
    echo "<- ${FUNCNAME[0]} ($LOCAL_EXIT_CODE $LOCAL_STACK_STATE)"
    return $LOCAL_EXIT_CODE
}
export -f GetStackState

DecideCiStateBasedOnStackStatus ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LOCAL_CURRENT_STACK_STATE=$1
    local LOCAL_EXIT_CODE=${CI_STATE[$CI_WAIT]}
    # echo "******* STATE=$LOCAL_CURRENT_STACK_STATE"

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
    echo "<- ${FUNCNAME[0]} (\$LOCAL_EXIT_CODE=$LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}
export -f DecideCiStateBasedOnStackStatus

DecideStackAction ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LOCAL_MODIFY_STACK=$1
    local LOCAL_CURRENT_STACK_STATE=$2
    local LOCAL_EXIT_CODE=$EXIT_CODE_SUCCESS
    local LOCAL_STACK_ACTION=""

    case $LOCAL_CURRENT_STACK_STATE in
        ${STACK_STATES[$NO_STACK]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - Stack safe to create"
            LOCAL_STACK_ACTION="create-stack"
            ;;
        ${STACK_STATES[$CREATE_COMPLETE]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_COMPLETE]}| \
        ${STACK_STATES[$ROLLBACK_COMPLETE]}| \
        ${STACK_STATES[$UPDATE_COMPLETE]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - Stack safe to update"
            LOCAL_STACK_ACTION="update-stack"
            ;;
        ${STACK_STATES[$CREATE_IN_PROGRESS]}| \
        ${STACK_STATES[$CREATE_FAILED]}| \
        ${STACK_STATES[$ROLLBACK_IN_PROGRESS]}| \
        ${STACK_STATES[$ROLLBACK_FAILED]}| \
        ${STACK_STATES[$DELETE_IN_PROGRESS]}| \
        ${STACK_STATES[$DELETE_FAILED]}| \
        ${STACK_STATES[$DELETE_COMPLETE]}| \
        ${STACK_STATES[$UPDATE_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_COMPLETE_CLEANUP_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_IN_PROGRESS]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_FAILED]}| \
        ${STACK_STATES[$UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS]}| \
        ${STACK_STATES[$REVIEW_IN_PROGRESS]}| \
        ${STACK_STATES[$NOT_VALID_STATE]})
            echo "Stack state: ${STACK_STATES[$LOCAL_CURRENT_STACK_STATE]} - Stack NOT safe to create/update"
            LOCAL_STACK_ACTION="do NOT update/create"
            LOCAL_EXIT_CODE=$EXIT_CODE_NOT_SAFE_STACK_STATE
            ;;
        *)
            echo "ERROR: Not known state, exit with error and investigate"
            LOCAL_STACK_ACTION="do NOT update/create"
            LOCAL_EXIT_CODE=$EXIT_CODE_NOT_SAFE_STACK_STATE
            ;;
    esac
    echo "<- ${FUNCNAME[0]} (\$LOCAL_EXIT_CODE=$LOCAL_EXIT_CODE \$LOCAL_STACK_ACTION=$LOCAL_STACK_ACTION)"
    eval $LOCAL_MODIFY_STACK=\$LOCAL_STACK_ACTION
    return $LOCAL_EXIT_CODE
}

ReadJsonVersionFile ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_JSON_FILE_NAME=$1
    local LCL_ABK_VERSION_MAJOR=$2
    local LCL_ABK_VERSION_MINOR=$3
    local LCL_ABK_VERSION_PATCH=$4
    local LCL_ABK_VERSION_MAJOR_VALUE=
    local LCL_ABK_VERSION_MINOR_VALUE=
    local LCL_ABK_VERSION_PATCH_VALUE=
    local LCL_EXIT_CODE=0

    if [ -f "$LCL_JSON_FILE_NAME" ]; then
        local LCL_ABK_VERSION_MAJOR_VALUE=$(cat $LCL_JSON_FILE_NAME | jq --raw-output --arg key "${LCL_ABK_VERSION_MAJOR}" '.[$key]') || return $?
        local LCL_ABK_VERSION_MINOR_VALUE=$(cat $LCL_JSON_FILE_NAME | jq --raw-output --arg key "${LCL_ABK_VERSION_MINOR}" '.[$key]') || return $?
        local LCL_ABK_VERSION_PATCH_VALUE=$(cat $LCL_JSON_FILE_NAME | jq --raw-output --arg key "${LCL_ABK_VERSION_PATCH}" '.[$key]') || return $?
    else
        LCL_EXIT_CODE=1
    fi

    echo "<- ${FUNCNAME[0]} ($LCL_ABK_VERSION_MAJOR_VALUE $LCL_ABK_VERSION_MINOR_VALUE $LCL_ABK_VERSION_PATCH_VALUE)"
    eval $LCL_ABK_VERSION_MAJOR=\$LCL_ABK_VERSION_MAJOR_VALUE
    eval $LCL_ABK_VERSION_MINOR=\$LCL_ABK_VERSION_MINOR_VALUE
    eval $LCL_ABK_VERSION_PATCH=\$LCL_ABK_VERSION_PATCH_VALUE
    return $LCL_EXIT_CODE
}

WaitForStackToComplite ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_PROFILE=$1
    local LCL_REGION=$2
    local LCL_STACK_NAME=$3
    local LCL_CI_STATE_SUCCESS=0
    local LCL_CI_STATE_FAIL=1
    local LCL_CI_STATE_WAIT=2
    local LCL_CURRENT_CI_STATE=$LCL_CI_STATE_WAIT
    local LCL_DELAY_TIME_IN_SECONDS=5
    local LCL_RETRIES=24
    local LCL_CURRENT_STACK_STATE=

    for (( i = 0; i < $LCL_RETRIES && $LCL_CURRENT_CI_STATE >= $LCL_CI_STATE_WAIT; i++)); do
        GetStackState LCL_CURRENT_STACK_STATE $LCL_PROFILE $LCL_REGION $LCL_STACK_NAME
        echo "LCL_CURRENT_STACK_STATE=$LCL_CURRENT_STACK_STATE"
        DecideCiStateBasedOnStackStatus $LCL_CURRENT_STACK_STATE
        LCL_CURRENT_CI_STATE=$?
        echo "\$LCL_CURRENT_CI_STATE[$i]=$LCL_CURRENT_CI_STATE"
        [ "$LCL_CURRENT_CI_STATE" -ge "$LCL_CI_STATE_WAIT" ] && sleep $LCL_DELAY_TIME_IN_SECONDS
    done

    echo "<- ${FUNCNAME[0]} (\$LCL_CURRENT_CI_STATE=$LCL_CURRENT_CI_STATE)"
    return $LCL_CURRENT_CI_STATE
}
export -f WaitForStackToComplite

GetSubDirectoryNames ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_SUB_DIR_ARRAY=$1
    local LCL_DIR_NAME=$2
    local LCL_SUB_DIR_ARRAY_VALUE=
    local LCL_EXIT_CODE=0

    if [ ! -d $LCL_DIR_NAME ]; then
        echo -e "${RED}ERROR:${NC} Directory [${PURPLE}$LCL_DIR_NAME${NC}] does not exist"
        LCL_EXIT_CODE=1
        echo "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
        return $LCL_EXIT_CODE
    fi

    pushd $LCL_DIR_NAME
    LCL_SUB_DIR_ARRAY_VALUE=$(ls -d * | sort)
    popd
    # for SUB_DIR in ${LCL_SUB_DIR_ARRAY_VALUE[@]}; do
    #     echo "SUB_DIR = $SUB_DIR"
    # done

    echo "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE $LCL_SUB_DIR_ARRAY_VALUE)"
    eval $LCL_SUB_DIR_ARRAY=\$LCL_SUB_DIR_ARRAY_VALUE
    return $LCL_EXIT_CODE
}
