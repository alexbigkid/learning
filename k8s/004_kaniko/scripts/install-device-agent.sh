#!/bin/bash

# alwaysAI Device Agent for Linux installation script
#
# Documentation: https://www.alwaysai.co/docs
#
# Prerequisites:
# 1. Docker installed with user permissions
#
# To install the alwaysAI Device Agent run:
#   $ curl -fsSL https://artifacts.alwaysai.co/device-agent/install-device-agent.sh | sudo -E bash -


# -----------------------------------------------------------------------------
# settings
# -----------------------------------------------------------------------------
set -o errexit

SUPPORTED_LINUX_DISTROS=( "ubuntu" "debian" "raspbian" )
SUPPORTED_UBUNTU_VERSIONS=( "20.04" "22.04" "23.10" "24.04" )
SUPPORTED_DEBIAN_VERSIONS=( "11" "12" )
SUPPORTED_RASPBIAN_VERSIONS=( "11" "12" )
REQUIRED_DOCKER_COMPOSE_VERSION='2.18.1'
REQUIRED_NODE_VERSION='18.0.0'


# -----------------------------------------------------------------------------
# script variables
# -----------------------------------------------------------------------------
TRUE=0
FALSE=1

TRACE_NONE=0
TRACE_CRITICAL=1
TRACE_ERROR=2
TRACE_FUNCTION=3
TRACE_INFO=4
TRACE_DEBUG=5
TRACE_ALL=6
TRACE_LEVEL=$TRACE_INFO

if [ -z "${ALWAYSAI_DISABLE_BASH_COLORS+x}" ] || [ -z "$ALWAYSAI_DISABLE_BASH_COLORS" ]; then
    BLK='\033[0;30m'
    RED='\033[0;31m'
    GRN='\033[0;32m'
    ORG='\033[0;33m'
    BLU='\033[0;34m'
    PRL='\033[0;35m'
    CYN='\033[0;36m'
    LGR='\033[0;37m'
    DGR='\033[1;30m'
    LRD='\033[1;31m'
    LGR='\033[1;32m'
    YLW='\033[1;33m'
    LBL='\033[1;34m'
    LPR='\033[1;35m'
    LCY='\033[1;36m'
    WHT='\033[1;37m'
    NC='\033[0m' # No Color
else
    echo "not using colors: ALWAYSAI_DISABLE_BASH_COLORS is defined: $ALWAYSAI_DISABLE_BASH_COLORS"
    BLK=
    RED=
    GRN=
    ORG=
    BLU=
    PRL=
    CYN=
    LGR=
    DGR=
    LRD=
    LGR=
    YLW=
    LBL=
    LPR=
    LCY=
    WHT=
    NC=
fi

# -----------------------------------------------------------------------------
# help functions
# -----------------------------------------------------------------------------
PrintTrace() {
    local LCL_TRACE_LEVEL=$1
    shift
    local LCL_PRINT_STRING=("$@")
    # shellcheck disable=SC2086
    if [ $TRACE_LEVEL -ge $LCL_TRACE_LEVEL ]; then
        case $LCL_TRACE_LEVEL in
            "$TRACE_CRITICAL")
                echo -e "${RED}[CRITICAL] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_ERROR")
                echo -e "${RED}[ERROR] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_FUNCTION")
                echo -e "${CYN}${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_INFO")
                echo -e "${YLW}[INFO] ${LCL_PRINT_STRING[*]}${NC}" ;;
            "$TRACE_DEBUG")
                echo -e "${BLU}[DEBUG] ${LCL_PRINT_STRING[*]}${NC}" ;;
            *)
                echo -e "${LCL_PRINT_STRING[@]}" ;;
        esac
    fi
}

help() {
    if [ "$2" != "" ]; then
        # shellcheck disable=SC2086
        if [ $1 -eq 0 ]; then
            PrintTrace $TRACE_INFO "$2"
        else
            PrintTrace $TRACE_ERROR "$2"
        fi
    fi
    echo
    exit "$1"
}

use_defined_variables() {
    # The purpose of this function is just to ensure that the definitions of all variables on the top of the file are used
    # Without this function shellcheck tool will bring up a lot of warnings of unused variables.
    # Even though some variables might not be used at the moment, they might be used in the future.
    # #shellcheck disable=SC2034 - was not used because it makes the variable definitions harder to read.
    PrintTrace $TRACE_ALL "use_defined_variables"
    PrintTrace $TRACE_NONE "$BLK $RED $GRN $ORG $BLU $PRL $CYN $LGR $DGR $LRD $LGR $YLW $LBL $LPR $LCY $WHT $NC"
}

