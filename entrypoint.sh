#!/bin/bash
# Created by Fabien Kerbouci <fkerbouci@opensense.fr> - 09/02/2016
#
# Apache Licence 2.0
#
# After that you read and understand the comments you can delete them to keep a shorter
# entrypoint script to read and edit.
#

function editMe {
    ####
    # If the variables specified here are not set in the environment, the launch will fail
    # and an error message will be reported.
    #
    # Syntax is: 'VARIABLE_NAME:Description'
    ####
    MANDATORY_ENV_VARIABLES=(
	'ENV_KAFKA_HOST:the Kafka broker public hostname'
	'ENV_MONGO_HOST:the MongoDB server hostname'
    )

    ####
    # If the variables specified here are not set in the environment, the launch will not fail
    # but a warning will be printed and the variables will take the specified default values.
    #
    # Syntax is: ['VARIABLE_NAME:DESCRIPTION']=DEFAULT_VALUE
    ####
    OPTIONAL_ENV_VARIABLES=(
	['ENV_KAFKA_PORT:the Kafka broker public port for connections']=9092
	['ENV_MONGO_PORT:the MongoDB server port for connections']=27017
    )

    ####
    # This is the list of the files that will have their content replaced according to the
    # CONFIGURATION_FILES_REPLACEMENTS array, seen later on. Configuration files that must not
    # be rewritten should not appear here.
    #
    # Syntax is: ['SourceFilePath']='FinalFilePath'
    #
    # What will happen is:
    # 1. The SourceFilePath will have its content replaced according to
    #    CONFIGURATION_FILE_REPLACEMENTS
    # 2. If FinalFilePath is not an empty string (aka '') then the SourceFilePath will be 
    #    moved to FinalFilePath (SourceFilePath will thus be deleted). If the string is 
    #    empty, the file will not be moved.
    #
    # Note: you MUST have a writeable /tmp directory inside your container.
    ####
    CONFIGURATION_FILES=(
    ["/$SERVICE_NAME/config/general.yaml.template"]="/$SERVICE_NAME/config/general.yaml"
	# ['/myfolder/config.1.src']='/my/dest/folder/config.1.dst'
	# ['config.2.src']=''
    )

    ####
    # This is where you set what to replace in configuration files. The content used for
    # replacements are usually the environment variables defined previously but you can replace
    # whatever you want with whatever you want.
    #
    # Syntax is: ['CookieToMatch']='ContentToReplaceCookieWith'
    #
    # What will happen is:
    # 1. Each file in CONFIGURATION_FILES will have their content replaced following the matches in
    #    CONFIGURATION_FILES_REPLACEMENTS below
    # 2. Rewritten configuration files will then be moved accordingly to CONFIGURATION_FILES above.
    #
    # Note: Requires a valid /tmp directory to be writeable for current user.
    ####
    CONFIGURATION_FILES_REPLACEMENTS=(
    ['{REPLACE_SERVICE_NAME}']="$SERVICE_NAME"
	['{REPLACE_KAFKA_HOST}']="${ENV_KAFKA_HOST}"
	['{REPLACE_KAFKA_PORT}']="${ENV_KAFKA_PORT}"
	['{REPLACE_MONGO_HOST}']="${ENV_MONGO_HOST}"
	['{REPLACE_MONGO_PORT}']="${ENV_MONGO_PORT}"
	['{REPLACE_OFFSET_STORAGE_FOLDER}']="/var/run/corpact-records/"
    )

    ####
    # Add your command lines to start the entrypoints (your apps) and specify how to stop them!
    #
    # Syntax is: ['FullCommandLineForStart']='FullCommandLineForStop:CrashPolicy'
    #
    # FullCommandLineForStart must be a shell line that runs only ONE executable program having 
    # a PID. You can have shell built-in commands (such as 'cd', 'echo', etc.) preceding your 
    # command, but if you ONLY define shell built-in commands, then  you will have issues and 
    # the monitoring of your command will fail (because it will not have a correct PID).
    #
    # If you only wish to run single built-in shell commands then you probably should use the 
    # PRESTART_COMMANDS feature above.
    #
    # FullCommandLineForStop accepts two pre-defined shortcuts or any arbitrary string:
    #    + 'KILL' -> Will send a SIGKILL on the last PID obtained for FullCommandLineForStart
    #    + 'TERM' -> Will send a SIGTERM on the last PID obtained for FullCommandLineForStart
    #      (should be handled by the receiving process)
    #    + Other strings will be executed as is (eg: 'service myServer stop',
    #      'ps -a ... | grep ...', etc.), so feel free to input your own graceful stop command.
    #
    # CrashPolicy accepts four pre-defined values:
    #    + ENDALLNOBLOCK -> will try to execute all stop commands, will wait 5 seconds and will
    #      quit forcingly (guaranteed exit)
    #    + ENDALLBLOCK -> will try to execute all stop commands, it might block if one of the stop
    #      command hangs (unguaranteed exit but might be quicker than guaranteed one depending of
    #      exit command)
    #    + RETRY -> will re-execute FullCommandLineForStart to try restarting the crashed process
    #    + IGNORE -> will do nothing but still reports a crash
    #
    # The specified entrypoints MUST never quit or return : all commands are started in background,
    # in the order specified, and then constantly monitored for cases of failures (detection of end
    # of execution).
    #
    # The FullCommandLineForStop are also executed when the container is being stopped by Docker
    # or when pressing CTRL+C in docker's interactive terminal mode. In this case the crash policy
    # does not matter and is not executed.
    #
    # When the script detects a crash (the PID does not exist anymore) then the crash policy will
    # apply for the specified command.
    #
    # Also note that the entrypoints are executed in an _unpredictable_ order, and disrespectful of the
    # order you might write them below. Those are the limitations of the associative arrays (hash
    # tables) in bash. So keep in mind that the execution order of your entrypoints should NOT matter.
    #
    # Reminder: only _one_ executable command (program) per entry below.
    ####
    ENTRYPOINTS=(
     ["/usr/bin/python3.4 /$SERVICE_NAME/bin/start.py"]='KILL:RETRY'  
	# ['sleep 0.1']='KILL:IGNORE'
	# ['sleep 2']='KILL:RETRY'
	# ['sleep 5']='KILL:ENDALLBLOCK'
	# ['sleep 200']='killall sleep:IGNORE'
	# ['sleep 100']='KILL:IGNORE'
    )

    ####
    # Add your custom extra commands here.
    #
    # Syntax is: ['FullLineCommand']=Timer
    #
    # 'Timer' is any float or integer value that is used to wait X seconds before executing
    # the specific command: 0 means that the command is instantly executed, 1 after 1 second, etc.
    #
    # PRESTART_COMMANDS will be executed just before launching your entrypoints, useful for
    # preparing your environment.
    #
    # POSTSTART_COMMANDS will be executed just after that all of your entrypoints have been
    # executed.
    #
    # If you need to, you can use your environment variables here.
    #
    # Unfortunately, the commands are executed in an _unpredictable_ order, and disrespectful of the
    # order you might write them below. On top of that, any Timer for a command will delay the
    # execution of the next commands. It might be confusing, but those are the limitations of the
    # associative arrays (hash tables) in bash. So, keep in mind that the order should NOT matter.
    #
    # If you want an ordered execution of commands, then build multi-part/complex command lines.
    #
    # Note: the commands are not monitored against crashes or return values, and are run only once.
    ####
    PRESTART_COMMANDS=(
	['echo "I am starting!"']=0
	['cat /etc/passwd']=2
    )
    POSTSTART_COMMANDS=(
	['echo "I have started!" && ls -al']=0
	['ls -al /']=2
    )

    ####
    # The POSTEND_COMMANDS below will be executed just before the whole script exits. 
    #
    # Syntax is: 'FullLineCommand'
    #
    # These commands are guaranteed to be executed, but you must ensure that they do NOT block,
    # otherwise it could hinder your crash policy settings or behavior.
    #
    # Unlike START commands, POSTEND_COMMANDS do not handle any timer by design. They also are executed
    # in the order of your input.
    #
    ####
    POSTEND_COMMANDS=(
	'echo "I have ended!"'
	'ls -al /tmp/'
    )

    ####
    # GLOBAL_STOP_POLICY defines what should happen when docker tries to stop the container or when
    # you press CTRL+C.
    #
    # It only accepts two values:
    #
    #    + 'ENDALLNOBLOCK' -> will try to execute all stop commands, will wait 5 seconds and will
    #      quit forcingly (guaranteed exit)
    #
    #    + 'ENDALLBLOCK' -> will try to execute all stop commands, it might block if one of the
    #      stop command hangs (but might also be quicker than guaranteed one depending of your
    #      stop commands)
    ####
    GLOBAL_STOP_POLICY="ENDALLBLOCK"

    ####
    # Defines all the text log files to print on STDOUT and to empty after printing them
    # Useful when you cannot flush some logs on stdout for whatever limitation you are facing
    ####
    LOGFILES_TO_FLUSH=(
	# '/var/log/yum/log'
    )

    ####
    # Reset commands are used when the environment variable RESET_CONTAINER is set (no matter its
    # value).
    # The config files are written, and all the reset commands are executed in order. However, nothing
    # else than those commands are executed:
    #    - PRESTART, POSTSTART and POSTEND commands are not executed
    #    - Entrypoints are not executed
    #
    # Once all the commands are executed (succesffully or not) the script will hang infinitely, giving
    # you time to review the logs and kill it by yourself (then CTRL+C or docker stop will work).
    #
    # You will use the RESET_CONTAINER feature when you need to delete files or databases or make more
    # specific cleanups. You can run your own shell commands or specific application scripts.
    #
    # Note: using environment variables should work here. 
    ####
    RESET_COMMANDS=(
	'echo "I am deleting all your files!"'
	'echo "I am now deleting $HOME"'
    )
}

