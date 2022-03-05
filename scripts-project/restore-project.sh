#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "restore-project.sh: Use ansible to restore the persistent storage for a project"
   echo ""
   echo "Help: restore-project.sh"
   echo "Usage: ./restore-project.sh -n hostname -v version"
   echo "Flags:"
   echo -e "-n hostname \t\t(Mandatory) Name of the host on which to restore the project's persistent storage"
   echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup to be restored"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or input variables are missing"
   echo "Use \"./backup-project.sh -h\" for help"
   exit 1
}

while getopts n:s:h flag
do
    case "${flag}" in
        n) hostname=${OPTARG};;
        s) stamp=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$hostname" ] || [ -z "$stamp" ]
then
  errorMessage
fi

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/../configuration/configuration_"$hostname".yml)"


# Restore project container persistent storage
##############################################

echo ""
echo "Restoring "$PROJECT_ID" container persistent storage on "$hostname" with stamp "$stamp""
ansible-playbook -i "$SCRIPT_DIR"/../../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/../backup-restore/restore-project.yml --extra-vars "project_id="$PROJECT_ID" host_id="$hostname" backup_stamp="$stamp""
