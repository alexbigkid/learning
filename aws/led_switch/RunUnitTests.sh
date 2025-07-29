#!/bin/bash

COLOR_DEFINITIONS="./BashColorDefinitions.sh"
[ -f $COLOR_DEFINITIONS ] && source $COLOR_DEFINITIONS || echo "ERROR: $COLOR_DEFINITIONS not found!"

RunCeedlingUnitTests() {
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    ceedling test:all
    return $?
}

RunCeedlingCoverage() {
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    ceedling gcov:all
    return $?
}

CreateAndOpenCoverageHtmlPage() {
    echo
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}| ${FUNCNAME[0]}${NC}"
    echo -e "${GREEN}----------------------------------------------------------------------${NC}"
    ceedling utils:gcov
    open build/artifacts/gcov/GcovCoverageResults.html
    return $?
}

#---------------------------
# main
#---------------------------
echo
echo "-> $0 ($@)"

echo -e "\n${BLUE}------------------------\nAdding USER_GEM_DIR=$HOME/$USER_GEM_DIR to PATH\n------------------------${NC}"
export PATH=$HOME/$USER_GEM_PATH:$PATH

# need that to supress deprications errors while executing the ceedling tests,
# ceedling writes to the error stream causing pipeline to fail
export RUBYOPT='-W:no-deprecated'

# RunCeedlingUnitTests || exit $?
# RunCeedlingCoverage || exit $?
# CreateAndOpenCoverageHtmlPage || exit $?

echo "<- $0 (0)"
echo
exit 0
