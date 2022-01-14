#!/bin/bash

# backup.sh
# This script backs up the persistent storage for the modules required for the project and for the project's components 

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"


# Help and error messages
#########################

helpMessage()
{
  echo "backup.sh: Back up project container persistent storage from the host to the control node"
  echo ""
  echo "Help: backup.sh"
  echo "Usage: ./backup.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up project container persistent storage"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./backup.sh -h\" for help"
  exit 1
}


# Command-line input handling
#############################

while getopts n:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ]
then
  errorMessage
fi


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"


# Info
echo "rollyourown.xyz backup script for "$PROJECT_ID""


# Update project repository
###########################

echo ""
echo "Refreshing project repository with git pull to ensure the current version"
git pull


# Stop project containers
##########################

echo ""
echo "Stop project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/stop-project-containers.sh -n "$hostname"


# Back up project container persistent storage
##############################################

echo ""
echo "Back up project container persistent storage on "$hostname""
ansible-playbook -i "$SCRIPT_DIR"/../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/backup-container-storage.yml --extra-vars "host_id="$hostname""


# Back up Modules
#################

# For each module, back up module if user agrees
echo ""
echo "Module backups"

for module in $MODULES
do
  echo ""
  echo -n "Back up "$module" module (default is 'n')? "
  read -e -p "[y/n]:" BACKUP_MODULE
  BACKUP_MODULE="${BACKUP_MODULE:-"n"}"
  BACKUP_MODULE="${BACKUP_MODULE,,}"

  # Check input
  while [ ! "$BACKUP_MODULE" == "y" ] && [ ! "$BACKUP_MODULE" == "n" ]
  do
    echo "Invalid option "${BACKUP_MODULE}". Please try again."
    echo -n "Back up "$module" module (default is 'n')? "
    read -e -p "[y/n]:" BACKUP_MODULE
    BACKUP_MODULE="${BACKUP_MODULE:-"y"}"
    BACKUP_MODULE="${BACKUP_MODULE,,}"
  done

  if [ "$BACKUP_MODULE" == "y" ]; then
    # git pull module repository
    echo ""
    echo "Updating "$module" repository..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/get-module.sh -m "$module"
    echo ""
    echo ""$module" module repository updated."
    # Back up module
    /bin/bash "$SCRIPT_DIR"/scripts-modules/backup-module.sh -n "$hostname" -m "$module"
    echo ""
    echo ""$module" back up completed from "$hostname"."
  else
    echo "Skipping "$module" module backup."
  fi
done


# Start project containers
##########################

echo ""
echo "Start project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/start-project-containers.sh -n "$hostname"
