#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# rollback.sh
# This script rolls back the modules for the project and the project components to previous versions

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"


# Help and error messages
#########################

helpMessage()
{
  echo "rollback.sh: Deploy a rollyourown.xyz project"
  echo "Usage: ./rollback.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to deploy the project"
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

while getopts n:v:rsh flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ]; then
  errorMessage
fi


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"


# Info
echo "rollyourown.xyz rollback script for "$PROJECT_ID""


# Roll back modules
###################

echo "Checking for each module."
for module in $MODULES
do
  # Get user input for whether to roll back module (default no)
  echo ""
  echo "Roll back "$module" module?"
  echo "Default is 'n'."
  echo "If you choose to roll back the module, you will be asked to enter a "
  echo "version stamp for a known working version of the module. Check the documentation "
  echo "at http://rollyourown.xyz/rollyourown/how_to_use/maintain/#rollback for how "
  echo "to identify the correct version."
  echo ""
  echo -n "Roll back "$module" module? "
  read -e -p "[y/n]: " ROLL_BACK_MODULE
  ROLL_BACK_MODULE="${ROLL_BACK_MODULE:-"n"}"
  ROLL_BACK_MODULE="${ROLL_BACK_MODULE,,}"
  
  # Check input
  while [ ! "$ROLL_BACK_MODULE" == "y" ] && [ ! "$ROLL_BACK_MODULE" == "n" ]
  do
    echo "Invalid option "${ROLL_BACK_MODULE}". Please try again."
    echo -n "Roll back "$module" module (default is 'n')? "
    read -e -p "[y/n]: " ROLL_BACK_MODULE
    ROLL_BACK_MODULE="${ROLL_BACK_MODULE:-"n"}"
    ROLL_BACK_MODULE="${ROLL_BACK_MODULE,,}"
  done

  if [ "$ROLL_BACK_MODULE" == "y" ]; then

    echo ""
    echo -n "Please enter the version of the module to restore:"
    read -e -p " " ROLL_BACK_MODULE_VERSION
    
    # Deploy module
    echo "Rolling back "$module" module on "$hostname" to version "$ROLL_BACK_MODULE_VERSION""
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/deploy-module.sh -n "$hostname" -v "$ROLL_BACK_MODULE_VERSION"

  else
    echo "Skipping "$module" module rollback."
  fi
done


# Roll back project components
##############################

# Get user input for the project component version to roll back to
echo ""
echo "Please enter a version stamp for a known working version of the project. Check the "
echo "documentation at http://rollyourown.xyz/rollyourown/how_to_use/maintain/#rollback "
echo "for how to identify the correct version."
echo ""
echo -n "Please enter the version of the project to restore:"
read -e -p " " ROLL_BACK_PROJECT_VERSION

# Roll back project
echo ""
echo "Rolling back "$PROJECT_ID" on "$hostname" to version "$ROLL_BACK_PROJECT_VERSION""
/bin/bash "$SCRIPT_DIR"/scripts-project/deploy-project.sh -n "$hostname" -v "$ROLL_BACK_PROJECT_VERSION"

echo ""
echo "Rollback completed."
