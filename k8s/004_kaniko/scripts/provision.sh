#!/bin/bash

# alwaysAI Device Provisioning for Linux script
#
# Documentation: https://www.alwaysai.co/docs
#
# Prerequisites:
# 1. alwaysAI Device Agent installed with 'install-device-agent.sh'
#
# To provision the current device run:
#   $ curl -fsSL https://artifacts.alwaysai.co/device-agent/provision.sh | bash -s -- --email <email> --password <password> [--device-name <device_name>] [--provision-only]


# -----------------------------------------------------------------------------
# settings
# -----------------------------------------------------------------------------
#set -o xtrace
set -o errexit


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

# bind script log level to the aai-device log level
if [ $TRACE_LEVEL -le $TRACE_ERROR ]; then
    AAI_LOG_LEVEL_STR=error
elif [ $TRACE_LEVEL -le $TRACE_INFO ]; then
    AAI_LOG_LEVEL_STR=info
else
    AAI_LOG_LEVEL_STR=debug
fi

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
    echo
    echo "Provision the current device"
    echo "Usage: $0 --email <email> --password <password> [--device-name <device_name>] [--provision-only]"
    echo "  email: your alwaysAI account email"
    echo "  password: your alwaysAI account password"
    echo "  device-name: (optional) the name to use for this device"
    echo "  provision-only: flag indicating to skip step of starting Device Agent in the background$"
    echo
    if [ "$2" != "" ]; then
        if [ "$1" -eq 0 ]; then
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
    PrintTrace $TRACE_NONE "$TRUE $FALSE $BLK $RED $GRN $ORG $BLU $PRL $CYN $LGR $DGR $LRD $LGR $YLW $LBL $LPR $LCY $WHT $NC"
}

# -----------------------------------------------------------------------------
# local functions
# -----------------------------------------------------------------------------
read_and_validate_input() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_EMAIL=$1
    local LCL_PASSWORD=$2
    local LCL_DEVICE_NAME=$3
    local LCL_PROVISION_ONLY=$4
    shift
    shift
    shift
    shift
    # local LCL_INPUT_PARAMS=("$@")
    local LCL_EMAIL_VAL=
    local LCL_PASSWORD_VAL=
    local LCL_DEVICE_NAME_VAL=
    local LCL_PROVISION_ONLY_VAL=

    PrintTrace $TRACE_DEBUG "LCL_EMAIL           = $LCL_EMAIL"
    PrintTrace $TRACE_DEBUG "LCL_PASSWORD        = $LCL_PASSWORD"
    PrintTrace $TRACE_DEBUG "LCL_DEVICE_NAME     = $LCL_DEVICE_NAME"
    PrintTrace $TRACE_DEBUG "LCL_PROVISION_ONLY  = $LCL_PROVISION_ONLY"
    PrintTrace $TRACE_DEBUG "\$*                  = $*"

    PrintTrace $TRACE_INFO "Parsing input parameters..."
    while [ $# -gt 0 ]; do
        key="$1"
        PrintTrace $TRACE_DEBUG "key    = $key"
        PrintTrace $TRACE_DEBUG "value  = $2"
        case $key in
            --email)
                [ "$2" == "" ] && help 1 "Email field is empty!"
                LCL_EMAIL_VAL="$2"
                shift # past argument
                shift # past value
                ;;
            --password)
                [ "$2" == "" ] && help 1 "Password field is empty!"
                LCL_PASSWORD_VAL="$2"
                shift # past argument
                shift # past value
                ;;
            --device-name)
                [ "$2" == "" ] && help 1 "Device name field is empty!"
                LCL_DEVICE_NAME_VAL="$2"
                shift # past argument
                shift # past value
                ;;
            --provision-only)
                LCL_PROVISION_ONLY_VAL='1'
                shift # past argument
                ;;
            *)    # unknown option
                help 1 "Unknown option: $1"
                ;;
        esac
    done

    [ -z "$LCL_EMAIL_VAL" ] && help 1 "Email is required!"
    [ -z "$LCL_PASSWORD_VAL" ] && help 1 "Password is required!"
    [ -z "$LCL_DEVICE_NAME_VAL" ] && LCL_DEVICE_NAME_VAL=""
    [ -z "$LCL_PROVISION_ONLY_VAL" ] && LCL_PROVISION_ONLY_VAL='0'

    eval "$LCL_EMAIL"=\$LCL_EMAIL_VAL
    eval "$LCL_PASSWORD"=\$LCL_PASSWORD_VAL
    eval "$LCL_DEVICE_NAME"=\$LCL_DEVICE_NAME_VAL
    eval "$LCL_PROVISION_ONLY"=\$LCL_PROVISION_ONLY_VAL
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}


create_pm2_aai_agent_startup() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_PROVISION_ONLY=$1
    if [ "$LCL_PROVISION_ONLY" == '1' ]; then
        echo 'Skipping Device Agent run in background'
    else
        mkdir -p ~/.config/alwaysai/pm2
        touch ~/.config/alwaysai/pm2/aai-agent.config.js ~/.config/alwaysai/pm2/start.sh
        chmod +x ~/.config/alwaysai/pm2/start.sh

        echo '
#!/bin/bash
set -o errexit
sudo npm install -g @alwaysai/device-agent@latest
aai-agent
' > ~/.config/alwaysai/pm2/start.sh

        echo '
module.exports = {
apps : [{
    name: "aai-agent",
    script: "./.config/alwaysai/pm2/start.sh",
    env: {
    ALWAYSAI_DEVICE_AGENT_MODE: "cloud",
    ALWAYSAI_LOG_LEVEL: "debug",
    ALWAYSAI_LOG_TO_CONSOLE: "",
    ALWAYSAI_ANALYTICS_PASSTHROUGH: "1"
    }
}]
}
' > ~/.config/alwaysai/pm2/aai-agent.config.js

        (
            cd ~
            pm2 start ~/.config/alwaysai/pm2/aai-agent.config.js
            eval "$(pm2 startup | sed -n 3p)"
            pm2 save
        )
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}


# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
use_defined_variables
echo
PrintTrace $TRACE_FUNCTION "-> $0 ($*)"

read_and_validate_input EMAIL PASSWORD DEVICE_NAME PROVISION_ONLY "$@"
PrintTrace $TRACE_DEBUG "Email            = $EMAIL"
PrintTrace $TRACE_DEBUG "Password         = $PASSWORD"
PrintTrace $TRACE_DEBUG "Device Name      = $DEVICE_NAME"
PrintTrace $TRACE_DEBUG "Provision Only   = $PROVISION_ONLY"

PrintTrace $TRACE_INFO "Logging in using your email/password..."
export ALWAYSAI_DEVICE_AGENT_MODE=''
export ALWAYSAI_LOG_TO_CONSOLE=1
export ALWAYSAI_LOG_LEVEL=$AAI_LOG_LEVEL_STR
aai-agent login --email "$EMAIL" --password "$PASSWORD" || help $? "Failed to login"

PrintTrace $TRACE_INFO "Initializing aai-agent..."
aai-agent device init --name "$DEVICE_NAME" || help $? "Failed to init aai-agent"

PrintTrace $TRACE_INFO "Starting aai-agent..."
export ALWAYSAI_DEVICE_AGENT_MODE='cloud'
aai-agent || help $? "Failed to start aai-agent"

create_pm2_aai_agent_startup "$PROVISION_ONLY"

PrintTrace $TRACE_INFO "Device provision done!"
PrintTrace $TRACE_FUNCTION "<- $0 (0)"
echo
exit 0
