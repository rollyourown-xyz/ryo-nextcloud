#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "deploy-module.sh: Use terraform to deploy project"
  echo ""
  echo "Help: deploy-module.sh"
  echo "Usage: ./deploy-module.sh -n hostname -v version -m module"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to deploy the project"
  echo -e "-v version \t\t(Mandatory) Version stamp for images to deploy, e.g. 20210101-1"
  echo -e "-m module \t\t(Mandatory) The module to deploy"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./deploy-module.sh -h\" for help"
  exit 1
}

while getopts n:v:m:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    m) module=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ] || [ -z "$module" ]
then
  errorMessage
fi

# Deploy module
echo "Deploying "$module" module on "$hostname" using images with version "$version""
"$SCRIPT_DIR"/../../"$module"/deploy-module.sh -n "$hostname" -v "$version"