# -----------------------------------------------------------------------------
# local functions
# -----------------------------------------------------------------------------
install_socat() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    if [ "$(command -v socat)" == "" ]; then
        PrintTrace $TRACE_INFO "Installing socat (needed for secure-tunnel HTTP proxy)..."
        sudo apt-get install -y --no-install-recommends socat
    else
        PrintTrace $TRACE_INFO "socat is already installed"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

install_nodejs() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    PrintTrace $TRACE_INFO "Checking NodeJS installation..."
    local LCL_NODE_REQUIRES_UPDATE=$FALSE
    if [ "$(command -v node)" == "" ]; then
        LCL_NODE_REQUIRES_UPDATE=$TRUE
    else
        LCL_CURRENT_NODE_VERSION=$(node --version)
        # strip leading v
        LCL_CURRENT_NODE_VERSION=${LCL_CURRENT_NODE_VERSION:1}
        check_version_requirement "$LCL_CURRENT_NODE_VERSION" "$REQUIRED_NODE_VERSION" || LCL_NODE_REQUIRES_UPDATE=$TRUE
    fi

    if [ $LCL_NODE_REQUIRES_UPDATE -eq $TRUE ]; then
        PrintTrace $TRACE_INFO "Install NodeJS 20"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
        nodejs -v
        npm -v
    else
        PrintTrace $TRACE_INFO "NodeJS ${LCL_CURRENT_NODE_VERSION} is already installed"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

update_npm() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    PrintTrace $TRACE_INFO "Updating to latest npm..."
    sudo npm install -g npm
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

install_aai_device_agent() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    PrintTrace $TRACE_INFO "Installing alwaysAI Device Agent..."
    sudo npm install -g @alwaysai/device-agent@latest
    sudo npm install -g pm2@latest
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

check_docker_installation() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    PrintTrace $TRACE_INFO "Checking Docker installation..."
    local LCL_CURRENT_DOCKER_VERSION
    local DOCKER_REQUIRES_UPDATE=$FALSE
    if [ "$(command -v docker)" == "" ]; then
        DOCKER_REQUIRES_UPDATE=$TRUE
    else
        LCL_CURRENT_DOCKER_VERSION=$(docker --version)
        PrintTrace $TRACE_INFO "Found docker: ${LCL_CURRENT_DOCKER_VERSION}"
    fi

    if [ $DOCKER_REQUIRES_UPDATE -eq $TRUE ]; then
        help 1 "Docker must be installed manually!"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

# install_docker_official() {
#     PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
#     # This is the official production process to install, but seems to
#     # conflict with the nvidia-docker installation
#     sudo apt-get remove -y docker docker-engine docker.io containerd runc || echo "Existing Docker installation not found"
#     sudo apt-get install -y --no-install-recommends \
#         ca-certificates \
#         curl \
#         gnupg \
#         lsb-release

#     mkdir -p /etc/apt/keyrings
#     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#     echo \
#         "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#         $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#     sudo apt-get update
#     sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
#     PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
# }

get_id_linux() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_RETURN_VAR=$1
    local LCL_EXIT_CODE=0
    local LCL_GET_LINUX_ID=""
    LCL_GET_LINUX_ID="$(grep '^ID=.*' /etc/os-release | cut -d'=' -f2)"
    [ "$LCL_GET_LINUX_ID" == "" ] && LCL_EXIT_CODE=1
    PrintTrace $TRACE_DEBUG "LCL_GET_LINUX_ID = $LCL_GET_LINUX_ID"

    eval "$LCL_RETURN_VAR"=\$LCL_GET_LINUX_ID
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE $LCL_GET_LINUX_ID)"
    return $LCL_EXIT_CODE
}

get_linux_id_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_RETURN_VAR=$1
    local LCL_EXIT_CODE=0
    local LCL_GET_LINUX_VERSION_ID=""
    LCL_GET_LINUX_VERSION_ID="$(grep '^VERSION_ID=.*' /etc/os-release | cut -d'=' -f2 | sed 's/"//g')"
    PrintTrace $TRACE_DEBUG "LCL_GET_LINUX_VERSION_ID = $LCL_GET_LINUX_VERSION_ID"
    [ "$LCL_GET_LINUX_VERSION_ID" == "" ] && LCL_EXIT_CODE=1

    eval "$LCL_RETURN_VAR"=\$LCL_GET_LINUX_VERSION_ID
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE $LCL_GET_LINUX_VERSION_ID)"
    return $LCL_EXIT_CODE
}

