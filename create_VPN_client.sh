#!/bin/ash

# Check for correct invocation
if [ -z "$1" -o -z "$2"]; then
  echo "Must specify 2 args"
  exit 1
else
  CLIENT=$1
  CLIENT_MAIL=$2
  SERVER=${SERVER_NAME}		# FIX

  # Setup dirs
  cd /etc/easy-rsa
  mkdir -p keys/${CLIENT}

  # Build and move keys to target folder
  build-key-pkcs12 ${CLIENT}.at.${SERVER}
  mv keys/${CLIENT}.at.${SERVER}.* keys/${CLIENT}

  # Change to target folder and, skeleton conf file and append user specific setting
  cd /etc/easy-rsa/keys/${CLIENT}
  cp /etc/openvpn/${SERVER}_client.conf ${CLIENT}.at.${SERVER}.conf
  echo "pkcs12 ${CLIENT}.at.${SERVER}.p12" >> ${CLIENT}.at.${SERVER}.conf

  # Append TLS key to user conf
  echo "\n<tls-auth>" >> ${CLIENT}.at.${SERVER}.conf
  cat ../ta.key >> ${CLIENT}.at.${SERVER}.conf
  echo "</tls-auth>" >> ${CLIENT}.at.${SERVER}.conf
fi

# Compress and encrypt user dir
zip -e ${CLIENT}.zip *

# Check if invocation included an email adress
if [ -n "${CLIENT_MAIL}" ]; then
  # If email is present, generate and send email
  echo -e "Hello ${CLIENT}!\n\nExtract attached files to your openvpn folder." > mail_body.txt
  echo "Remember to rename *.conf to *.ovpn if you are using Windows." >> mail_body.txt
  echo "This email is automatically generated, please do not respond to it." >> mail_body.txt
  mailsend -to ${CLIENT_MAIL} -from ${SENDER_EMAIL} -ssl -port 465 -auth-login -smtp ${SENDER_SMTP} -sub "Configuration for ${CLIENT} on ${SERVER} OpenVPN server" -attach "mail_body.txt,text/plain,i" -attach "${CLIENT}.zip" +cc +bc -user ${SENDER_USER} -pass ${SENDER_PASSWORD}
  
  # Remove tmp mail body file and feedback that mail was sent
  rm mail_body.txt
  echo "Files emailed to ${CLIENT_MAIL}"
else
  # If no email present, whine and exit
  echo "Invalid or non-existant email adress, files stored locally in keys/${CLIENT} only"
fi
