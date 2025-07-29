#!/bin/bash

#------------------------------------------------------------------------------
# variables definitions
#------------------------------------------------------------------------------
SEA_COMMON_LIB_FILE="scripts/common-lib.sh"
SEA_REQUIRED_TOOLS=( tree jq )
SEA_S3_RELEASES_BUCKET="aai-releases-dev"
SEA_S3_AAI_AGENT_DIR="aai-agent"

EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMS=0
SEA_NODE_PACKAGE_FILE="package.json"


#------------------------------------------------------------------------------
# Trace configuration
#------------------------------------------------------------------------------
TRACE_NONE=0
TRACE_ERROR=1
TRACE_CRITICAL=2
TRACE_FUNCTION=3
TRACE_INFO=4
TRACE_DEBUG=5
TRACE_ALL=6
TRACE_LEVEL=$TRACE_ALL

#------------------------------------------------------------------------------
# exit error codes
#------------------------------------------------------------------------------
EXIT_CODE_SUCCESS=0
EXIT_CODE_GENERAL_ERROR=1
EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS=2


#------------------------------------------------------------------------------
# helper functions
#------------------------------------------------------------------------------
help() {
    echo
    echo -e "$0 - extracts bin/aai-agent-xx.xx.xx.tar.gz to bin directory and deploys to AWS S3"
    echo -e "$0 must be called with $EXPECTED_NUMBER_OF_PARAMS parameters."
    echo
    echo -e "$2"
    echo
    echo -e "  $0 --help           - display this info"
    # shellcheck disable=SC2086
    exit $1
}


PrintTrace() {
    local LCL_TRACE_LEVEL=$1
    shift
    local LCL_PRINT_STRING=("$@")
    if [[ $TRACE_LEVEL -ge $LCL_TRACE_LEVEL ]]; then
        case $LCL_TRACE_LEVEL in
            "$TRACE_CRITICAL")
                echo -e "${RED}[CRITICAL] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_ERROR")
                echo -e "${RED}[ERROR] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_FUNCTION")
                echo -e "${CYN}${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_INFO")
                echo -e "\n\n${YLW}[INFO] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_DEBUG")
                echo -e "${BLU}[DEBUG] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_NONE")
                echo ;;
            *)
                echo -e "${LCL_PRINT_STRING[@]}" ;;
        esac
    fi
}


#------------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------------
ExtractTarZipFile() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_TAR_FILE="bin/aai-agent-${LCL_BIN_VERSION}.tar.gz"
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Before tar unpack"
    find bin

    PrintTrace $TRACE_INFO "Unpacking tar file: $LCL_TAR_FILE"
    [ -f "$LCL_TAR_FILE" ] && tar -xzvf "$LCL_TAR_FILE" && rm "$LCL_TAR_FILE"

    PrintTrace $TRACE_INFO "After tar unpack"
    tree bin

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


SyncBinariesToS3() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Before syncing content of: s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION"
    aws s3 ls s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION/ --recursive

    PrintTrace $TRACE_INFO "Syncing binaries to: s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION"
    # aws s3 sync "bin/$LCL_BIN_VERSION" "s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION" --dryrun
    aws s3 sync "bin/$LCL_BIN_VERSION" "s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION"
    LCL_EXIT_CODE=$?

    PrintTrace $TRACE_INFO "After syncing content of: s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION"
    aws s3 ls s3://$SEA_S3_RELEASES_BUCKET/$SEA_S3_AAI_AGENT_DIR/$LCL_BIN_VERSION/ --recursive

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


CleanBinDirectory() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Before cleaning bin directory"
    find bin

    PrintTrace $TRACE_INFO "Cleaning bin directory"
    rm -Rf "bin/$LCL_BIN_VERSION"

    PrintTrace $TRACE_INFO "After cleaning bin directory"
    find bin

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
if [ -f "$SEA_COMMON_LIB_FILE" ]; then
    # shellcheck disable=SC1090
    source "$SEA_COMMON_LIB_FILE"
else
    help 1 "Cannot find common library: $SEA_COMMON_LIB_FILE"
fi

common_is_parameter_help $# "$1" && help $EXIT_CODE_SUCCESS
# shellcheck disable=SC2068
common_check_number_of_parameters $EXPECTED_NUMBER_OF_PARAMS $@ || help $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS
common_install_required_tools "${SEA_REQUIRED_TOOLS[@]}"
common_read_version AAI_VERSIONING "$SEA_NODE_PACKAGE_FILE"
[ "$AAI_VERSIONING" == "" ] && PrintTrace $TRACE_ERROR "${RED}ERROR:${NC} ${PRL}Versioning is not defined${NC}" && help $EXIT_CODE_GENERAL_ERROR

ExtractTarZipFile "$AAI_VERSIONING" || help $? "${RED}ERROR:${NC} ExtractTarZipFile failed"
SyncBinariesToS3 "$AAI_VERSIONING" || help $? "${RED}ERROR:${NC} SyncBinariesToS3 failed"
CleanBinDirectory "$AAI_VERSIONING" || help $? "${RED}ERROR:${NC} CleanBinDirectory failed"

exit $EXIT_CODE