is_predefined_parameter_valid() {
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

check_is_supported_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_RETURN_VAR=$1
    local LCL_CHECK_SUPPORTED_LINUX_ID=
    local LCL_CHECK_SUPPORTED_LINUX_VERSION_ID=
    get_id_linux LCL_CHECK_SUPPORTED_LINUX_ID || help $? "Not able to read Linux distro name"
    PrintTrace $TRACE_DEBUG "LCL_CHECK_SUPPORTED_LINUX_ID = $LCL_CHECK_SUPPORTED_LINUX_ID"
    is_predefined_parameter_valid "$LCL_CHECK_SUPPORTED_LINUX_ID" "${SUPPORTED_LINUX_DISTROS[@]}" || help 1 "$LCL_CHECK_SUPPORTED_LINUX_ID Linux Distro not supported"
    get_linux_id_version LCL_CHECK_SUPPORTED_LINUX_VERSION_ID || help $? "Not able to read $LCL_CHECK_SUPPORTED_LINUX_ID linux version"
    PrintTrace $TRACE_DEBUG "LCL_CHECK_SUPPORTED_LINUX_VERSION_ID = $LCL_CHECK_SUPPORTED_LINUX_VERSION_ID"

    case "${LCL_CHECK_SUPPORTED_LINUX_ID}" in
        "ubuntu")
            is_predefined_parameter_valid "$LCL_CHECK_SUPPORTED_LINUX_VERSION_ID" "${SUPPORTED_UBUNTU_VERSIONS[@]}" || help 1 "Ubuntu Version ($LCL_CHECK_SUPPORTED_LINUX_VERSION_ID) not supported"
            ;;
        "debian")
            is_predefined_parameter_valid "$LCL_CHECK_SUPPORTED_LINUX_VERSION_ID" "${SUPPORTED_DEBIAN_VERSIONS[@]}" || help 1 "Debian Version ($LCL_CHECK_SUPPORTED_LINUX_VERSION_ID) not supported"
            ;;
        "raspbian")
            is_predefined_parameter_valid "$LCL_CHECK_SUPPORTED_LINUX_VERSION_ID" "${SUPPORTED_RASPBIAN_VERSIONS[@]}" || help 1 "Raspbian Version ($LCL_CHECK_SUPPORTED_LINUX_VERSION_ID) not supported"
            ;;
        *)
            help 1 "Bad value identified for OS or version"
            ;;
    esac

    eval "$LCL_RETURN_VAR"=\$LCL_CHECK_SUPPORTED_LINUX_ID
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0 $LCL_CHECK_SUPPORTED_LINUX_ID)"
    return 0
}

setup_docker_repo() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    local LCL_SETUP_DOCKER_LINUX_ID=
    PrintTrace $TRACE_INFO "Setting up repository for Docker and Docker Compose..."
    check_is_supported_version LCL_SETUP_DOCKER_LINUX_ID
    PrintTrace $TRACE_DEBUG "LCL_SETUP_DOCKER_LINUX_ID = $LCL_SETUP_DOCKER_LINUX_ID"

    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "https://download.docker.com/linux/$LCL_SETUP_DOCKER_LINUX_ID/gpg" -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # to avoid shellcheck producing an error the external file needs to be checked for existance before sourcing it.
    if [ -f /etc/os-release ]; then
        # shellcheck source=src/etc/os-release disable=SC1091
        source /etc/os-release
    else
        help 1 "/etc/os-release not found"
    fi

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$LCL_SETUP_DOCKER_LINUX_ID \
    $VERSION_CODENAME stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

