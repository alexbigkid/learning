#!/bin/bash

#------------------------------------------------------------------------------
# variables definitions
#------------------------------------------------------------------------------
SEA_K8S_CLUSTER_NAME='sea-aai-agent'
SEA_K8S_CONFIG_TEMPLATE_FILE='sea/k8s-kind-config.template.yaml'
SEA_AG_K8S_CONFIG_FILE='sea/ag-k8s-kind-config.yaml'
# SEA_AG_K8S_CONFIG_MAP_FILE='sea/ag-k8s-config-map.yaml'
SEA_KANIKO_PVC_FILE='sea/sea-kaniko-pvc.yaml'
# SEA_KANIKO_JOB_TEMPLATE_FILE='sea/sea-kaniko-job.template.yaml'
SEA_KANIKO_POD_TEMPLATE_FILE='sea/sea-kaniko-pod.template.yaml'
SEA_KANIKO_POD_BASE_FILE='sea/ag-sea-kaniko-pod'
# SEA_AG_KANIKO_JOB_FILE='sea/ag-sea-kaniko-job.yaml'
# SEA_K8S_POD_CONFIG_FILE='sea/sea-kaniko-pod.yaml'
SEA_SUPPORTED_VERSION_FILE='sea/sea-supported-versions.json'
SEA_COMMON_LIB_FILE="scripts/common-lib.sh"
SEA_REQUIRED_TOOLS=( jq gettext kind kubectl )
SEA_K8S_TIMEOUT=120
SEA_K8S_TIMEOUT_INTERVAL=4
SEA_K8S_POD_TIMEOUT=120

EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMS=0
SEA_NODE_PACKAGE_FILE="package.json"


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

    # create k8s volume config from template
    PrintTrace $TRACE_INFO "Creating $SEA_AG_K8S_CONFIG_FILE ..."
    envsubst < "$SEA_K8S_CONFIG_TEMPLATE_FILE" > "$SEA_AG_K8S_CONFIG_FILE"

    # Creating K8s
    PrintTrace $TRACE_INFO "Creating Kubernetes cluster: $SEA_K8S_CLUSTER_NAME from $SEA_AG_K8S_CONFIG_FILE"
    kind create cluster --name "$SEA_K8S_CLUSTER_NAME" --config "$SEA_AG_K8S_CONFIG_FILE"
    PrintTrace $TRACE_INFO "Creating Kubernetes namespace: $SEA_K8S_CLUSTER_NAME"
    kubectl create namespace "$SEA_K8S_CLUSTER_NAME"
    PrintTrace $TRACE_INFO "Creating Kubernetes volume from file: $SEA_KANIKO_PVC_FILE"
    kubectl apply -f "$SEA_KANIKO_PVC_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    WaitUntilVolumeIsBound "sea-kaniko-pvc" "$SEA_K8S_CLUSTER_NAME"

    for SEA_OS_TYPE in $(jq -r 'keys[]' "$SEA_SUPPORTED_VERSION_FILE"); do
        for SEA_OS_VERSION in $(jq -r --arg SEA_OS_TYPE "$SEA_OS_TYPE" '.[$SEA_OS_TYPE] | keys[]' "$SEA_SUPPORTED_VERSION_FILE"); do
            for SEA_OS_ARCH in $(jq -r --arg SEA_OS_TYPE "$SEA_OS_TYPE" --arg SEA_OS_VERSION "$SEA_OS_VERSION" '.[$SEA_OS_TYPE][$SEA_OS_VERSION][]' "$SEA_SUPPORTED_VERSION_FILE"); do
                # build_sea_binary "$LCL_REMOTE_DOCKER_IMAGE" "$LCL_VERSION" "$SEA_OS_TYPE" "$SEA_OS_VERSION" "$SEA_OS_ARCH" || return $?
                # LCL_ARGS+=("build_sea_binary $LCL_REMOTE_DOCKER_IMAGE $LCL_VERSION $SEA_OS_TYPE $SEA_OS_VERSION $SEA_OS_ARCH")
                LCL_ARGS+=("$SEA_OS_TYPE-$SEA_OS_VERSION-$SEA_OS_ARCH")
                PrintTrace $TRACE_DEBUG "SEA_OS_TYPE: $SEA_OS_TYPE, SEA_OS_VERSION: $SEA_OS_VERSION, SEA_OS_ARCH = $SEA_OS_ARCH"
                BuildSeaBinary "$LCL_VERSION" "$SEA_OS_TYPE" "$SEA_OS_VERSION" "$SEA_OS_ARCH" || LCL_EXIT_CODE=$?
            done
        done
    done

    # create k8s ConfigMap
    # PrintTrace $TRACE_INFO "Creating ConfigMap from file: $SEA_AG_K8S_CONFIG_MAP_FILE"
    # CreateConfigMapFile "${LCL_ARGS[@]}"
    # kubectl apply -f "$SEA_AG_K8S_CONFIG_MAP_FILE" -n "$SEA_K8S_CLUSTER_NAME"

    # create k8s kaniko job
    # PrintTrace $TRACE_INFO "Creating kaniko Job from file: $SEA_AG_KANIKO_JOB_FILE"
    # CreateKanikoJobFile ${#LCL_ARGS[@]}
    # kubectl apply -f "$SEA_AG_KANIKO_JOB_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    # kubectl get jobs -n "$SEA_K8S_CLUSTER_NAME"
    # kubectl wait --for=condition=complete --timeout="${SEA_K8S_TIMEOUT}s" job/kaniko-job -n "$SEA_K8S_CLUSTER_NAME"

    # parallel --halt now,fail=1 build_sea_binary "$LCL_REMOTE_DOCKER_IMAGE" ::: "debian" ::: "12" ::: "arm64v8"
    # parallel --halt now,fail=1 ::: "${LCL_ARGS[@]}"
    # LCL_EXIT_CODE=$?


    # Cleanup K8s
    # PrintTrace $TRACE_INFO "Deleting kaniko pod from file: $SEA_K8S_POD_CONFIG_FILE"
    # kubectl delete -f "$SEA_K8S_POD_CONFIG_FILE" -n "$SEA_K8S_CLUSTER_NAME"

    # PrintTrace $TRACE_INFO "Deleting kaniko Job from file: $SEA_AG_KANIKO_JOB_FILE"
    # kubectl delete -f "$SEA_AG_KANIKO_JOB_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    # PrintTrace $TRACE_INFO "Deleting ConfigMap from file: $SEA_AG_K8S_CONFIG_MAP_FILE"
    # kubectl delete -f "$SEA_AG_K8S_CONFIG_MAP_FILE" -n "$SEA_K8S_CLUSTER_NAME"

    PrintTrace $TRACE_INFO "Deleting Kubernetes volume from file: $SEA_KANIKO_PVC_FILE"
    kubectl delete -f "$SEA_KANIKO_PVC_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    PrintTrace $TRACE_INFO "Deleting all resources in namespace: $SEA_K8S_CLUSTER_NAME"
    kubectl delete all --all -n "$SEA_K8S_CLUSTER_NAME"
    PrintTrace $TRACE_INFO "Deleting Kubernetes namespace: $SEA_K8S_CLUSTER_NAME"
    kubectl delete namespace "$SEA_K8S_CLUSTER_NAME"
    PrintTrace $TRACE_INFO "Deleting Kubernetes cluster: $SEA_K8S_CLUSTER_NAME"
    kind delete cluster --name "$SEA_K8S_CLUSTER_NAME"

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
    local LCL_NODE_MAJOR="20"
    # local LCL_DOCKER_FILE="sea/docker/Dockerfile.$LCL_LCL_OS_TYPE"
    local LCL_EXIT_CODE=0

    [ "$LCL_BIN_ARCH" == "arm64v8" ] && LCL_BIN_ARCH="arm64"
    [ "$LCL_BIN_ARCH" == "arm32v7" ] && LCL_BIN_ARCH="arm"

    PrintTrace $TRACE_DEBUG "LCL_BIN_VERSION        = $LCL_BIN_VERSION"
    PrintTrace $TRACE_DEBUG "LCL_OS_TYPE            = $LCL_OS_TYPE"
    PrintTrace $TRACE_DEBUG "LCL_OS_IMAGE_VERSION   = $LCL_OS_IMAGE_VERSION"
    PrintTrace $TRACE_DEBUG "LCL_OS_IMAGE_ARCH      = $LCL_OS_IMAGE_ARCH"
    PrintTrace $TRACE_DEBUG "LCL_BIN_ARCH           = $LCL_BIN_ARCH"
    PrintTrace $TRACE_DEBUG "LCL_NODE_MAJOR         = $LCL_NODE_MAJOR"
    export BIN_VERSION=$LCL_BIN_VERSION
    export OS_TYPE=$LCL_OS_TYPE
    export OS_IMAGE_VERSION=$LCL_OS_IMAGE_VERSION
    export OS_IMAGE_ARCH=$LCL_OS_IMAGE_ARCH
    export BIN_ARCH=$LCL_BIN_ARCH
    export NODE_MAJOR=$LCL_NODE_MAJOR

    local LCL_KANIKO_POD_FILE="${SEA_KANIKO_POD_BASE_FILE}-${LCL_OS_TYPE}-${LCL_OS_IMAGE_VERSION}-${LCL_OS_IMAGE_ARCH}.yaml"
    PrintTrace $TRACE_INFO "Creating kaniko pod from file: $LCL_KANIKO_POD_FILE ..."
    envsubst < "$SEA_KANIKO_POD_TEMPLATE_FILE" > "$LCL_KANIKO_POD_FILE"
    kubectl apply -f "$LCL_KANIKO_POD_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    # local LCL_KANIKO_POD_NAME="kaniko-${LCL_OS_TYPE}-${LCL_OS_IMAGE_VERSION}-${LCL_OS_IMAGE_ARCH}"
    local LCL_KANIKO_POD_NAME="kaniko"
    kubectl wait --for=condition=containersready pod "$LCL_KANIKO_POD_NAME" --timeout="${SEA_K8S_POD_TIMEOUT}s" -n "$SEA_K8S_CLUSTER_NAME"
    kubectl logs "$LCL_KANIKO_POD_NAME" --follow -n "$SEA_K8S_CLUSTER_NAME"

    PrintTrace $TRACE_INFO "Deleting kaniko pod from file: $LCL_KANIKO_POD_FILE ..."
    kubectl delete -f "$LCL_KANIKO_POD_FILE" -n "$SEA_K8S_CLUSTER_NAME"
    kubectl wait --for=delete "pod/$LCL_KANIKO_POD_NAME" --timeout="${SEA_K8S_POD_TIMEOUT}s" -n "$SEA_K8S_CLUSTER_NAME"

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)\n"
    return $LCL_EXIT_CODE
}

