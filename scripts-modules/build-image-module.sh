#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "build-image-module.sh: Use packer to build images for deployment"
  echo ""
  echo "Help: build-image-module.sh"
  echo "Usage: ./build-image-module.sh -m -n hostname -v version -m module"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
  echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
  echo -e "-m module \t\t(Mandatory) The module for which to build images"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or mandatory input variable is missing"
  echo "Use \"./build-image-module.sh -h\" for help"
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

# Build module images
echo "Running build-images script for "$module" module on "$hostname" with version "$version""
"$SCRIPT_DIR"/../../"$module"/build-images.sh -n "$hostname" -v "$version"
