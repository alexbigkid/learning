#!/bin/bash

#------------------------------------------------------------------------------
# variables definitions
#------------------------------------------------------------------------------
SEA_SUPPORTED_VERSION_FILE='sea/sea-supported-versions.json'
SEA_COMMON_LIB_FILE='scripts/common-lib.sh'
SEA_REQUIRED_TOOLS=( jq parallel )

EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMS=0
SEA_NODE_PACKAGE_FILE='package.json'


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
    echo -e "$0 - build Single Executable Application inside Kubernetes."
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
BuildSeaBinaries() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_VERSION=$1
    local LCL_EXIT_CODE=0
    local LCL_ARGS=()

    PrintTrace $TRACE_DEBUG "LCL_VERSION              = $LCL_VERSION"
    PrintTrace $TRACE_DEBUG "PWD                      = $PWD"

    mkdir -p docker_image_tmp

    for SEA_OS_TYPE in $(jq -r 'keys[]' "$SEA_SUPPORTED_VERSION_FILE"); do
        for SEA_OS_VERSION in $(jq -r --arg SEA_OS_TYPE "$SEA_OS_TYPE" '.[$SEA_OS_TYPE] | keys[]' "$SEA_SUPPORTED_VERSION_FILE"); do
            for SEA_OS_ARCH in $(jq -r --arg SEA_OS_TYPE "$SEA_OS_TYPE" --arg SEA_OS_VERSION "$SEA_OS_VERSION" '.[$SEA_OS_TYPE][$SEA_OS_VERSION][]' "$SEA_SUPPORTED_VERSION_FILE"); do
                # BuildSeaBinary "$LCL_VERSION" "$SEA_OS_TYPE" "$SEA_OS_VERSION" "$SEA_OS_ARCH" || LCL_EXIT_CODE=$?
                LCL_ARGS+=("BuildSeaBinary $LCL_VERSION $SEA_OS_TYPE $SEA_OS_VERSION $SEA_OS_ARCH")
            done
        done
    done

    parallel --halt now,fail=1 ::: "${LCL_ARGS[@]}"
    rm -Rf docker_image_tmp

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

BuildSeaBinary() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_OS_TYPE=$2
    local LCL_OS_IMAGE_VERSION=$3
    local LCL_OS_IMAGE_ARCH=$4
    local LCL_BIN_ARCH=$LCL_OS_IMAGE_ARCH
    local LCL_NODE_MAJOR='20'
    local LCL_EXIT_CODE=0
    local LCL_DOCKER_TMP_DIR

    [ "$LCL_BIN_ARCH" == "arm64v8" ] && LCL_BIN_ARCH="arm64"
    [ "$LCL_BIN_ARCH" == "arm32v7" ] && LCL_BIN_ARCH="arm"

    PrintTrace $TRACE_DEBUG "LCL_BIN_VERSION        = $LCL_BIN_VERSION"
    PrintTrace $TRACE_DEBUG "LCL_OS_TYPE            = $LCL_OS_TYPE"
    PrintTrace $TRACE_DEBUG "LCL_OS_IMAGE_VERSION   = $LCL_OS_IMAGE_VERSION"
    PrintTrace $TRACE_DEBUG "LCL_OS_IMAGE_ARCH      = $LCL_OS_IMAGE_ARCH"
    PrintTrace $TRACE_DEBUG "LCL_BIN_ARCH           = $LCL_BIN_ARCH"
    PrintTrace $TRACE_DEBUG "LCL_NODE_MAJOR         = $LCL_NODE_MAJOR"

    LCL_DOCKER_TMP_DIR="./docker_image_tmp/${LCL_BIN_VERSION}/${LCL_OS_TYPE}/${LCL_OS_IMAGE_VERSION}/${LCL_OS_IMAGE_ARCH}"

    docker build \
        --tag "aai-agent-binary:${LCL_OS_TYPE}-${LCL_OS_IMAGE_VERSION}-${LCL_OS_IMAGE_ARCH}" \
        --platform "linux/$LCL_BIN_ARCH" \
        --build-arg "OS_IMAGE_VERSION=$LCL_OS_IMAGE_VERSION" \
        --build-arg "OS_IMAGE_ARCH=$LCL_OS_IMAGE_ARCH" \
        --build-arg "NODE_MAJOR=$LCL_NODE_MAJOR" \
        --no-cache \
        --progress plain \
        --file "sea/docker/Dockerfile.$LCL_OS_TYPE" \
        --output "type=local,dest=$LCL_DOCKER_TMP_DIR" \
        .
    LCL_EXIT_CODE=$?

    if [ $LCL_EXIT_CODE -eq 0 ] && [ -f "$LCL_DOCKER_TMP_DIR/workspace/bin/aai-agent" ] ; then
        CheckFileFormat "$LCL_DOCKER_TMP_DIR/workspace/bin/aai-agent"
        mkdir -p "./bin/${LCL_BIN_VERSION}/${LCL_OS_TYPE}/${LCL_OS_IMAGE_VERSION}/${LCL_OS_IMAGE_ARCH}/"
        mv "$LCL_DOCKER_TMP_DIR/workspace/bin/aai-agent" "./bin/${LCL_BIN_VERSION}/${LCL_OS_TYPE}/${LCL_OS_IMAGE_VERSION}/${LCL_OS_IMAGE_ARCH}/"
    fi

    [ -d "$LCL_DOCKER_TMP_DIR" ] && rm -Rf "$LCL_DOCKER_TMP_DIR"

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)\n"
    return $LCL_EXIT_CODE
}
export -f BuildSeaBinary

CheckFileFormat() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_FILE_NAME=$1
    local LCL_EXIT_CODE=0
    local LCL_ARCH_FILE

    if file "$LCL_FILE_NAME" | grep -q 'ELF'; then
        PrintTrace $TRACE_INFO 'File is an ELF executable'
        LCL_ARCH_FILE=$(file "$LCL_FILE_NAME")
        if [[ "$LCL_ARCH_FILE" == *"ARM"* ]]; then
            PrintTrace $TRACE_INFO "Success creating aai-agent for arch: ${GRN}ARM64"
        elif [[ "$LCL_ARCH_FILE" == *"x86-64"* ]]; then
            PrintTrace $TRACE_INFO "Success creating aai-agent for arch: ${GRN}AMD64"
        else
            PrintTrace $TRACE_CRITICAL "The binary is of an unknown architecture."
        fi
    else
        PrintTrace $TRACE_ERROR "File is an NOT ELF executable"
    fi

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)\n"
    return $LCL_EXIT_CODE
}
export -f CheckFileFormat

CreateTarZipFile() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_TAR_FILE="bin/aai-agent-${LCL_BIN_VERSION}.tar.gz"
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Before tar pack"
    find bin -type f -exec ls -lh {} \;

    PrintTrace $TRACE_INFO "Packing tar file: $LCL_TAR_FILE"
    [ -d "bin/${LCL_BIN_VERSION}" ] && tar -czvf "$LCL_TAR_FILE" "bin/${LCL_BIN_VERSION}" && rm -r "bin/${LCL_BIN_VERSION}"

    PrintTrace $TRACE_INFO "After tar pack"
    find bin -type f -exec ls -lh {} \;

    # check whether we got the tar file
    [ -f "$LCL_TAR_FILE" ] || LCL_EXIT_CODE=1

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

BuildSeaBinaries "$AAI_VERSIONING" || help $? "${RED}ERROR:${NC} BuildSeaBinaries failed"

CreateTarZipFile "$AAI_VERSIONING" || help $? "${RED}ERROR:${NC} CreateTarZipFile failed"

exit $EXIT_CODE
