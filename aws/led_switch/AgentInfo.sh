#!/bin/bash

COLOR_DEFINITIONS="./BashColorDefinitions.sh"
[ -f $COLOR_DEFINITIONS ] && source $COLOR_DEFINITIONS || echo "ERROR: $COLOR_DEFINITIONS not found!"

# BLACK='\033[0;30m'
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# ORANGE='\033[0;33m'
# BLUE='\033[0;34m'
# PURPLE='\033[0;35m'
# CYAN='\033[0;36m'
# LIGHT_GRAY='\033[0;37m'
# DARK_GRAY='\033[1;30m'
# LIGHT_RED='\033[1;31m'
# LIGHT_GREEN='\033[1;32m'
# YELLOW='\033[1;33m'
# LIGHT_BLUE='\033[1;34m'
# LIGHT_PURPLE='\033[1;35m'
# LIGHT_CYAN='\033[1;36m'
# WHITE='\033[1;37m'
# NC='\033[0m' # No Color

#---------------------------
# functions
#---------------------------
DateAndTimeInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    local CURRENT_DATE_TIME=$(date)
    local EPOCH_DATE_TIME=$(date +%s)
    echo -e "CURRENT_DATE_TIME \t: $CURRENT_DATE_TIME"
    echo -e "EPOCH_DATE_TIME   \t: $EPOCH_DATE_TIME"
}

BuildInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "Build.BuildId     \t: $BUILD_ID"
    echo -e "Build.BuildNumber \t: $BUILD_NUMBER"
}

NumberOfProcessingCores ()
{
    local LCL_NUMBER_OF_CORES=
    local LCL_UNAME="$(uname -s)"
    [ "$LCL_UNAME" == "Darwin" ] && LCL_UNAME="Mac OSX" && LCL_NUMBER_OF_CORES=$(sysctl -n hw.ncpu) || LCL_NUMBER_OF_CORES=$(nproc --all)
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo "Unix type                  :  $LCL_UNAME system"
    echo "Number of Processing Cores :  $LCL_NUMBER_OF_CORES"
}

AgentHwInfo ()
{
    local LCL_INFO_KEY=(
                            MACHINE_NODE_NAME
                            MACHINE_HW_NAME
                            CPU_ARCHITECTURE
                            OS_SYSTEM_RELEASE
                            OS_SYSTEM_NAME
                            OS_SYSTEM_VERSION
                        )
    local LCL_INFO_VALUE=(
                            $(uname -n)
                            $(uname -m)
                            $(uname -p)
                            $(uname -r)
                            $(uname -s)
                            $(uname -v)
                         )
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    for (( i = 0; i < ${#LCL_INFO_KEY[@]}; i++)); do
        echo -e "${LCL_INFO_KEY[$i]}  \t: ${LCL_INFO_VALUE[$i]}"
    done
}

CurrentDirectoryInfo ()
{
    local LCL_PWD=$(pwd)
    local LCL_LIST_DIR=$(ls -la)
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "LCL_PWD      \t : $LCL_PWD"
    echo -e "LCL_LIST_DIR \t : $LCL_LIST_DIR"
}

PathInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo "${PATH//:/$'\n'}"
}

NodeInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "\n------------------------\nNODE LOCATION\n------------------------"
    which node
    echo -e "\n------------------------\nNODE VERSION\n------------------------"
    node --version
    echo -e "\n------------------------\nNPM LOCATION\n------------------------"
    which npm
    echo -e "\n------------------------\nNPM VERSION\n------------------------"
    npm --version

}

PythonInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "\n------------------------\nPYTHON INSTALLATION LOCATIONS\n------------------------"
    which -a python python2 python3
    echo -e "\n------------------------\nPYTHON VERSIONS AND lIBS\n------------------------"
    python --version
    echo -e "\n------------------------\nPYTHON2 VERSIONS AND lIBS\n------------------------"
    python2 --version
    python2 -c 'import sys; print(sys.path)'
    echo -e "\n------------------------\nPYTHON3 VERSIONS AND lIBS\n------------------------"
    python3 --version
    python3 -c 'import sys; print(sys.path)'
    echo
    echo -e "\n------------------------\nPIP INSTALLATIONS\n------------------------"
    which pip pip2 pip3
    echo -e "\n------------------------\nPIP VERSION\n------------------------"
    pip -V
    echo -e "\n------------------------\nPIP2 VERSION\n------------------------"
    pip2 -V
    echo -e "\n------------------------\nPIP3 VERSION\n------------------------"
    pip3 -V
}

BrewInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "\n------------------------\nBREW LOCATION\n------------------------"
    which brew
    echo -e "\n------------------------\nBREW VERSION\n------------------------"
    brew --version
    echo -e "\n------------------------\nBREW LIST\n------------------------"
    brew list --versions
    echo -e "\n------------------------\nBREW OUTDATED\n------------------------"
    brew outdated
}

BashInfo ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "\n------------------------\nBASH LOCATION\n------------------------"
    which bash
    echo -e "\n------------------------\nBASH VERSION\n------------------------"
    bash --version
}

SysteVariablesSettings ()
{
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    # echo "HOME = $HOME"
    # echo "SHELL = $SHELL"
    # # set
    declare -xp | cut -d" " -f3-
}


#---------------------------
# main
#---------------------------
echo
echo "-> $0 ($@)"

DateAndTimeInfo
# BuildInfo
NumberOfProcessingCores
AgentHwInfo
CurrentDirectoryInfo
PathInfo
NodeInfo
PythonInfo
BashInfo
BrewInfo
SysteVariablesSettings

echo "<- $0 (0)"
echo
exit 0
