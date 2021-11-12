#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Add additional help for software package versions defined below
# Option "-g grav_version" as an example
helpMessage()
{
   echo "build-images.sh: Use packer to build images for deployment"
   echo ""
   echo "Help: build-images.sh"
   echo "Usage: ./build-images.sh -m -n hostname -g grav_version -v version"
   echo "Flags:"
   echo -e "-m \t\t\t(Optional) Flag to also build images for modules"
   echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
   echo -e "-g grav_version \t(Optional) Override default grav version to use for the webserver image, e.g. 1.7.17 (default)"
   echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./build-images.sh -h\" for help"
   exit 1
}

# Default software package versions
# Add software package versions here, for example grav
grav_version='1.7.17'

build_modules='false'

# Add additional options for software package versions defined above
# Option "-g grav_version" as an example
while getopts mn:g:v:h flag
do
    case "${flag}" in
        m) build_modules='true';;
        n) hostname=${OPTARG};;
        g) grav_version=${OPTARG};;
        v) version=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$hostname" ] || [ -z "$version" ] || [ -z "$grav_version" ]
then
   errorMessage
fi

# Common to almost all projects - service proxy module
# Remove if not needed for this project
# Build module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-service-proxy module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-service-proxy/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Project-specific image builds here..., for example
#echo "Building webserver image on "$hostname""
#echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"grav_version="$grav_version"\" -var \"version="$version"\" "$SCRIPT_DIR"/image-build/webserver.pkr.hcl"
#echo ""
#packer build -var "host_id="$hostname"" -var "grav_version="$grav_version"" -var "version="$version"" "$SCRIPT_DIR"/image-build/webserver.pkr.hcl
#echo ""

echo "Completed"
