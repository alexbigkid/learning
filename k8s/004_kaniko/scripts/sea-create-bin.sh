#!/bin/bash

# -----------------------------------------------------------------------------
# settings
# -----------------------------------------------------------------------------
#set -o xtrace
set -o errexit

EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMS=0
AAI_COMMON_LIB_FILE="scripts/common-lib.sh"
AAI_SEA_CONFIG_FILE="sea/sea-config.json"
AAI_SUPPORTED_OS=("linux" "mac")
AAI_REQUIRED_NODE_VERSION="20.11.0"


#------------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------------
help() {
    echo
    echo "$0 creates aai-agent binary"
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMS parameters."
    echo
    echo "  $0 --help           - display this info"
    echo
    if [ "$2" != "" ]; then
        # shellcheck disable=SC2086
        if [ $1 -eq 0 ]; then
            PrintTrace "$TRACE_INFO" "$2"
        else
            PrintTrace "$TRACE_ERROR" "$2"
        fi
    fi
    popd
    # shellcheck disable=SC2086
    exit $1
}

install_required_tools() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ()"
    local LCL_INSTALL_TOOL=
    local LCL_TOOL=(
        jq
    )

    if [ "$AAI_UNIX_TYPE" == "mac" ] && [ "$(command -v brew)" != "" ]; then
        LCL_INSTALL_TOOL="brew"
    elif [ "$AAI_UNIX_TYPE" == "linux" ]; then
        if [ -n "$BITBUCKET_BUILD_NUMBER" ]; then
            LCL_INSTALL_TOOL="apt-get"
        else
            LCL_INSTALL_TOOL="sudo apt-get"
        fi
        $LCL_INSTALL_TOOL update
    else
        PrintTrace "$TRACE_ERROR" "Unsupported OS: $AAI_UNIX_TYPE"
        return 1
    fi

    for TOOL in "${LCL_TOOL[@]}"; do
        TOOL_PATH=$(command -v "$TOOL")
        if [ -z "$TOOL_PATH" ]; then
            PrintTrace "$TRACE_INFO" "Installing: $TOOL ..."
            $LCL_INSTALL_TOOL install -y "$TOOL" || return $?
        fi
    done

    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} (0)"
    return 0
}

create_inject_blob() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_CONFIG_FILE=$1
    node --experimental-sea-config "$LCL_CONFIG_FILE" || return $?
    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
}

create_node_binary() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_BINARY_RETURN=$1
    local LCL_CONFIG_FILE=$2
    local LCL_EXIT_CODE=0
    local LCL_BINARY_NAME=
    local LCL_NODENV_INSTALLED=

    # get the name of the binary from config file
    PrintTrace "$TRACE_DEBUG" "LCL_CONFIG_FILE: $LCL_CONFIG_FILE"
    LCL_BINARY_NAME=$(jq -r '.bin' "$LCL_CONFIG_FILE")
    PrintTrace "$TRACE_DEBUG" "LCL_BINARY_NAME: $LCL_BINARY_NAME"


    # check whether nodenv is installed
    LCL_NODENV_INSTALLED=$(command -v nodenv)
    if [ "$LCL_NODENV_INSTALLED" != "" ]; then
        cp "$(nodenv which node)" "$LCL_BINARY_NAME" || LCL_EXIT_CODE=$?
    else
        cp "$(command -v node)" "$LCL_BINARY_NAME" || LCL_EXIT_CODE=$?
    fi
    eval "$LCL_BINARY_RETURN"=\$LCL_BINARY_NAME
    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE $LCL_BINARY_NAME)"
}

remove_binary_signature() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_BINARY_FILE=$1
    if [ "$AAI_UNIX_TYPE" == "mac" ]; then
        PrintTrace "$TRACE_DEBUG" "LCL_BINARY_FILE = $LCL_BINARY_FILE"
        codesign --remove-signature "$LCL_BINARY_FILE" || return $?
    fi
    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
}

