#!/bin/sh
##
## Read user credentials from stdin and store them in a protected file for later use

# Read user input
echo "Setting up credential file"
echo -n "Enter VPN server name: "
read -r SERVER_NAME
echo -n "Enter email adress that will be used to send credentials: "
read SENDER_MAIL
echo -n "Enter SMTP adress: "
read SENDER_SMTP
echo -n "Enter email username: "
read SENDER_USER
echo -n "Enter email password: "
stty -echo
read -r SENDER_PASS
stty echo

# Write data to credentials file
rm -f .credentials
touch .credentials
chmod 600 .credentials
echo "SERVER_NAME=$SERVER_NAME"  >> .credentials
echo "SENDER_MAIL=$SENDER_EMAIL" >> .credentials
echo "SENDER_SMTP=$SENDER_SMTP"  >> .credentials
echo "SENDER_USER=$SENDER_USER"  >> .credentials
echo "SENDER_PASS=$SENDER_PASS"  >> .credentials

