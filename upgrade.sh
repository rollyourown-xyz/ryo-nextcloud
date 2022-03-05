#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# upgrade.sh
# This script upgrades the modules required for the project and upgrades the project components 

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"


# Help and error messages
#########################

helpMessage()
{
  echo "upgrade.sh: Upgrade a rollyourown.xyz project"
  echo "Usage: ./upgrade.sh -n hostname -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to upgrade the project"
  echo -e "-v version \t\t(Mandatory) Version stamp for images to upgrade, e.g. 20210101-1"
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


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"


# Info
echo "rollyourown.xyz upgrade script for "$PROJECT_ID""


# Update project repository
###########################

echo "Refreshing project repository with git pull to get the current version"
cd "$SCRIPT_DIR" && git pull


# Option to back up the project before upgrading
################################################

echo " "
echo "!!! An upgrade may fail and break your project deployment. "
echo "!!! It is recommended to back up your project before upgrading. "
echo " "
echo "Do you want to create a backup of "$PROJECT_ID" on "$hostname" before upgrading? (y/n)"
echo "Default is 'y'."
echo -n "Back up "$PROJECT_ID" on "$hostname"? "
read -e -p "[y/n]: " BACKUP_FIRST
BACKUP_FIRST="${BACKUP_FIRST:-"y"}"
BACKUP_FIRST="${BACKUP_FIRST,,}"

# Check input
while [ ! "$BACKUP_FIRST" == "y" ] && [ ! "$BACKUP_FIRST" == "n" ]
do
  echo "Invalid option "${BACKUP_FIRST}". Please try again."
  echo -n "Back up "$PROJECT_ID" on "$hostname"? "
  read -e -p "[y/n]: " BACKUP_FIRST
  BACKUP_FIRST="${BACKUP_FIRST:-"y"}"
  BACKUP_FIRST="${BACKUP_FIRST,,}"
done

if [ "$BACKUP_FIRST" == "y" ]; then
  
  # Get backup stamp as input
  echo""
  echo -n "Enter a stamp (e.g. date, time, name) to identify the backup"
  read -e -p ": " BACKUP_STAMP
  /bin/bash "$SCRIPT_DIR"/backup.sh -n "$hostname" -s "$BACKUP_STAMP"
fi


# Upgrade Modules
#################

# For each module, do module upgrade if user agrees
echo ""
echo "Module upgrades"

for module in $MODULES
do
  echo ""
  echo -n "Upgrade "$module" module (default is 'n')? "
  read -e -p "[y/n]:" UPGRADE_MODULE
  UPGRADE_MODULE="${UPGRADE_MODULE:-"n"}"
  UPGRADE_MODULE="${UPGRADE_MODULE,,}"

  # Check input
  while [ ! "$UPGRADE_MODULE" == "y" ] && [ ! "$UPGRADE_MODULE" == "n" ]
  do
    echo "Invalid option "${UPGRADE_MODULE}". Please try again."
    echo -n "Upgrade "$module" module (default is 'n')? "
    read -e -p "[y/n]:" UPGRADE_MODULE
    UPGRADE_MODULE="${UPGRADE_MODULE:-"y"}"
    UPGRADE_MODULE="${UPGRADE_MODULE,,}"
  done

  if [ "$UPGRADE_MODULE" == "y" ]; then
    echo "Upgrading "$module" module."

    # Upgrade module
    echo ""
    echo "Upgrading "$module" module on "$hostname" with version "$version""
    /bin/bash "$SCRIPT_DIR"/../"$module"/upgrade.sh -n "$hostname" -v "$version"

  else
    echo ""
    echo "Skipping "$module" module upgrade."
  fi
done


# Upgrade project components
############################

# Build new project images
echo ""
echo "Building new image(s) for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/build-image-project.sh -n "$hostname" -v "$version"

# Deploy project containers
echo ""
echo "Deploying new image(s) for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/deploy-project.sh -n "$hostname" -v "$version"