# CreateConfigMapFile() {
#     PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
#     local LCL_OS_COMBINATIONS=("$@")

#     PrintTrace $TRACE_DEBUG "Generating K8s config map: $SEA_AG_K8S_CONFIG_MAP_FILE"
#     cat <<EOF > "$SEA_AG_K8S_CONFIG_MAP_FILE"
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: sea-kaniko-config
# data:
#   combinations: |
# EOF

#     for LCL_ITEM in "${LCL_OS_COMBINATIONS[@]}"; do
#         echo "    $LCL_ITEM" >> "$SEA_AG_K8S_CONFIG_MAP_FILE"
#     done

#     PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
#     return 0
# }


# CreateKanikoJobFile() {
#     PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
#     local LCL_NUMBER_OF_PODS=$1
#     local LCL_NUM_OF_CORES=8

#     # common_get_number_of_cores LCL_NUM_OF_CORES

#     # PrintTrace $TRACE_INFO "Creating Kaniko Job File: $SEA_AG_KANIKO_JOB_FILE ..."
#     export NUM_OF_PODS_TO_COMPLETE=$LCL_NUMBER_OF_PODS
#     export NUM_OF_CONCURRENT_PODS=$LCL_NUM_OF_CORES
#     export JOB_TTL_SECONDS=$SEA_K8S_TIMEOUT
#     envsubst < "$SEA_KANIKO_JOB_TEMPLATE_FILE" > "$SEA_AG_KANIKO_JOB_FILE"

#     PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
#     return 0
# }


WaitUntilVolumeIsBound() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_PVC_NAME=$1
    local LCL_NAMESPACE=$2
    local LCL_ELAPSED=0

    until kubectl get pvc "$LCL_PVC_NAME" -n "$LCL_NAMESPACE" | grep -q "Bound"; do
        if [[ $LCL_ELAPSED -ge $SEA_K8S_TIMEOUT ]]; then
            PrintTrace $TRACE_ERROR "Timeout reached: bbp-kaniko-pvc did not become bound within $SEA_K8S_TIMEOUT seconds."
            return 1
        fi
        sleep $SEA_K8S_TIMEOUT_INTERVAL
        LCL_ELAPSED=$((LCL_ELAPSED + SEA_K8S_TIMEOUT_INTERVAL))
        PrintTrace $TRACE_DEBUG "Waiting for $LCL_PVC_NAME to be bound... (elapsed time: $LCL_ELAPSED seconds)"
    done

    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}


CreateTarZipFile() {
    PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($*)"
    local LCL_BIN_VERSION=$1
    local LCL_TAR_FILE="bin/aai-agent-${LCL_BIN_VERSION}.tar.gz"
    local LCL_EXIT_CODE=0

    PrintTrace $TRACE_INFO "Before tar pack"
    tree bin

    PrintTrace $TRACE_INFO "Packing tar file: $LCL_TAR_FILE"
    [ -d "bin/${LCL_BIN_VERSION}" ] && tar -czvf "$LCL_TAR_FILE" "bin/${LCL_BIN_VERSION}" && rm -r "bin/${LCL_BIN_VERSION}"

    PrintTrace $TRACE_INFO "After tar pack"
    tree bin

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