inject_blob_into_binary() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_CONFIG_FILE=$1
    local LCL_BINARY_FILE=$2
    local LCL_EXIT_CODE=0
    local LCL_BLOB_FILE=

    LCL_BLOB_FILE=$(jq -r '.output' "$LCL_CONFIG_FILE")
    PrintTrace "$TRACE_DEBUG" "LCL_CONFIG_FILE: $LCL_CONFIG_FILE"
    PrintTrace "$TRACE_DEBUG" "LCL_BINARY_FILE: $LCL_BINARY_FILE"
    PrintTrace "$TRACE_DEBUG" "LCL_BLOB_FILE:   $LCL_BLOB_FILE"

    PrintTrace "$TRACE_DEBUG" "Checking the binary file"
    file "$LCL_BINARY_FILE"

    if [ "$AAI_UNIX_TYPE" == "mac" ]; then
        PrintTrace "$TRACE_DEBUG" "Mac postject execution ..."
        npx postject "$LCL_BINARY_FILE" NODE_SEA_BLOB "$LCL_BLOB_FILE" \
            --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
            --macho-segment-name NODE_SEA || LCL_EXIT_CODE=$?
    elif [ "$AAI_UNIX_TYPE" == "linux" ]; then
        PrintTrace "$TRACE_DEBUG" "Linux postject execution ..."
        ls -la dist/
        npx postject "$LCL_BINARY_FILE" NODE_SEA_BLOB "$LCL_BLOB_FILE" \
            --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 || LCL_EXIT_CODE=$?
    else
        LCL_EXIT_CODE=1
    fi

    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

sign_binary() {
    PrintTrace "$TRACE_FUNCTION" "-> ${FUNCNAME[0]} ($*)"
    local LCL_BINARY_FILE=$1
    if [ "$AAI_UNIX_TYPE" == "mac" ]; then
        codesign --sign - "$LCL_BINARY_FILE" || return $?
    fi
    PrintTrace "$TRACE_FUNCTION" "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return 0
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "${DIR}/.."
# include common library, fail if does not exist
if [ -f "$AAI_COMMON_LIB_FILE" ]; then
    # shellcheck disable=SC1090
    source "$AAI_COMMON_LIB_FILE"
else
    help 1 "Cannot find common library: $AAI_COMMON_LIB_FILE"
fi

echo
PrintTrace "$TRACE_FUNCTION" "-> $0 ($*)"
common_is_parameter_help $# "$1" && help 0 "---- Help displayed ----"
common_check_number_of_parameters $EXPECTED_NUMBER_OF_PARAMS $# || help 1 "Invalid number of parameters"
common_is_parameter_valid "$AAI_UNIX_TYPE" "${AAI_SUPPORTED_OS[@]}" || help 1 "Unsupported OS: $AAI_UNIX_TYPE"
CURRENT_NODE_VERSION=$(node --version | sed 's/[^0-9\.]*//g')
common_check_version_requirement "$CURRENT_NODE_VERSION" "$AAI_REQUIRED_NODE_VERSION" || help 1 "Required node version: $AAI_REQUIRED_NODE_VERSION or higher, installed is: $CURRENT_NODE_VERSION"
install_required_tools || help 1 "Failed to install required tools"
mkdir -p dist || help 1 "Failed to create dist directory"

PrintTrace "$TRACE_INFO" "Creating binary ..."
PrintTrace "$TRACE_DEBUG" "AAI_SEA_CONFIG_FILE: $AAI_SEA_CONFIG_FILE"
create_inject_blob "$AAI_SEA_CONFIG_FILE" || help 1 "Failed to create blob"
create_node_binary BINARY_FILE "$AAI_SEA_CONFIG_FILE" || help 1 "Failed to create binary"
remove_binary_signature "$BINARY_FILE" || help 1 "Failed to remove binary signature"
PrintTrace "$TRACE_DEBUG" "----- BINARY_FILE: $BINARY_FILE"
ls -la dist/
inject_blob_into_binary "$AAI_SEA_CONFIG_FILE" "$BINARY_FILE" || help 1 "Failed to inject blob into binary"
sign_binary "$BINARY_FILE" || help 1 "Failed to sign binary"

popd
PrintTrace "$TRACE_FUNCTION" "<- $0 ($EXIT_CODE)"
echo
exit $EXIT_CODE
