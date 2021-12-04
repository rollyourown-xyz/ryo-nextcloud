#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "host-setup-module.sh: Use ansible to configure a remote host for module deployment"
  echo ""
  echo "Help: host-setup-module.sh"
  echo "Usage: ./host-setup-module.sh -n hostname -m module"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host to be configured"
  echo -e "-m module \t\t(Mandatory) The module for which to set up the remote host"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or mandatory input variable is missing"
  echo "Use \"./host-setup-module.sh -h\" for help"
  exit 1
}

while getopts n:m:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    m) module=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$module" ]
then
  errorMessage
fi

# Set up host for module
if [ -f ""$SCRIPT_DIR"/../../"$module"/configuration/"$hostname"_playbooks_executed" ]
then
  echo "Host setup for "$module" module has already been done on "$hostname""
else
  echo "Running module-specific host setup for "$module" on "$hostname""
  "$SCRIPT_DIR"/../../"$module"/host-setup.sh -n "$hostname"
fi
