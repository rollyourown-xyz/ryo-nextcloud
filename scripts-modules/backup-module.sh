#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "backup-module.sh: Back up a module"
  echo ""
  echo "Help: backup-module.sh"
  echo "Usage: ./backup-module.sh -n hostname -m module"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up the module"
  echo -e "-m module \t\t(Mandatory) The module to deploy"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./backup-module.sh -h\" for help"
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

# Deploy module
echo "Backing up "$module" module on "$hostname""
"$SCRIPT_DIR"/../../"$module"/backup-module.sh -n "$hostname"
