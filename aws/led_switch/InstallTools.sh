#!/bin/bash

COLOR_DEFINITIONS="./BashColorDefinitions.sh"
[ -f $COLOR_DEFINITIONS ] && source $COLOR_DEFINITIONS || echo "ERROR: $COLOR_DEFINITIONS not found!"

#---------------------------
# functions
#---------------------------
InstallRequiredToolsUsingBrew() {
    local TOOL=(
        gcc
        # cmake
        # gcovr
        ruby
        # ceedling
    )
    local PACKAGE=(
        gcc
        # cmake
        # gcovr
        ruby
        # ceedling
    )
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"

    for ((i = 0; i < ${#TOOL[@]}; i++)); do
        echo -e "\n------------------------\n${TOOL[$i]} - INSTALL AND CHECK\n------------------------"
        [ "$(command -v ${TOOL[$i]})" == "" ] && brew install ${PACKAGE[$i]} || which ${TOOL[$i]}
        echo -e "\n------------------------\n${TOOL[$i]} - VERSION\n------------------------"
        ${TOOL[$i]} --version || exit $?
        echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
        echo
    done
}

InstallCeedlingGem() {
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"

    TEST_SUPPORT_DIR='./test/support'
    echo -e "\n------------------------\nCreating $TEST_SUPPORT_DIR dir needed for ceedling to work\n------------------------"
    mkdir $TEST_SUPPORT_DIR -p
    echo -e "\n------------------------\nAdding USER_GEM_PATH=$HOME/$USER_GEM_PATH to PATH\n------------------------"
    export PATH=$HOME/$USER_GEM_PATH:$PATH
    echo "PATH = $PATH"
    echo -e "\n------------------------\nInstalling ceedling gem\n------------------------"
    gem install --user-install ceedling
    echo -e "\n------------------------\nChecking ceedling version\n------------------------"
    ceedling version
    echo
    echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}| List of installed ruby gems"
    echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
    gem list
}

InstallRequiredToolsUsingPip() {
    local TOOL=(
        gcovr
    )
    local PACKAGE=(
        gcovr
    )
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"

    for ((i = 0; i < ${#TOOL[@]}; i++)); do
        echo -e "\n------------------------\n${TOOL[$i]} - INSTALL AND CHECK\n------------------------"
        [ "$(command -v ${TOOL[$i]})" == "" ] && pip install ${PACKAGE[$i]} || which ${TOOL[$i]}
        echo -e "\n------------------------\n${TOOL[$i]} - VERSION\n------------------------"
        python ${TOOL[$i]} --version || exit $?
        echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
        echo
    done
}

InstallRequiredToolsUsingNpm() {
    # ask cli v2.15.0 broke our pipeline we need to install a previous version of the tool.
    # unfortunatelly the brew does not offer ask cli v 2.14.0, which we know it was running successfully with before.
    # brew install ask-cli@2.14.0 - fails

    # "brew install serverless" fails to install serverless package
    # this is a work around to install it through npm installer

    local TOOL=(
        ask
        serverless
    )
    local PACKAGE=(
        ask-cli@2.14.0
        serverless
    )
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${RED}| Please use this function if the installation of required tool fails with InstallRequiredToolsUsingBrew.${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"

    for ((i = 0; i < ${#TOOL[@]}; i++)); do
        echo -e "\n------------------------\n${TOOL[$i]} - INSTALL AND CHECK\n------------------------"
        [ "$(command -v ${TOOL[$i]})" == "" ] && sudo npm -g install ${PACKAGE[$i]} || which ${TOOL[$i]}
        echo -e "\n------------------------\n${TOOL[$i]} - VERSION\n------------------------"
        ${TOOL[$i]} --version || exit $?
        echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
        echo
    done
}

#---------------------------
# main
#---------------------------
echo
echo "-> $0 ($@)"

InstallRequiredToolsUsingBrew || exit $?
# InstallRequiredToolsUsingPip || exit $?
# InstallCeedlingGem || exit $?
# InstallRequiredToolsUsingNpm || exit $?

echo "<- $0 (0)"
echo
exit 0
