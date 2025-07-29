#!/bin/bash

LCL_SQLITE_DB=abkcompa_shDev
LCL_SQLITE_DB_FILE=$LCL_SQLITE_DB.db
LCL_SQLITE_INIT=sqlite_init.sql
LCL_SQLITE_EXE=sqlite3
LCL_FLYWAY_EXE=flyway
LCL_FLYWAY_CONF=abkcompa_shDev.conf

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_MISUSE_OF_SHELL_BUILT_INS=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3
ERROR_CODE_NOT_VALID_PARAMETER=4
ERROR_CODE=$ERROR_CODE_SUCCESS


type $LCL_SQLITE_EXE >/dev/null 2>&1 || { echo >&2 "$LCL_SQLITE_EXE is not installed. Aborting."; exit $ERROR_CODE_GENERAL_ERROR; }

type $LCL_FLYWAY_EXE >/dev/null 2>&1 || { echo >&2 "$LCL_FLYWAY_EXE is not installed. Aborting."; exit $ERROR_CODE_GENERAL_ERROR; }


if [ -f $LCL_SQLITE_DB_FILE ]; then
    echo "SQLite db file $LCL_SQLITE_DB_FILE exists"
else
    echo "SQLite db file $LCL_SQLITE_DB_FILE does not exist, creating it"
    # $LCL_SQLITE_EXE $LCL_SQLITE_DB_FILE "ATTACH DATABASE '$LCL_SQLITE_DB_FILE' AS '$LCL_SQLITE_DB' .databases .quit;"
    $LCL_SQLITE_EXE $LCL_SQLITE_DB_FILE -init $LCL_SQLITE_INIT
    # touch $LCL_SQLITE_DB_FILE
    $LCL_FLYWAY_EXE -url=jdbc:sqlite:$LCL_SQLITE_DB -user= -password= -configFiles=$LCL_FLYWAY_CONF baseline
fi

# echo "starting ssh on $LCL_SSH_PORT:127.0.0.1:3306 $HOST"
# ssh -f -N -T -M -L $LCL_SSH_PORT:127.0.0.1:3306 $HOST
# echo "ssh connection opened with $?"
# ERROR_CODE=$?

if [ "$ERROR_CODE" -eq $ERROR_CODE_SUCCESS ]; then
    echo "+----------------------------------------+"
    echo "| Flyway schema version before migration |"
    echo "+----------------------------------------+"
    # flyway -configFiles=flywayDbConnection.conf -configFiles=abkcompa_shDev.conf info
    $LCL_FLYWAY_EXE -url=jdbc:sqlite:$LCL_SQLITE_DB -user= -password= -configFiles=$LCL_FLYWAY_CONF info
    echo "+----------------------------------------+"
    echo "| Flyway schema migration                |"
    echo "+----------------------------------------+"
    # flyway -configFiles=flywayDbConnection.conf -configFiles=abkcompa_shDevLocal.conf migrate
    $LCL_FLYWAY_EXE -url=jdbc:sqlite:$LCL_SQLITE_DB -user= -password= -configFiles=$LCL_FLYWAY_CONF migrate
    ERROR_CODE=$?
    echo "+----------------------------------------+"
    echo "| Flyway schema version after migration  |"
    echo "+----------------------------------------+"
    # flyway -configFiles=flywayDbConnection.conf -configFiles=abkcompa_shDevLocal.conf info
    $LCL_FLYWAY_EXE -url=jdbc:sqlite:$LCL_SQLITE_DB -user= -password= -configFiles=$LCL_FLYWAY_CONF info
fi

# echo "closing ssh connection ..."
# ssh -T -O "exit" $HOST
# echo "ssh connection closed with $?"

if [ "$ERROR_CODE" -ne $ERROR_CODE_SUCCESS ]; then
    echo "\$ERROR_CODE = $ERROR_CODE"
    exit $ERROR_CODE
fi
echo "\$? = $?"
exit $?
