#!/bin/bash

# backup.sh
# This script backs up the persistent storage for a project and its modules

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"


# Help and error messages
#########################

helpMessage()
{
  echo "backup.sh: Back up the persistent storage for a project and its modules"
  echo "Usage: ./backup.sh -n hostname -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up project and module container persistent storage"
  echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup"
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

while getopts n:s:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    s) stamp=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$stamp" ]; then
  errorMessage
fi


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"

# Info
echo "Starting backup of "$PROJECT_ID" on "$hostname""

# Stop project containers
echo "Stopping project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/stop-project-containers.sh -n "$hostname"

# Ask whether to backup modules
echo ""
echo "Back up all modules?"
echo "Modules for this project are: "$MODULES""
echo ""
echo "If this is the only project deployed on the host "$hostname", then answer 'y' (the default)."
echo "If you choose 'n', you will still be able to select whether to back up each module individually."
echo ""
echo -n "Back up all modules? "
read -e -p "[y/n]: " BACKUP_MODULES
BACKUP_MODULES="${BACKUP_MODULES:-"y"}"
BACKUP_MODULES="${BACKUP_MODULES,,}"

# Check input
while [ ! "$BACKUP_MODULES" == "y" ] && [ ! "$BACKUP_MODULES" == "n" ]
do
  echo "Invalid option "${BACKUP_MODULES}". Please try again."
  echo -n "Back up all modules (default is 'y')? "
  read -e -p "[y/n]: " BACKUP_MODULES
  BACKUP_MODULES="${BACKUP_MODULES:-"y"}"
  BACKUP_MODULES="${BACKUP_MODULES,,}"
done

if [ "$BACKUP_MODULES" == "y" ]; then
  echo "Backing up all modules."
  for module in $MODULES
  do
    # Stop module containers
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
    # Back up module
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/backup-module.sh -n "$hostname" -s "$stamp"
    # Start module containers
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
  done

else
  echo "Checking for each module."
  for module in $MODULES
  do
    # Get user input for whether to do module backup (default yes)
    echo ""
    echo "Checking whether to back up "$module" module."
    echo "Default is 'y'."
    echo -n "Back up "$module" module? "
    read -e -p "[y/n]: " BACKUP_MODULE
    BACKUP_MODULE="${BACKUP_MODULE:-"y"}"
    BACKUP_MODULE="${BACKUP_MODULE,,}"
    
    # Check input
    while [ ! "$BACKUP_MODULE" == "y" ] && [ ! "$BACKUP_MODULE" == "n" ]
    do
      echo "Invalid option "${BACKUP_MODULE}". Please try again."
      echo -n "Back up "$module" module (default is 'y')? "
      read -e -p "[y/n]: " BACKUP_MODULE
      BACKUP_MODULE="${BACKUP_MODULE:-"y"}"
      BACKUP_MODULE="${BACKUP_MODULE,,}"
    done

    if [ "$BACKUP_MODULE" == "y" ]; then
      # Stop module containers
      /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
      # Back up module
      /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/backup-module.sh -n "$hostname" -s "$stamp"
      # Start module containers
      /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"

    else
      echo ""
      echo "Skipping "$module" module backup."
    fi
  done
fi

# Back up project
echo "Backing up project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/backup-project.sh -n "$hostname" -s "$stamp"

# Start project containers
echo "Starting project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/start-project-containers.sh -n "$hostname"
echo "Backup completed"
