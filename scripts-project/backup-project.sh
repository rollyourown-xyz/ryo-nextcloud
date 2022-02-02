#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "backup-project.sh: Use ansible to back up the persistent storage for the project"
   echo ""
   echo "Help: backup-project.sh"
   echo "Usage: ./backup-project.sh -n hostname -v version"
   echo "Flags:"
   echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up the project and its modules"
   echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or input variables are missing"
   echo "Use \"./backup-module.sh -h\" for help"
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


# Back up project container persistent storage
#############################################

echo ""
echo "Backing up "$PROJECT_ID" container persistent storage on "$hostname" with stamp "$stamp""
ansible-playbook -i "$SCRIPT_DIR"/../../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/../backup-restore/backup-project.yml --extra-vars "project_id="$PROJECT_ID" host_id="$hostname" backup_stamp="$stamp""
