#!/usr/bin/env bash

#---------------------------
# variables definitions
#---------------------------
EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMETERS=0
ABK_LIB_FILE="$HOME/abkBin/abkLib.sh"
KCTL_NAMESPACE="ingress-nginx"
HELM_REPO_NAME="ingress-nginx"
HELM_REPO_URL="https://kubernetes.github.io/$HELM_REPO_NAME"


#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode() {
    echo "$0 will setup nginx ingress controller in kind"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo -e $2
    echo "errorExitCode = $1"
    exit $1
}


ValidateHelmInstallation() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]}"
    local LCL_EXIT_CODE=0
    if ! command -v helm &> /dev/null; then
        LCL_EXIT_CODE=1
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


AddHelmRepo() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]} ($*)"
    local LCL_EXIT_CODE=0
    local REPO_NAME=$1
    local REPO_URL=$2

    if ! helm repo list | grep -q "$REPO_NAME"; then
        helm repo add $REPO_NAME $REPO_URL
        LCL_EXIT_CODE=$?
    fi
    [ $LCL_EXIT_CODE -eq 0 ] && helm repo update
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


InstallIngressController() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]} ($*)"
    local LCL_NAMESPACE="${1:-default}"
    local LCL_EXIT_CODE=0

    if ! helm list -n "$LCL_NAMESPACE" --filter '^ingress-nginx$' | grep -q 'ingress-nginx'; then
    PrintTrace $TRACE_INFO "Ingress controller not installed. Installing..."
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace "$LCL_NAMESPACE" --create-namespace \
        --set controller.service.type=NodePort \
        --set controller.service.nodePorts.http=30080 \
        --set controller.service.nodePorts.https=30443 \
        --set controller.hostNetwork=true \
        --set controller.kind=Deployment
        LCL_EXIT_CODE=$?
    else
        PrintTrace $TRACE_INFO "Ingress controller is already installed"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


PrintRunningNginxIngressController() {
    PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]} ($*)"
    local LCL_NAMESPACE="${1:-default}"
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Checking if ingress controller is running"
    if helm list -n "$LCL_NAMESPACE" --filter '^ingress-nginx$' | grep -q 'ingress-nginx'; then
        PrintTrace $TRACE_INFO "${GRN}Ingress controller is running${NC}"
        kubectl get pods -n "$LCL_NAMESPACE"
    else
        PrintTrace $TRACE_INFO "Ingress controller is not running"
    fi
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


#---------------------------
# main
#---------------------------
if [ -f $ABK_LIB_FILE ]; then
    source $ABK_LIB_FILE
else
    echo "ERROR: cannot find $ABK_LIB_FILE"
    echo "  $ABK_LIB_FILE contains common definitions and functions"
    exit 1
fi

echo
PrintTrace $TRACE_FUNCTION "-> $0 ($*)"

[ "$#" -ne $EXPECTED_NUMBER_OF_PARAMETERS ] && PrintUsageAndExitWithCode 1 "ERROR: invalid number of parameters, expected: $EXPECTED_NUMBER_OF_PARAMETERS"
ValidateHelmInstallation || PrintUsageAndExitWithCode $? "${RED}Please install helm first${NC}"
AddHelmRepo "$HELM_REPO_NAME" "$HELM_REPO_URL" || PrintUsageAndExitWithCode $? "${RED}Please install helm first${NC}"
InstallIngressController "$KCTL_NAMESPACE" || PrintUsageAndExitWithCode $? "${RED}Failed to install ingress controller${NC}"
PrintRunningNginxIngressController "$KCTL_NAMESPACE"

# # Fetch and base64 encode secrets
# USER_B64=$(pass dev/k8s/demo/mongo-user | tr -d '\n'| base64)
# PASSWORD_B64=$(pass dev/k8s/demo/mongo-password | tr -d '\n' | base64)

# # Export variables for envsubst
# export USER_B64
# export PASSWORD_B64

# # Substitute and write to output file
# envsubst < mongo-secret.template.yaml > mongo-secret.yaml
# echo "Secret written to mongo-secret.yaml"


echo
PrintTrace $TRACE_FUNCTION "<- $0 ($EXIT_CODE)"
exit $EXIT_CODE
