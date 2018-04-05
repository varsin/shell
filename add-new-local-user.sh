#!/bin/bash

#
# This Script will create a new user on local system
#Usage: 
	#Apply username as an argument to the script
	#Password will automatically generated
#


#Make sure the script is executed by super user

if [[ "${UID}" -ne 0 ]]
then
	echo "Please run with sudo or as root"
	exit 1
fi

if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [COMMENT]..."
	echo "Create the account with USER_NAME and a comments field on COMMENT"
	exit 1
fi


#The first Parameter is username

USER_NAME="${1}"

#Rest Parameters are just comment

shift
COMMENT="${@}"

#Password generation

PASSWORD=$(date +%s%N | sha256sum | head -c48)

#check if the PASSWORD generated successfully

if [[ "${?}" -ne 0 ]]
then
	echo "Password is not generated successfully!"
	exit 1
fi

#Create the user with the password

useradd -c "${COMMENT}" -m  ${USER_NAME}

if [[ "${?}" -ne 0  ]]
then
	echo "The account could not be created."
fi 

#Set the password 
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

if [[ "${?}" -ne 0  ]]
then
	echo "Password for the account couldn't generated!"
	exit 1
fi 

#Force to change on first login

passwd -e ${USER_NAME}

echo
echo "username:"
echo "${USER_NAME}"
echo 
echo "Default password"
echo "${PASSWORD}"
echo
echo "Host"
echo "${HOST_NAME}"
exit 0


