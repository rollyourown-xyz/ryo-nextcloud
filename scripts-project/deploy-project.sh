#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "deploy-project.sh: Use terraform to deploy project"
  echo ""
  echo "Help: deploy-project.sh"
  echo "Usage: ./deploy-project.sh -n hostname -v version"
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
  echo "Use \"./deploy-project.sh -h\" for help"
  exit 1
}

while getopts n:v:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ]
then
  errorMessage
fi

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/../configuration/configuration_"$hostname".yml)"

# Deploy components
###################

echo "Deploying components for "$PROJECT_ID" project on "$hostname""
echo ""

# Set up / switch to project workspace for host
if [ -f ""$SCRIPT_DIR"/../configuration/"$hostname"_workspace_created" ]; then
   echo ""
   echo "Workspace for host "$hostname" already created, switching to workspace"
   echo ""
   echo "Executing command terraform -chdir="$SCRIPT_DIR"/../project-deployment workspace select "$hostname""
   terraform -chdir="$SCRIPT_DIR"/../project-deployment workspace select "$hostname"
else
   echo ""
   echo "Creating workpsace for host "$hostname" and switching to it"
   echo ""
   echo "Executing command: terraform -chdir="$SCRIPT_DIR"/../project-deployment workspace new "$hostname""
   terraform -chdir="$SCRIPT_DIR"/../project-deployment workspace new "$hostname"
   touch "$SCRIPT_DIR"/../configuration/"$hostname"_workspace_created
fi

echo "Executing command: terraform -chdir="$SCRIPT_DIR"/../project-deployment init"
echo ""
terraform -chdir="$SCRIPT_DIR"/../project-deployment init
echo ""
echo "Executing command: terraform -chdir="$SCRIPT_DIR"/../project-deployment apply -input=false -auto-approve -var \"host_id="$hostname"\" -var \"image_version="$version"\""
terraform -chdir="$SCRIPT_DIR"/../project-deployment apply -input=false -auto-approve -var "host_id="$hostname"" -var "image_version="$version""
echo "Completed"


# Update ryo-host deployed-projects file for "$hostname"
########################################################

DEPLOYED_PROJECTS_FILE="$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml

# Check existence of deployed-projects file and create it not existing
echo ""
echo "Checking existence of deployed-projects file for "$hostname" and creating if not existing"

if [ ! -f "$DEPLOYED_PROJECTS_FILE" ]; then
  cp "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_TEMPLATE.yml "$DEPLOYED_PROJECTS_FILE"
fi


# Add project to deployed-projects file for "$hostname"
echo ""
echo "Adding project to deployed-projects file for "$hostname""

if [ $(yq_project_id="$PROJECT_ID" yq eval '. |= any_c(. == strenv(yq_project_id))' "$DEPLOYED_PROJECTS_FILE") == true ]; then
  echo ""$PROJECT_ID" is already recorded in the deployed-projects_"$hostname".yml file"
else
  yq_project_id="$PROJECT_ID" yq eval -i '. += strenv(yq_project_id)' "$DEPLOYED_PROJECTS_FILE"
fi


# Delete the null entry if it exists
echo ""
echo "Deleting the null entry if it exists"
yq eval -i 'del(.[] | select(. == null))' "$DEPLOYED_PROJECTS_FILE"