#
# END OF EDITABLE SECTION -- YOU SHOULD NOT EDIT PAST HERE!
#

# /!\ DO NOT MODIFY - Logger functions
function printError {
    DATE=$(date);echo "[${DATE}][ERROR@entrypoint]: $@"
}
function printWarn {
    DATE=$(date);echo "[${DATE}][WARNING@entrypoint]: $@"
}
function printLog {
    DATE=$(date);echo "[${DATE}][INFO@entrypoint]: $@"
}
 
# /!\ DO NOT MODIFY - If we have an argument for docker run, exec the argument and quit without
# running something else
if [ -n "$1" ]; then
    printLog "Running custom command: '$@'"
    eval $@
    exit 0
fi
 
# /!\ DO NOT MODIFY - Arrays creation
printLog 'Preparing environment...'
declare -a MANDATORY_ENV_VARIABLES
declare -a LOGFILES_TO_FLUSH
declare -a POSTEND_COMMANDS
declare -a RESET_COMMANDS
declare -A PRESTART_COMMANDS
declare -A POSTSTART_COMMANDS
declare -A ENTRYPOINTS
declare -A WATCHED_PROCESSES
declare -A OPTIONAL_ENV_VARIABLES
declare -A CONFIGURATION_FILES
declare -A CONFIGURATION_FILES_REPLACEMENTS
# First call of editMe() will set all the mandatory stuff but not the optional variables
editMe

