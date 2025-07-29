#! /bin/bash

echo "Current Date on the machine"
echo "------------------------------------------------"
date
echo
echo "GoCD User Defined Environment Variables"
echo "------------------------------------------------"
echo "\$ABK_ARTIFACTS_DIR               = $ABK_ARTIFACTS_DIR" 
echo "\$ABK_TEST_DLLS_DIR               = $ABK_TEST_DLLS_DIR"
echo "\$ABK_SHELL_SCRIPTS_DIR           = $ABK_SHELL_SCRIPTS_DIR"
echo "\$ABK_UI_TEST_DLL                 = $ABK_UI_TEST_DLL"
echo "\$ABK_UNIT_TEST_DLL               = $ABK_UNIT_TEST_DLL"
echo "\$ABK_APP_DIR                     = $ABK_APP_DIR"
echo "\$ABK_ANDROID_UI_TEST_DIR         = $ABK_ANDROID_UI_TEST_DIR"
echo "\$ABK_IOS_UI_TEST_DIR             = $ABK_IOS_UI_TEST_DIR"
echo
echo "GoCD Environment Variables"
echo "------------------------------------------------"
echo "\$MONO_PATH               = $MONO_PATH"
echo "\$GO_SERVER_URL           = $GO_SERVER_URL"
echo "\$GO_ENVIRONMENT_NAME     = $GO_ENVIRONMENT_NAME"
echo "\$GO_PIPELINE_NAME        = $GO_PIPELINE_NAME"
echo "\$GO_PIPELINE_COUNTER     = $GO_PIPELINE_COUNTER"
echo "\$GO_PIPELINE_LABEL       = $GO_PIPELINE_LABEL"
echo "\$GO_STAGE_NAME           = $GO_STAGE_NAME"
echo "\$GO_STAGE_COUNTER        = $GO_STAGE_COUNTER"
echo "\$GO_JOB_NAME             = $GO_JOB_NAME"
echo "\$GO_TRIGGER_USER         = $GO_TRIGGER_USER"
echo "\$GO_REVISION             = $GO_REVISION"
echo "\$GO_TO_REVISION          = $GO_TO_REVISION"
echo "\$GO_FROM_REVISION        = $GO_FROM_REVISION"
echo "\$GO_DEPENDENCY_LABEL_\${GO_PIPELINE_NAME} = $GO_DEPENDENCY_LABEL_${GO_PIPELINE_NAME}"
echo "\$GO_DEPENDENCY_LOCATOR_\${GO_PIPELINE_NAME} = $GO_DEPENDENCY_LOCATOR_${GO_PIPELINE_NAME}"
# echo "\$GO_REVISION_${material name or dest} = $GO_REVISION_${material name or dest}"
# echo "\$GO_TO_REVISION_${material name or dest} = $GO_TO_REVISION_${material name or dest}"
# echo "\$GO_FROM_REVISION_${material name or dest} = $GO_FROM_REVISION_${material name or dest}"
# echo "\$GO_MATERIAL_HAS_CHANGED = $GO_MATERIAL_HAS_CHANGED"
# echo "\$GO_MATERIAL_${material name or dest}_HAS_CHANGED = $GO_MATERIAL_${material name or dest}_HAS_CHANGED"
echo
echo "List All Unix Environment Variables"
echo "------------------------------------------------"
declare -xp | cut -d" " -f3-
# echo "\$HOME    = $HOME"
# echo "\$SHELL   = $SHELL"
# echo "\$PWD     = $PWD"
# echo "\$PATH    = $PATH"
echo
echo "Nuget Location and Version"
echo "------------------------------------------------"
which nuget
nuget help
echo
echo "Content of Current Directory"
echo "------------------------------------------------"
ls -la
echo
exit 0