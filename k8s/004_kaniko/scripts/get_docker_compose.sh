#!/bin/bash

REQUIRED_DOCKER_COMPOSE_VERSION='2.25.0'

TRUE=0
FALSE=1

TRACE_NONE=0
TRACE_CRITICAL=1
TRACE_ERROR=2
TRACE_FUNCTION=3
TRACE_INFO=4
TRACE_DEBUG=5
TRACE_ALL=6
TRACE_LEVEL=$TRACE_DEBUG

if [ -z "$ALWAYSAI_DISABLE_BASH_COLORS" ]; then
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
    if [ "$TRACE_LEVEL" -ge "$LCL_TRACE_LEVEL" ]; then
        case $LCL_TRACE_LEVEL in
            $TRACE_CRITICAL)
                echo -e "${RED}[CRITICAL] ${LCL_PRINT_STRING[@]}${NC}" ;;
            $TRACE_ERROR)
                echo -e "${RED}[ERROR] ${LCL_PRINT_STRING[@]}${NC}" ;;
            $TRACE_FUNCTION)
                echo -e "${CYN}${LCL_PRINT_STRING[@]}${NC}" ;;
            $TRACE_INFO)
                echo -e "${YLW}[INFO] ${LCL_PRINT_STRING[@]}${NC}" ;;
            $TRACE_DEBUG)
                echo -e "${BLU}[DEBUG] ${LCL_PRINT_STRING[@]}${NC}" ;;
            *)
                echo -e "${LCL_PRINT_STRING[@]}" ;;
        esac
    fi
}


get_docker_compose_version() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_MAJOR_RETURN=$1
    local LCL_MINOR_RETURN=$2
    local LCL_PATCH_RETURN=$3
    local LCL_EXIT_CODE=$TRUE

    local LCL_DOCKER_COMPOSE_VERSION_STR=$(docker compose version 2>/dev/null)
    PrintTrace $TRACE_DEBUG "LCL_DOCKER_COMPOSE_VERSION_STR = $LCL_DOCKER_COMPOSE_VERSION_STR"
    [ -z "$LCL_DOCKER_COMPOSE_VERSION_STR" ] && return 1 # check we have something before proceed

    local LCL_VERSION_STR=$(echo "$LCL_DOCKER_COMPOSE_VERSION_STR" | awk '{print $4}' | sed 's/[^0-9\.]*//g')
    PrintTrace $TRACE_DEBUG "LCL_VERSION_STR = $LCL_VERSION_STR"
    local LCL_VERSION_STR_ARRAY=(${LCL_VERSION_STR//./ })
    PrintTrace $TRACE_DEBUG "LCL_VERSION_STR_ARRAY = ${LCL_VERSION_STR_ARRAY[@]}"
    if [ ${#LCL_VERSION_STR_ARRAY[@]} -ge 3 ]; then
        eval $LCL_MAJOR_RETURN=\${LCL_VERSION_STR_ARRAY[0]}
        eval $LCL_MINOR_RETURN=\${LCL_VERSION_STR_ARRAY[1]}
        eval $LCL_PATCH_RETURN=\${LCL_VERSION_STR_ARRAY[2]}
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
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_CURRENT_VERSION=$1 # please pass the version in format major.minor.patch
    local LCL_REQUIRED_VERSION=$2  # please pass the version in format major.minor.patch
    local LCL_EXIT_CODE=$FALSE

    # extract major, minor, patch into arrays
    local LCL_CURRENT_ARRAY=(${LCL_CURRENT_VERSION//./ })
    local LCL_REQUIRED_ARRAY=(${LCL_REQUIRED_VERSION//./ })

    # validate required version numbers
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
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_DOCKER_COMPOSE_REQUIRES_UPDATE=$FALSE
    local LCL_VERSION_MAJOR=
    local LCL_VERSION_MINOR=
    local LCL_VERSION_PATCH=
    get_docker_compose_version LCL_VERSION_MAJOR LCL_VERSION_MINOR LCL_VERSION_PATCH || help $? "Not able to extract docker compose version numbers"

    check_version_requirement "$LCL_VERSION_MAJOR.$LCL_VERSION_MINOR.$LCL_VERSION_PATCH" "$REQUIRED_DOCKER_COMPOSE_VERSION" || LCL_DOCKER_COMPOSE_REQUIRES_UPDATE=$TRUE
    if [ $LCL_DOCKER_COMPOSE_REQUIRES_UPDATE -eq $TRUE ]; then
        PrintTrace $TRACE_ERROR "Docker compose version requirement not met"
        install_docker_compose
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}


# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
echo
PrintTrace $TRACE_FUNCTION "-> $0 ($*)"

check_docker_compose_installation


PrintTrace $TRACE_FUNCTION "<- $0 (0)"
echo
exit 0