# /!\ DO NOT MODIFY - Execute the Reset commands, only if the RESET_CONTAINER environment variable is set
function resetContainer {
    if [ -z $RESET_CONTAINER ]; then
	# Environment variable is not set, ignoring reset feature.
	return
    fi
    printWarn "Reset mode is enabled! Nothing else than resetting the container will be done."
    for CMD in "${RESET_COMMANDS[@]}"; do
	printLog "Executing reset command: ${CMD}"
	eval ${CMD}
    done
    printLog "All the reset commands have been executed... Entering in sleep mode for eternity."
    trap "printLog 'End of execution is requested by Docker... Container is reset and terminated.' && exit 0" SIGHUP SIGINT SIGTERM SIGSTOP
    while true; do
	sleep 1000
    done
}

# /!\ DO NOT MODIFY - Flush all user-specified logs on stdout
function flushLogs {
    for LOGFILE in "${LOGFILES_TO_FLUSH[@]}"; do
        cat "${LOGFILE}" && echo -n "" > "${LOGFILE}" 2>&1 > /dev/null
    done
}

# /!\ DO NOT MODIFY - Makes the process quit
function exitNow {
    extraCommandsPostEnd
    sleep $1
    exit 0
}

# /!\ DO NOT MODIFY - this ends all the processes registered in ENTRYPOINTS
function endAll {
    if [ ${#WATCHED_PROCESSES[@]} == 0 ]; then
	printLog "There is nothing to terminate: all processes have already terminated."
	return
    fi
    printLog "Shutting down remaining processes (${#WATCHED_PROCESSES[@]})..."
    for PID in "${!WATCHED_PROCESSES[@]}"; do
        CMD="${WATCHED_PROCESSES[$PID]}"
	printLog "Starting termination of process '${CMD}'..."
        EXITCMD=$(echo ${ENTRYPOINTS[${CMD}]} | rev | cut -f 2- -d ':' | rev)
        # Ensure process is still running
        PROCESS=$(ps -p ${PID} -o comm=)
        if [ -z "${PROCESS}" ]; then
	    if [ "${EXITCMD}" == "TERM" ] || [ "${EXITCMD}" == "KILL" ]; then
		printLog "Process '${CMD}' with PID '${PID}' has already terminated. Continuing termination..."
		continue
	    fi
        fi
        # Process is still up, execute its stop command
        if [ "${EXITCMD}" == "KILL" ]; then
            printLog "Applying shortcut 'KILL': 'kill -9 ${PID}'..."
            kill -9 ${PID} 2>&1 > /dev/null
        elif [ "${EXITCMD}" == "TERM" ]; then
            printLog "Applying shortcut 'TERM': 'kill -15 ${PID}'..."
            kill -15 ${PID} 2>&1 > /dev/null
        else
            if [ "${1}" == "NOBLOCK" ]; then
		printLog "Executing full quit command '${EXITCMD}' in background..."
		eval ${EXITCMD} 2>&1 > /dev/null &
            else
		printLog "Applying full quit command '${EXITCMD}' and wait..."
                eval ${EXITCMD} 2>&1 > /dev/null
            fi
        fi
        if [ "${1}" == "BLOCK" ]; then
	    wait ${PID} 2> /dev/null
        fi
	printLog "Termination of process has been successfully handled."
    done
    if [ "${1}" == "NOBLOCK" ]; then
        printLog "All processes had their stop commands executed... Exiting in 5 seconds."
	exitNow 5
    else
        printLog "All processes had their stop commands executed with success... Exiting."
	exitNow 0
    fi
}
 
# /!\ DO NOT MODIFY - This starts everything and ensures crash detection / container stop
function startEntryPoints {
    printLog "Starting entry-points..."
    for CMD in "${!ENTRYPOINTS[@]}"; do
        eval ${CMD} &
        PID=$!
        printLog "'${CMD}' has PID '${PID}'"
        WATCHED_PROCESSES[${PID}]="${CMD}"
    done
    # Run the post-start commands
    extraCommandsPostStart
    printLog "Setting up crash handler and process monitoring..."
    trap "printLog 'End of execution is requested by Docker... Ending all processes according to global stop policy ${GLOBAL_STOP_POLICY}' && endAll ${GLOBAL_STOP_POLICY}" SIGHUP SIGINT SIGTERM SIGSTOP
    while true; do
        flushLogs
        # Loop over each PID to see if it is still alive, similar to a heartbeat
        for PID in "${!WATCHED_PROCESSES[@]}"; do
            PROCESS=$(ps -p ${PID} -o comm=)
            if [ -z $PROCESS ]; then
                printError "a program has crashed: '${WATCHED_PROCESSES[$PID]}'"
                CMD=${WATCHED_PROCESSES[$PID]}
                CRASHPOLICY=$(echo ${ENTRYPOINTS[$CMD]} | rev | cut -f 1 -d ':' | rev)
                # Remove the PID from list of PIDs to monitor
                unset WATCHED_PROCESSES[$PID]
                if [ "${CRASHPOLICY}" == "RETRY" ]; then
                    printLog "crash policy for process is 'RETRY', restarting the process..."
                    eval ${CMD} &
                    PID=$!
                    WATCHED_PROCESSES[${PID}]="${CMD}"
                elif [ "${CRASHPOLICY}" == "IGNORE" ]; then
                    printLog "crash policy for process is 'IGNORE', nothing is done..."
                elif [ "${CRASHPOLICY}" == "ENDALLNOBLOCK" ]; then
                    printLog "crash policy for process is 'ENDALLNOBLOCK', trying to end all processes and quit forcingly..."
                    endAll "NOBLOCK"
                elif [ "${CRASHPOLICY}" == "ENDALLBLOCK" ]; then
                    printLog "crash policy for process is 'ENDALLBLOCK', trying to end all processes and wait for them to finish..."
                    endAll "BLOCK"
                fi
            fi
        done
        if [ ${#WATCHED_PROCESSES[@]} == 0 ]; then
            printLog "No more process is running, exiting!"
	    exitNow 0
        fi
        sleep 0.2 # Consider this the heartbeat frequency...
    done
}

# /!\ DO NOT MODIFY - This is to run the eventual pre-start commands
function extraCommandsPreStart {
    printLog "Executing pre-start commands..."
    for CMD in "${!PRESTART_COMMANDS[@]}"; do
	TIMER="${PRESTART_COMMANDS[$CMD]}"
	sleep "${TIMER}"; printLog "Executing '${CMD}'"; eval ${CMD}
    done
}
 
# /!\ DO NOT MODIFY - This is to run the eventual post-start commands
function extraCommandsPostStart {
    printLog "Executing post-start commands..."
    for CMD in "${!POSTSTART_COMMANDS[@]}"; do
	TIMER="${POSTSTART_COMMANDS[$CMD]}"
	sleep "${TIMER}"; printLog "Executing '${CMD}'"; eval ${CMD}
    done
}

# /!\ DO NOT MODIFY - This is to run the eventual post-start commands
function extraCommandsPostEnd {
    printLog "Executing post-end commands..."
    for CMD in "${POSTEND_COMMANDS[@]}"; do
	printLog "Executing '${CMD}'"; eval ${CMD}
    done
}

# /!\ DO NOT MODIFY - Check mandatory variables
function checkMandatoryEnv {
    for VAR in "${MANDATORY_ENV_VARIABLES[@]}"; do
        ENV_VAR=$(echo ${VAR} | cut -f 1 -d ':')
        ENV_DESC=$(echo ${VAR} | cut -f 2- -d ':')
        ENV_TEST=$(printenv ${ENV_VAR})
        if [ -z $ENV_TEST ]; then
            printError "variable '${ENV_VAR}' - ${ENV_DESC} - is not specified in environment. This value is mandatory, you need to specify it. Refer to the documentation of the service if required."
            exit 1
        fi
        printLog "Env: ${ENV_VAR}=${ENV_TEST}"
    done
}
 
# /!\ DO NOT MODIFY - Check optional variables and set them if not specified
function checkOptionalEnv {
    for KEY in "${!OPTIONAL_ENV_VARIABLES[@]}"; do
        ENV_KEY=$(echo ${KEY} | cut -f 1 -d ':')
        ENV_DESC=$(echo ${KEY} | cut -f 2- -d ':')
        ENV_VALUE=${OPTIONAL_ENV_VARIABLES[$KEY]}
        ENV_TEST=$(printenv ${ENV_KEY})
        if [ -z $ENV_TEST ]; then
            export ${ENV_KEY}=${ENV_VALUE}
            printWarn "variable '${ENV_KEY}' - ${ENV_DESC} - was not specified in environment. It has been set to '${ENV_VALUE}' by default."
        fi
        printLog "Env: ${ENV_KEY}=${ENV_VALUE}"
    done
}
 
# /!\ DO NOT MODIFY - This is an ugly file content replacer
function replaceConfigFileContents {
    for SOURCE_FILE in "${!CONFIGURATION_FILES[@]}"; do
        DST_FILE=$(basename "${CONFIGURATION_FILES[$SOURCE_FILE]}")
	if [ "${CONFIGURATION_FILES[$SOURCE_FILE]}" == "" ]; then
	    printLog "Writing configuration file '${SOURCE_FILE}'"
	else
            printLog "Writing configuration file '${CONFIGURATION_FILES[$SOURCE_FILE]}' from template file '${SOURCE_FILE}'"
	fi
        i=0
        TMP_FILE="/tmp/${DST_FILE}.$i"
        cp "${SOURCE_FILE}" "${TMP_FILE}"
        for COOKIE in "${!CONFIGURATION_FILES_REPLACEMENTS[@]}"; do
            CUR_TMP_FILE="/tmp/${DST_FILE}.$i"
            let i=$i+1
            NEW_TMP_FILE="/tmp/${DST_FILE}.$i"
            cat "${CUR_TMP_FILE}" | sed -e "s/$(echo ${COOKIE} | sed -e 's/[]\/$*.^|[]/\\&/g')/$(echo ${CONFIGURATION_FILES_REPLACEMENTS[$COOKIE]} | sed -e 's/[]\/$*.^|[]/\\&/g')/g" > "${NEW_TMP_FILE}"
            nbmatches=$(cat "${CUR_TMP_FILE}" | grep "${COOKIE}" | wc -l)
            if [ "${nbmatches}" -ne "0" ]; then
                printLog "Found '${COOKIE}': replaced with '${CONFIGURATION_FILES_REPLACEMENTS[$COOKIE]}'"
            fi
            rm -f "${CUR_TMP_FILE}"
        done
	if [ "${CONFIGURATION_FILES[$SOURCE_FILE]}" == "" ]; then
	    CONFIGURATION_FILES[$SOURCE_FILE]="${SOURCE_FILE}"
	fi
        mv "${NEW_TMP_FILE}" "${CONFIGURATION_FILES[$SOURCE_FILE]}"
	if [ "${SOURCE_FILE}" != "${CONFIGURATION_FILES[$SOURCE_FILE]}" ]; then
            rm -f "${SOURCE_FILE}"
	fi
    done
}

# /!\ DO NOT MODIFY - The order of the function calls matters here.
checkMandatoryEnv
checkOptionalEnv
# important - we make a 2nd pass on editMe() to set the optional variables
editMe
replaceConfigFileContents
resetContainer
extraCommandsPreStart
startEntryPoints
