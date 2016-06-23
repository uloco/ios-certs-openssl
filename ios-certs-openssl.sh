#!/usr/bin/env bash

echo "This script generates development and distribution certificates for itunes connect with openssl. You will need a itunes connect account though."

echo "Please insert details. If your input is empty, the default value in brackets will be used"

while true; do
  echo;
  echo -n "dev or dist certifiate? [dev]: "
  read DEVDIST

  if [[ -z "$DEVDIST" ]]; then
    DEVDIST="dev"
  fi

  if [[ "$DEVDIST" != "dev" && "$DEVDIST" != "dist" ]]; then
    echo "Incorrect input, only 'dev' or 'dist' allowed. Try again!"
    continue
  else
    break
  fi
done

echo -n "email [email@example.com]: "
read EMAIL

if [[ -z "$EMAIL" ]]; then
  EMAIL="email@example.com"
fi

echo -n "common name [sample cert]: "
read CN

if [[ -z "$CN" ]]; then
  CN="sample cert"
fi

echo -n "country code [DE]: "
read C

if [[ -z "$C" ]]; then
  C="DE"
fi

function generate {
  openssl genrsa -out "$1".key 2048
  openssl req -new -key "$1".key -out "$1".csr -subj "/emailAddress=$EMAIL, CN=$CN, C=$C"

  echo -e "\n * Upload the $1.csr file to itunes connect. \n * Download the $1.cer file and place it in this folder. \n * Then press any key"
  read foo

  openssl x509 -in "$1".cer -inform DER -out "$1".pem -outform PEM
  openssl pkcs12 -export -inkey "$1".key -in "$1".pem -out "$1".p12

  echo "Generated $1.p12 file for email '$EMAIL', comman name '$CN', country '$C'"
}

case $DEVDIST in
  dev )
    generate ios_development
    ;;
  dist )
    generate ios_distribution
    ;;
esac

rm *.cer *.csr *.key *.pem