install_docker_compose() {
    # Note: please call this after calling setup_docker_repo
    # this ensures the keys and certificates are up to date
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    setup_docker_repo
    PrintTrace $TRACE_INFO "Installing Docker Compose..."
    sudo apt-get update
    sudo apt-get install docker-compose-plugin
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

get_docker_compose_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_MAJOR_RETURN=$1
    local LCL_MINOR_RETURN=$2
    local LCL_PATCH_RETURN=$3
    local LCL_EXIT_CODE=$TRUE

    local LCL_DOCKER_COMPOSE_VERSION_STR=""
    LCL_DOCKER_COMPOSE_VERSION_STR=$(docker compose version 2>/dev/null)
    PrintTrace $TRACE_DEBUG "LCL_DOCKER_COMPOSE_VERSION_STR = $LCL_DOCKER_COMPOSE_VERSION_STR"
    [ -z "$LCL_DOCKER_COMPOSE_VERSION_STR" ] && return 1 # check we have something before proceed

    local LCL_VERSION_STR=""
    LCL_VERSION_STR=$(echo "$LCL_DOCKER_COMPOSE_VERSION_STR" | awk '{print $4}' | sed 's/[^0-9\.]*//g')
    PrintTrace $TRACE_DEBUG "LCL_VERSION_STR = $LCL_VERSION_STR"
    local LCL_VERSION_STR_ARRAY=
    IFS='.' read -r -a LCL_VERSION_STR_ARRAY <<< "$LCL_VERSION_STR"

    PrintTrace $TRACE_DEBUG "LCL_VERSION_STR_ARRAY = ${LCL_VERSION_STR_ARRAY[*]}"
    PrintTrace $TRACE_DEBUG "Length of LCL_VERSION_STR_ARRAY = ${#LCL_VERSION_STR_ARRAY[@]}"
    if [ ${#LCL_VERSION_STR_ARRAY[@]} -ge 3 ]; then
        # shellcheck disable=SC1083
        eval "$LCL_MAJOR_RETURN"=\${LCL_VERSION_STR_ARRAY[0]}
        # shellcheck disable=SC1083
        eval "$LCL_MINOR_RETURN"=\${LCL_VERSION_STR_ARRAY[1]}
        # shellcheck disable=SC1083
        eval "$LCL_PATCH_RETURN"=\${LCL_VERSION_STR_ARRAY[2]}
        PrintTrace $TRACE_DEBUG "MAJOR_VERSION = ${LCL_VERSION_STR_ARRAY[0]}"
        PrintTrace $TRACE_DEBUG "MINOR_VERSION = ${LCL_VERSION_STR_ARRAY[1]}"
        PrintTrace $TRACE_DEBUG "PATCH_VERSION = ${LCL_VERSION_STR_ARRAY[2]}"
    else
        LCL_EXIT_CODE=$FALSE
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

check_version_requirement() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_CURRENT_VERSION=$1 # please pass the version in format major.minor.patch
    local LCL_REQUIRED_VERSION=$2  # please pass the version in format major.minor.patch
    local LCL_EXIT_CODE=$FALSE

    # extract major, minor, patch into arrays
    local LCL_CURRENT_ARRAY=
    IFS='.' read -r -a LCL_CURRENT_ARRAY <<< "$LCL_CURRENT_VERSION"
    local LCL_REQUIRED_ARRAY=
    IFS='.' read -r -a LCL_REQUIRED_ARRAY <<< "$LCL_REQUIRED_VERSION"

    # validate required version numbers
    # shellcheck disable=SC2086
    if [ ${LCL_CURRENT_ARRAY[0]} -gt ${LCL_REQUIRED_ARRAY[0]} ]; then
        LCL_EXIT_CODE=$TRUE
    elif [ ${LCL_CURRENT_ARRAY[0]} -eq ${LCL_REQUIRED_ARRAY[0]} ] && \
        [ ${LCL_CURRENT_ARRAY[1]} -gt ${LCL_REQUIRED_ARRAY[1]} ]; then
        LCL_EXIT_CODE=$TRUE
    elif [ ${LCL_CURRENT_ARRAY[0]} -eq ${LCL_REQUIRED_ARRAY[0]} ] && \
        [ ${LCL_CURRENT_ARRAY[1]} -eq ${LCL_REQUIRED_ARRAY[1]} ] && \
        [ ${LCL_CURRENT_ARRAY[2]} -ge ${LCL_REQUIRED_ARRAY[2]} ]; then
        LCL_EXIT_CODE=$TRUE
    fi

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

check_docker_compose_installation() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ()"
    local LCL_DOCKER_COMPOSE_REQUIRES_UPDATE=$FALSE
    if docker compose version &> /dev/null; then
        local LCL_VERSION_MAJOR=
        local LCL_VERSION_MINOR=
        local LCL_VERSION_PATCH=
        get_docker_compose_version LCL_VERSION_MAJOR LCL_VERSION_MINOR LCL_VERSION_PATCH || help $? "Not able to extract docker compose version numbers"

        check_version_requirement "$LCL_VERSION_MAJOR.$LCL_VERSION_MINOR.$LCL_VERSION_PATCH" "$REQUIRED_DOCKER_COMPOSE_VERSION" || LCL_DOCKER_COMPOSE_REQUIRES_UPDATE=$TRUE
    else
        LCL_DOCKER_COMPOSE_REQUIRES_UPDATE=$TRUE
    fi

    if [ $LCL_DOCKER_COMPOSE_REQUIRES_UPDATE -eq $TRUE ]; then
        PrintTrace $TRACE_INFO "Docker compose version requirement not met"
        install_docker_compose
    else
        PrintTrace $TRACE_INFO "Docker compose version requirement OK"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}


# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
use_defined_variables
echo
PrintTrace $TRACE_FUNCTION "-> $0 ($*)"

PrintTrace $TRACE_INFO "Updating system package manager (apt-get)..."
sudo apt-get update

install_socat
install_nodejs
update_npm
install_aai_device_agent

check_docker_installation
sudo usermod -aG docker "$USER"
check_docker_compose_installation

PrintTrace $TRACE_INFO "Installed alwaysAI Device Agent and dependencies"
PrintTrace $TRACE_FUNCTION "<- $0 (0)"
echo
exit 0
