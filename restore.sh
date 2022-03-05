#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# restore.sh
# This script restores a previous backup of the persistent storage for a project and, 
# optionally, its modules.
# This should only be used if necessary, e.g. after a system failure or failed upgrade.
#
# ATTENTION!!!
# The process will **delete** the current persistent storage for the project and its modules and 
# replace them with the content of a backup. This will return the project and its modules to a previous state. 
# If other projects use the same module, then this may affect those projects
# THIS SHOULD NORMALLY ONLY BE DONE FOR DISASTER RECOVERY - e.g. AFTER A SYSTEM FAILURE

# restore.sh
# This script restores the persistent storage for a project and its module

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-mariadb ryo-wellknown"

# Help and error messages
#########################

helpMessage()
{
  echo "restore.sh: Restore a previous backup of the persistent storage for a project and its modules"
  echo "Usage: ./restore.sh -n hostname -s stamp"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to restore project container persistent storage"
  echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup to restore to the host server"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./restore.sh -h\" for help"
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

if [ -z "$hostname" ]|| [ -z "$stamp" ]; then
  errorMessage
fi

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"


# Warn the user and get confirmation
####################################

echo " "
echo "!!! CAUTION! "
echo "!!! "
echo "!!! A restore should normally only be carried out after a system failure, a failed upgrade"
echo "!!! or to move projects and modules to a new host server. "
echo " "
echo "!!! A restore should not be carried out for a host server with functioning"
echo "!!! projects! "
echo " "
echo "Do you want to restore a backup for "$PROJECT_ID" on "$hostname"? (y/n)"
echo "Default is 'n'."
echo -n "Restore backup? "
read -e -p "[y/n]: " RESTORE_BACKUP
RESTORE_BACKUP="${RESTORE_BACKUP:-"n"}"
RESTORE_BACKUP="${RESTORE_BACKUP,,}"

if [ ! "$RESTORE_BACKUP" == "y" ] && [ ! "$RESTORE_BACKUP" == "n" ]; then
  echo "Invalid option "${RESTORE_BACKUP}". Exiting"
  exit 1

elif [ "$RESTORE_BACKUP" == "n" ]; then
  echo "Exiting"
  exit 1

else
  echo ""
  echo "!!! ARE YOU SURE? "
  echo "!!! "
  echo "!!! If your project is currently working, then you will lose the current state and "
  echo "!!! may not be able to recover it! "
  echo "!!! "
  echo "!!! If you proceed, you will restore the project "$PROJECT_ID" "
  echo "!!! on "$hostname" from backups stamped with "$stamp" "
  echo "!!! "
  echo "!!! Please confirm by typing 'yes' for the next question "
  echo "!!! Default is 'no'."
  echo ""
  echo -n "Are you sure that you want to restore a backup? "
  read -e -p "[yes/no]: " RESTORE_BACKUP_SURE
  RESTORE_BACKUP_SURE="${RESTORE_BACKUP_SURE:-"no"}"
  RESTORE_BACKUP_SURE="${RESTORE_BACKUP_SURE,,}"
  
  if [ ! "$RESTORE_BACKUP_SURE" == "yes" ] && [ ! "$RESTORE_BACKUP_SURE" == "no" ]; then
    echo "Invalid option "${RESTORE_BACKUP_SURE}". Exiting"
    exit 1

  elif [ "$RESTORE_BACKUP_SURE" == "no" ]; then
    echo "Exiting"
    exit 1
  
  else
    echo ""
    echo "!!! Please confirm the stamp of the backup to restore "
    echo "!!! " 
    echo "!!! You will be restoring from backups with stamp: "$stamp" "
    echo "!!! "
    echo "!!! Please confirm by typing 'yes' for the next question "
    echo "!!! Default is 'no'."
    echo ""
    echo -n "Are you sure that the backup stamp is correct? "
    read -e -p "[yes/no]: " RESTORE_BACKUP_STAMP_SURE
    RESTORE_BACKUP_STAMP_SURE="${RESTORE_BACKUP_STAMP_SURE:-"no"}"
    RESTORE_BACKUP_STAMP_SURE="${RESTORE_BACKUP_STAMP_SURE,,}"
    
    if [ ! "$RESTORE_BACKUP_STAMP_SURE" == "yes" ] && [ ! "$RESTORE_BACKUP_STAMP_SURE" == "no" ]; then
      echo "Invalid option "${RESTORE_BACKUP_STAMP_SURE}". Exiting"
      exit 1

    elif [ "$RESTORE_BACKUP_STAMP_SURE" == "no" ]; then
      echo "Exiting"
      exit 1

    fi
  fi
fi

# Info
echo "Starting restore of "$PROJECT_ID" on "$hostname""

# Stop project containers
echo "Stopping project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/stop-project-containers.sh -n "$hostname"

# Ask whether to restore modules
echo ""
echo "Restore all modules?"
echo "Modules for this project are: "$MODULES""
echo ""
echo "If this is the only project to be restored on the host "$hostname", and you have backed "
echo "up all modules WITH THE SAME STAMP "$stamp" as the project, then answer 'y'."
echo "If you choose 'n' (the default), you be able to select whether to restore each module individually"
echo "and/or choose a different backup stamp."
echo ""
echo -n "Restore all modules with stamp "$stamp"? "
read -e -p "[y/n]: " RESTORE_MODULES
RESTORE_MODULES="${RESTORE_MODULES:-"n"}"
RESTORE_MODULES="${RESTORE_MODULES,,}"

# Check input
while [ ! "$RESTORE_MODULES" == "y" ] && [ ! "$RESTORE_MODULES" == "n" ]
do
  echo "Invalid option "${RESTORE_MODULES}". Please try again."
  echo -n "Restore all modules with stamp "$stamp" (default is 'n')? "
  read -e -p "[y/n]: " RESTORE_MODULES
  RESTORE_MODULES="${RESTORE_MODULES:-"n"}"
  RESTORE_MODULES="${RESTORE_MODULES,,}"
done

if [ "$RESTORE_MODULES" == "y" ]; then
  echo "Restoring all modules."
  for module in $MODULES
  do
    # Stop module containers
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
    # Restore module
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/restore-module.sh -n "$hostname" -s "$stamp"
    # Start module containers
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
  done

else
  echo "Checking for each module."
  for module in $MODULES
  do
    # Get user input for whether to do module restore (default yes)
    echo ""
    echo "Checking whether to restore "$module" module."
    echo "Default is 'n'."
    echo -n "Restore "$module" module? "
    read -e -p "[y/n]: " RESTORE_MODULE
    RESTORE_MODULE="${RESTORE_MODULE:-"n"}"
    RESTORE_MODULE="${RESTORE_MODULE,,}"
    
    # Check input
    while [ ! "$RESTORE_MODULE" == "y" ] && [ ! "$RESTORE_MODULE" == "n" ]
    do
      echo "Invalid option "${RESTORE_MODULE}". Please try again."
      echo -n "Restore "$module" module (default is 'n')? "
      read -e -p "[y/n]: " RESTORE_MODULE
      RESTORE_MODULE="${RESTORE_MODULE:-"n"}"
      RESTORE_MODULE="${RESTORE_MODULE,,}"
    done

    if [ "$RESTORE_MODULE" == "y" ]; then
      # Check the module stamp
      echo ""
      echo "You will be restoring the module "$module" from a backup with stamp "$stamp"."
      echo "Please check the stamp "$stamp" carefully!"
      echo -n "Is the stamp "$stamp" correct for the module "$module"? (default is 'y') "
      read -e -p "[y/n]: " STAMP_CORRECT
      STAMP_CORRECT="${STAMP_CORRECT:-"y"}"
      STAMP_CORRECT="${STAMP_CORRECT,,}"

      # Check input
      while [ ! "$STAMP_CORRECT" == "y" ] && [ ! "$STAMP_CORRECT" == "n" ]
      do
        echo "Invalid option "${STAMP_CORRECT}". Please try again."
        echo -n "Is the stamp "$stamp" correct for the module "$module"? (default is 'y') "
        read -e -p "[y/n]: " STAMP_CORRECT
        STAMP_CORRECT="${STAMP_CORRECT:-"y"}"
        STAMP_CORRECT="${STAMP_CORRECT,,}"
      done

      if [ "$STAMP_CORRECT" == "y" ]; then
        # Stop module containers
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
        # Restore module
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/restore-module.sh -n "$hostname" -s "$stamp"
        # Start module containers
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"

      else
        # Request different backup stamp
        echo ""
        echo "Please enter the stamp for the backup of module "$module" to restore."
        echo "Please double-check you are entering the correct stamp."
        echo ""
        echo -n "What is the stamp for the backup of module "$module" to restore? "
        read -e -p "" DIFFERENT_STAMP
        echo ""
        echo "Restoring the module "$module" to "$hostname" from a backup with stamp "$DIFFERENT_STAMP""
        # Stop module containers
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
        # Restore module
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/restore-module.sh -n "$hostname" -s "$DIFFERENT_STAMP"
        # Start module containers
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
      fi

    else
      echo ""
      echo "Skipping "$module" module restore."
    fi
  done
fi

# Restore project
echo "Restoring project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/restore-project.sh -n "$hostname" -s "$stamp"

# Start project containers
echo "Starting project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/start-project-containers.sh -n "$hostname"
echo "Restore completed"
