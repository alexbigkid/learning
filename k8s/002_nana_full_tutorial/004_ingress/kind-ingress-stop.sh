#!/usr/bin/env bash

#---------------------------
# variables definitions
#---------------------------
EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMETERS=0
ABK_LIB_FILE="$HOME/abkBin/abkLib.sh"
HELM_RELEASE_NAME="ingress-nginx"
HELM_NAMESPACE="ingress-nginx"
HELM_REPO_NAME="ingress-nginx"


#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode() {
    echo "$0 will uninstall nginx ingress controller in kind"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo -e "$2"
    echo "errorExitCode = $1"
    exit "$1"
}


ValidateHelmInstallation() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]}"
    if ! command -v helm &> /dev/null; then
        PrintTrace $TRACE_ERROR "Helm is not installed"
        return 1
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}


UninstallIngressController() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]}"
    local LCL_EXIT_CODE=0

    if helm list -n "$HELM_NAMESPACE" --filter "^$HELM_RELEASE_NAME\$" | grep -q "$HELM_RELEASE_NAME"; then
        PrintTrace $TRACE_INFO "Uninstalling ingress controller..."
        helm uninstall "$HELM_RELEASE_NAME" -n "$HELM_NAMESPACE"
        LCL_EXIT_CODE=$?

        # Optional: delete namespace if no other resources are present
        if kubectl get namespace "$HELM_NAMESPACE" &> /dev/null; then
            PrintTrace $TRACE_INFO "Deleting namespace $HELM_NAMESPACE..."
            kubectl delete namespace "$HELM_NAMESPACE"
        fi
    else
        PrintTrace $TRACE_INFO "Ingress controller not found; nothing to uninstall"
    fi

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

RemoveHelmRepo() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]}"
    if helm repo list | grep -q "$HELM_REPO_NAME"; then
        PrintTrace $TRACE_INFO "Removing Helm repo $HELM_REPO_NAME..."
        helm repo remove "$HELM_REPO_NAME"
    else
        PrintTrace $TRACE_INFO "Helm repo $HELM_REPO_NAME not found"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

#---------------------------
# main
#---------------------------
if [ -f "$ABK_LIB_FILE" ]; then
    source "$ABK_LIB_FILE"
else
    echo "ERROR: cannot find $ABK_LIB_FILE"
    echo "  $ABK_LIB_FILE contains common definitions and functions"
    exit 1
fi

echo
PrintTrace $TRACE_FUNCTION "-> $0 ($*)"

[ "$#" -ne $EXPECTED_NUMBER_OF_PARAMETERS ] && PrintUsageAndExitWithCode 1 "ERROR: invalid number of parameters, expected: $EXPECTED_NUMBER_OF_PARAMETERS"
ValidateHelmInstallation || PrintUsageAndExitWithCode $? "Please install helm first"
UninstallIngressController || PrintUsageAndExitWithCode $? "Failed to uninstall ingress controller"
RemoveHelmRepo || PrintUsageAndExitWithCode $? "Failed to remove helm repo"

echo
PrintTrace $TRACE_FUNCTION "<- $0 ($EXIT_CODE)"
exit $EXIT_CODE
