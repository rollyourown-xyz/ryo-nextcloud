#!/bin/bash

# deploy.sh
# This script deploys the modules required for the project and the project components 

# Project ID
PROJECT_ID="ryo-nextcloud"

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Info
echo "rollyourown.xyz deployment script for "$PROJECT_ID""


# Help and error messages
#########################

helpMessage()
{
  echo "deploy.sh: Deploy a rollyourown.xyz project"
  echo "Usage: ./deploy.sh -n hostname -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to deploy the project"
  echo -e "-v version \t\t(Mandatory) Version stamp for images to deploy, e.g. 20210101-1"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./deploy.sh -h\" for help"
  exit 1
}


# Command-line input handling
#############################

while getopts n:v:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ]; then
  errorMessage
fi


# Update project repository
###########################

echo "Refreshing project repository with git pull to ensure the current version"
git pull


# Deploy Modules
################

# Get user input for whether to deploy all modules (default yes)
echo ""
echo "Deploy all modules?"
echo -n "If this is the first project to be deployed on the host "$hostname", then answer 'y' (the default) "
read -e -p "[y/n]:" DEPLOY_MODULES
DEPLOY_MODULES="${DEPLOY_MODULES:-"y"}"
DEPLOY_MODULES="${DEPLOY_MODULES,,}"

if [ ! "$DEPLOY_MODULES" == "y" ] && [ ! "$DEPLOY_MODULES" == "n" ]; then
  echo "Invalid option "${DEPLOY_MODULES}". Quitting"
  exit 1

elif [ "$DEPLOY_MODULES" == "y" ]; then
  echo "Deploying all modules."
  for module in $MODULES
  do
    # Clone module repository
    echo ""
    echo "Cloning "$module" repository..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/get-module.sh -m "$module"
    echo ""
    echo ""$module" module repository cloned."
    # Run host setup playbooks for module
    echo ""
    echo "Setting up host "$hostname" for "$module" module..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/host-setup-module.sh -n "$hostname" -m "$module"
    echo ""
    echo "Host setup for "$module" module on "$hostname" completed."
    # Run packer image build for module
    echo ""
    echo "Building image(s) for "$module" module on "$hostname"..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/build-image-module.sh -n "$hostname" -v "$version" -m "$module"
    echo ""
    echo ""$module" module image build(s) completed on "$hostname"."
    # Deploy module
    echo ""
    echo "Deploying image(s) for "$module" module on "$hostname"..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/deploy-module.sh -n "$hostname" -v "$version" -m "$module"
    echo ""
    echo ""$module" module deployment completed."
  done

else
  echo "Checking for each module."
  for module in $MODULES
  do
    # Get user input for whether to do module deployment (default yes)
    echo ""
    echo "Checking whether to deploy "$module" module."
    echo "Check the documentation for already-deployed projects at https://rollyourown.xyz/rollyourown/projects/"
    echo "If this module has already been deployed for another project on the host "$hostname", then answer 'n'."
    echo "Default is 'y'."
    echo -n "Deploy "$module" module? "
    read -e -p "[y/n]:" DEPLOY_MODULE
    DEPLOY_MODULE="${DEPLOY_MODULE:-"y"}"
    DEPLOY_MODULE="${DEPLOY_MODULE,,}"
    
    # Check input
    while [ ! "$DEPLOY_MODULE" == "y" ] && [ ! "$DEPLOY_MODULE" == "n" ]
    do
      echo "Invalid option "${DEPLOY_MODULE}". Please try again."
      echo -n "Deploy "$module" module (default is 'y')? "
      read -e -p "[y/n]:" DEPLOY_MODULE
      DEPLOY_MODULE="${DEPLOY_MODULE:-"y"}"
      DEPLOY_MODULE="${DEPLOY_MODULE,,}"
    done

    if [ "$DEPLOY_MODULE" == "y" ]; then
      # Clone module repository
      echo ""
      echo "Cloning "$module" repository..."
      /bin/bash "$SCRIPT_DIR"/scripts-modules/get-module.sh -m "$module"
      echo ""
      echo ""$module" module repository cloned."
      # Run host setup playbooks for module
      echo ""
      echo "Setting up host "$hostname" for "$module" module..."
      /bin/bash "$SCRIPT_DIR"/scripts-modules/host-setup-module.sh -n "$hostname" -m "$module"
      echo ""
      echo "Host setup for "$module" module on "$hostname" completed."
      # Run packer image build for module
      echo ""
      echo "Building image(s) for "$module" module on "$hostname"..."
      /bin/bash "$SCRIPT_DIR"/scripts-modules/build-image-module.sh -n "$hostname" -v "$version" -m "$module"
      echo ""
      echo ""$module" module image build(s) completed on "$hostname"."
      # Deploy module
      echo ""
      echo "Deploying image(s) for "$module" module on "$hostname"..."
      /bin/bash "$SCRIPT_DIR"/scripts-modules/deploy-module.sh -n "$hostname" -v "$version" -m "$module"
      echo ""
      echo ""$module" module deployment completed."
    else
      echo ""
      echo "Skipping "$module" module deployment."
    fi
  done
fi


# Deploy project components
###########################

# Run host setup playbooks for project
echo ""
echo "Running project-specific host setup for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/host-setup-project.sh -n "$hostname"

# Build project images
echo ""
echo "Running image build for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/build-image-project.sh -n "$hostname" -v "$version"

# Deploy project containers
echo ""
echo "Deploying "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/deploy-project.sh -n "$hostname" -v "$version"
