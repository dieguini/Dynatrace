#!/bin/bash

# Color variables
GREEN_COLOR=$(tput setaf 2)
YELLOW_COLOR=$(tput setaf 3)
BLUE_COLOR=$(tput setaf 4)
WHITE_COLOR=$(tput setaf 7)

# Args
HOST_DYNATRACE=$1
API_TOKEN=$2

# Vars
DYNATRACE_ONE_AGENT_SCRIPT="Dynatrace-OneAgent-Linux-1.261.201.sh"

setNormalColor() {
  printf "%s" "$WHITE_COLOR"
}

message() {
  printf "%s" "$YELLOW_COLOR"
  printf "\n******************************************\n"
  echo "$1"
  echo "******************************************"
  setNormalColor
}

download_installation() {
  message "DOWNLOAD DYNATRACE"
  wget -O $DYNATRACE_ONE_AGENT_SCRIPT \
    "$HOST_DYNATRACE/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default" \
    --header="Authorization: Api-Token $API_TOKEN"
}

verify_signature() {
  message "VERIFY SIGNATURE"
  wget https://ca.dynatrace.com/dt-root.cert.pem
  (
    echo 'Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg="sha-256"; boundary="--SIGNED-INSTALLER"'
    echo
    echo
    echo '----SIGNED-INSTALLER'
    cat $DYNATRACE_ONE_AGENT_SCRIPT
  ) | openssl cms -verify -CAfile dt-root.cert.pem >/dev/null
}

run_installer() {
  message "INSTALLER"
  sudo /bin/sh $DYNATRACE_ONE_AGENT_SCRIPT \
    --set-infra-only=false --set-app-log-content-access=true
}

main() {
  # Step 1
  download_installation
  # Step 2
  verify_signature
  # Step 3
  run_installer
}
main
