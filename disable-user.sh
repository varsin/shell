#!/bin/bash

 # This script will disable, delete or archive the users on local system

ARCHIVE_DIR='/archive'

usage() {
    #Display the usage and exit
    echo "Usage: ${0} [-dra] USER [USERN]..." >&2
    echo "Disable a local account." >&2
    echo "     -d Delete accounts instead of disabling them." >&2
    echo "     -r Remove the home directory associated with the account(s)." >&2
    echo "     -a Create an archive of the home directory associated with the account(s)." >&2
    exit 1
}

#Make sure about the previlages
if [[ "${UID}" -ne 0 ]]
then
    echo "Please run with sudo or as root user." >&2
    exit 1
fi 


#Parse the options
while getopts dra OPTION
do
    case ${OPTION} in 
        d) DELETE_USER='true' 
        ;;
        r) REMOVE_OPTION='-r' 
        ;;
        a) ARCHIVE='true'
        ;;
        ?) usage
        ;;
    esac
done

#Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

#If the user doesn't supply at least one argument, give then help.
if [[ "${#}" -lt 1 ]]
then
    usage
fi

#Loop through all the args
for USERNAME in "${@}"
do
    echo "Processing user: ${USERNAME}"
    
    #Make sure the UID of the account is atleast 1000
    USERID=$(id -u ${USERNAME})
    if [[ "${USERID}" -lt 1000 ]]
    then
        echo "Refusing to remove the ${USERNAME} account with UID ${USERID}." >&2
        exit 1
    fi
    
    #Create an archive if requested to do so.
    if [[ "${ARCHIVE}" = 'true' ]]
    then
        if [[ ! -d "${ARCHIVE_DIR}" ]]
        then
            echo "Creating ${ARCHIVE_DIR} directory."
            mkdir -p ${ARCHIVE_DIR}
            if [[ "${?}" -ne 0 ]]
            then
                echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
                exit 1 
            fi
        fi
    
        #Archive the user's home directory and move it into the ARCHIVE_DIR.
        HOME_DIR="/home/${USERNAME}"
        ARCHIVE_FILE="$ARCHIVE_DIR/${USERNAME}.tgz"
        if [[ -d "${HOME_DIR}" ]]
        then
            echo "Archiving the ${HOME_DIR} to ${ARCHIVE_FILE}"
            tar -zcf ${ARCHIVE_FILE} ${HOME_DIR}&> /dev/null
            if [[ "${?}" -ne 0 ]]
            then
                echo "Couldn't create ${ARCHIVE_FILE}" >&2
                exit 1
            fi
        else 
            echo "${HOME_DIR} doesn't exist or is not a directory." >&2
            exit 1    
        fi
    fi 
   
    if [[ "${DELETE_USER}" = 'true' ]]
    then
        #Delete the user
        userdel ${REMOVE_OPTION} ${USERNAME}
        if [[ "${?}" -ne 0 ]]
        then
            echo "The account ${USERNAME} is NOT deleted!" >&2
            exit 1
        fi
        echo "The account ${USERNAME}  deleted successfully."
    else 
        chage -E 0 ${USERNAME}
        #Validate disable command ran successfully 
        if [[ "${?}" -ne 0 ]]
        then
            echo "The account ${USERNAME} is NOT disabled!" >&2
            exit 1
        fi
        echo "The account ${USERNAME} is disabled successfully."
    fi 
done

exit 0



