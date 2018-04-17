#!/bin/bash

#This script generates a random password
#This user can set paswd length with -l and add special character with -s
#Vervose mode can be enabled with -v
#Usage : vl:s (l is mandatory)
#Set default length

usage() {
    echo "Usage: ${0} [-vs] [-l LENGTH]" >&2
    echo 'Generate a random password'
    echo ' -l LENGTH    Specify the password length.'
    echo ' -s           Append the special character to the password'
    echo ' -v           Increase the verbosity.'
    exit 1
}

log() {
    local MESSAGE="${@}"
    if [[ "${VERBOSE}" = 'true' ]]
    then
        echo "${MESSAGE}" 
    fi
}

LENGTH=48

while getopts vl:s OPTION
do
    case ${OPTION} in
        v)
        VERBOSE='true'
        log 'Verbose mode on!'
        ;;
        l)
        LENGTH="${OPTARG}"
        ;;
        s)
        USE_SPECIAL_CHARACTER='true'
        ;;
        ?)
        usage
        ;;
    esac
done

log 'Generating a password'

PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c${LENGTH})

#Append a special character
if [[ "${USE_SPECIAL_CHARACTER}" = 'true' ]]
then
    log 'Selecting a random character'
    USE_SPECIAL_CHARACTER=$(echo '!@#$%^&*()-=+' | fold -w1 | shuf | head -c1)
    PASSWORD="${PASSWORD}${USE_SPECIAL_CHARACTER}"
fi    

log 'Done!!'
log 'Here is the paaword'
echo "${PASSWORD}"
exit 0
