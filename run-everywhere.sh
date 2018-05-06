#!/bin/bash



# This script will run on all the servers listed in the file provided
SERVERS='/vagrant/servers'

#Options for the ssh command
SSH_OPTIONS='-o ConnectTimeout=2'

usage() {
    #Display the usage and exit
    echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
    echo 'Execute COMMAND as a single command on every server.' >&2
    echo "      -f FILE Use for the list of servers. Default ${SERVERS}." >&2
    echo '      -n Dry run mode. Display the COMMAND that would have been executed and exit.' >&2
    echo '      -s Execute the COMMAND using sudo on the remote server.' >&2
    echo '      -v Verbose mode. Display the server name before executing COMMAND.' >&2
    exit 1
}

#Make sure the script is not begin executed with superuser privilages
if [[ "${UID}" -eq  0 ]]
then
    echo 'Do not execute this script as root. Use the -s option instead.' >&2
    usage
fi

#Parse the options

while getopts f:nsv OPTION
do
    case ${OPTION} in
        f) SERVERS=${OPTARG}
        ;;
        n) DRY_RUN=true
        ;;
        s) SUDO='sudo'
        ;;
        v) VERBOSE=true
        ;;
        ?) usage
        ;;
    esac
done

#Remove the options while l;eaving the args

shift "$(( OPTIND - 1 ))"
if [[ "${#}" -lt 1 ]]
then
    usage
fi

#Anything that remains on the command line is to treated as a singlr command
COMMAND="${@}"

#Make sure the servers list file exists
if [[ ! -e "${SERVERS}"  ]]
then
    echo "Cannot open the servers list file ${SERVERS}!!" >&2
    exit 1
fi

#Expect the best...

EXIT_STATUS='0'

#LOOP through the servers

for SERVER in SERVERS
do
    if [[ "${VERBOSE}" = 'true'  ]]
    then
        echo "${SERVER}"
    fi    
    SSH_COOMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"
    
    #if it's a dry run just display the content, just echo it
    if [[ "${DRY_RUN}"='true' ]]
    then
        echo "DRY RUN: ${SSH_COMMAND}"
    else
        ${SSH_COMMAND}
        SSH_EXIT_STATUS="${?}"
        #Capture any non-zero status
        if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
        then
            EXIT_STATUS="${SSH_EXIT_STATUS}"
            echo "Execution on ${SERVER} faild!!" >&2
        fi
    fi   
done

exit ${EXIT_STATUS}

