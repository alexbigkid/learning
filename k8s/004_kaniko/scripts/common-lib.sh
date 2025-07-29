#!/bin/bash

#------------------------------------------------------------------------------
# variables definitions
#------------------------------------------------------------------------------
declare -r TRUE=0
declare -r FALSE=1

export TRACE_NONE=0
export TRACE_CRITICAL=1
export TRACE_ERROR=2
export TRACE_FUNCTION=3
export TRACE_INFO=4
export TRACE_DEBUG=5
export TRACE_ALL=6
export TRACE_LEVEL=$TRACE_DEBUG

if [ -z "$ALWAYSAI_DISABLE_BASH_COLORS" ]; then
    export BLK='\033[0;30m'
    export RED='\033[0;31m'
    export GRN='\033[0;32m'
    export ORG='\033[0;33m'
    export BLU='\033[0;34m'
    export PRL='\033[0;35m'
    export CYN='\033[0;36m'
    export LGR='\033[0;37m'
    export DGR='\033[1;30m'
    export LRD='\033[1;31m'
    export LGR='\033[1;32m'
    export YLW='\033[1;33m'
    export LBL='\033[1;34m'
    export LPR='\033[1;35m'
    export LCY='\033[1;36m'
    export WHT='\033[1;37m'
    export NC='\033[0m' # No Color
else
    echo "not using colors: ALWAYSAI_DISABLE_BASH_COLORS is defined: $ALWAYSAI_DISABLE_BASH_COLORS"
    export BLK=
    export RED=
    export GRN=
    export ORG=
    export BLU=
    export PRL=
    export CYN=
    export LGR=
    export DGR=
    export LRD=
    export LGR=
    export YLW=
    export LBL=
    export LPR=
    export LCY=
    export WHT=
    export NC=
fi

#------------------------------------------------------------------------------
# unix type
#------------------------------------------------------------------------------
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*) export AAI_UNIX_TYPE=linux ;;
    Darwin*) export AAI_UNIX_TYPE=mac ;;
    CYGWIN*) export AAI_UNIX_TYPE=cygwin ;;
    MINGW*) export AAI_UNIX_TYPE=mingw ;;
    *) AAI_UNIX_TYPE="UNKNOWN:${unameOut}" ;;
esac


# -----------------------------------------------------------------------------
# help functions
# -----------------------------------------------------------------------------
PrintTrace() {
    local LCL_TRACE_LEVEL=$1
    shift
    local LCL_PRINT_STRING=("$@")
    if [[ $TRACE_LEVEL -ge $LCL_TRACE_LEVEL ]]; then
        case $LCL_TRACE_LEVEL in
            "$TRACE_CRITICAL")
                echo -e "${RED}[CRITICAL] " "${LCL_PRINT_STRING[@]}" "${NC}" ;;
            "$TRACE_ERROR")
                echo -e "${RED}[ERROR] " "${LCL_PRINT_STRING[@]}" "${NC}" ;;
            "$TRACE_FUNCTION")
                echo -e "${CYN}" "${LCL_PRINT_STRING[@]}" "${NC}" ;;
            "$TRACE_INFO")
                echo -e "\n${YLW}[INFO] " "${LCL_PRINT_STRING[@]}" "${NC}" ;;
            "$TRACE_DEBUG")
                echo -e "${BLU}[DEBUG] " "${LCL_PRINT_STRING[@]}" "${NC}" ;;
            "$TRACE_NONE")
                echo ;;
            *)
                echo -e "${LCL_PRINT_STRING[@]}" ;;
        esac
    fi
}


# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
common_is_parameter_help()
{
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

common_check_number_of_parameters()
{
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_EXPECTED_NUMBER_OF_PARAMS=$1
    local LCL_GIVEN_NUMBER_OF_PARAMS=$2
    if [[ $LCL_EXPECTED_NUMBER_OF_PARAMS -ne $LCL_GIVEN_NUMBER_OF_PARAMS ]]; then
        PrintTrace $TRACE_ERROR "ERROR: invalid number of parameters."
        PrintTrace $TRACE_ERROR "  expected number:  $LCL_EXPECTED_NUMBER_OF_PARAMS"
        PrintTrace $TRACE_ERROR "  passed in number: $LCL_GIVEN_NUMBER_OF_PARAMS"
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    else
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    fi
}

common_is_parameter_valid()
{
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local MATCH_FOUND=$FALSE
    local VALID_PARAMETERS=""
    local PARAMETER=$1
    shift
    local PARAMETER_ARRAY=("$@")
    PrintTrace $TRACE_DEBUG "PARAMETER = $PARAMETER"

    for element in "${PARAMETER_ARRAY[@]}";
    do
        if [ "$PARAMETER" == "$element" ]; then
            MATCH_FOUND=$TRUE
        fi
        VALID_PARAMETERS="$VALID_PARAMETERS $element,"
        PrintTrace $TRACE_DEBUG "VALID PARAMS = $element"
    done

    if [ $MATCH_FOUND -eq $TRUE ]; then
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        PrintTrace $TRACE_ERROR "${RED}ERROR: Invalid parameter:${NC} ${PRL}$PARAMETER${NC}"
        PrintTrace $TRACE_ERROR "${RED}Valid Parameters: $VALID_PARAMETERS ${NC}"
        PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

common_check_version_requirement() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_CURRENT_VERSION=$1 # please pass the version in format major.minor.patch
    local LCL_REQUIRED_VERSION=$2  # please pass the version in format major.minor.patch
    local LCL_EXIT_CODE=$FALSE

    # extract major, minor, patch into arrays
    # shellcheck disable=SC2206
    local LCL_CURRENT_ARRAY=( ${LCL_CURRENT_VERSION//./ } )
    # shellcheck disable=SC2206
    local LCL_REQUIRED_ARRAY=( ${LCL_REQUIRED_VERSION//./ } )

    # validate required version numbers
    if [ "${LCL_CURRENT_ARRAY[0]}" -gt "${LCL_REQUIRED_ARRAY[0]}" ]; then
        LCL_EXIT_CODE=$TRUE
    elif [ "${LCL_CURRENT_ARRAY[0]}" -eq "${LCL_REQUIRED_ARRAY[0]}" ] && \
        [ "${LCL_CURRENT_ARRAY[1]}" -gt "${LCL_REQUIRED_ARRAY[1]}" ]; then
        LCL_EXIT_CODE=$TRUE
    elif [ "${LCL_CURRENT_ARRAY[0]}" -eq "${LCL_REQUIRED_ARRAY[0]}" ] && \
        [ "${LCL_CURRENT_ARRAY[1]}" -eq "${LCL_REQUIRED_ARRAY[1]}" ] && \
        [ "${LCL_CURRENT_ARRAY[2]}" -ge "${LCL_REQUIRED_ARRAY[2]}" ]; then
        LCL_EXIT_CODE=$TRUE
    fi

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

common_read_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_RETURN_VAR=$1
    local LCL_FILE_TO_READ=$2
    local LCL_EXIT_CODE=0
    local LCL_PACKAGE_VERSION=

    if [ -f "$LCL_FILE_TO_READ" ]; then
        LCL_PACKAGE_VERSION=$(jq -r '.version' "$LCL_FILE_TO_READ")
    else
        PrintTrace $TRACE_INFO "File does not exist: $LCL_FILE_TO_READ"
    fi
    PrintTrace $TRACE_DEBUG "LCL_PACKAGE_VERSION = $LCL_PACKAGE_VERSION"
    [ "$LCL_PACKAGE_VERSION" == "" ] && LCL_EXIT_CODE=1

    eval "$LCL_RETURN_VAR"=\$LCL_PACKAGE_VERSION
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE $LCL_PACKAGE_VERSION)"
    return $LCL_EXIT_CODE
}

common_write_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_APP_VERSION=$1
    local LCL_FILE_TO_WRITE=$2
    local LCL_TS_VERSION_STR='export const VERSION'
    local LCL_EXIT_CODE=0
    echo "$LCL_TS_VERSION_STR = $LCL_APP_VERSION;" > "$LCL_FILE_TO_WRITE"
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

common_install_required_tools() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_INSTALL_TOOL=
    local LCL_TOOL=("$@")
    local LCL_AUTO_INSTALL_OPTION=

    if [ "$AAI_UNIX_TYPE" == "mac" ] && [ "$(command -v brew)" != "" ]; then
        LCL_INSTALL_TOOL="brew"
    elif [ "$AAI_UNIX_TYPE" == "linux" ]; then
        if [ -n "$BITBUCKET_BUILD_NUMBER" ]; then
            LCL_INSTALL_TOOL="apt-get"
        else
            LCL_INSTALL_TOOL="sudo apt-get"
        fi
        $LCL_INSTALL_TOOL update
        LCL_AUTO_INSTALL_OPTION="-y"
    else
        PrintTrace "$TRACE_ERROR" "Unsupported OS: $AAI_UNIX_TYPE"
        return 1
    fi

    for TOOL in "${LCL_TOOL[@]}"; do
        PrintTrace $TRACE_DEBUG "Checking tool installation: $TOOL"
        TOOL_PATH=$(command -v "$TOOL")
        if [ -z "$TOOL_PATH" ]; then
            PrintTrace "$TRACE_INFO" "Installing: $TOOL ..."
            $LCL_INSTALL_TOOL install $LCL_AUTO_INSTALL_OPTION "$TOOL" || return $?
        fi
    done

    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} (0)"
    return 0
}
