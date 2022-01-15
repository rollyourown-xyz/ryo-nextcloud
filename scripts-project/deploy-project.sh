#!/bin/bash

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


# Deploy project

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
# Deploy
echo ""
echo "Executing command: terraform -chdir="$SCRIPT_DIR"/../project-deployment init"
terraform -chdir="$SCRIPT_DIR"/../project-deployment init
echo ""
echo "Executing command: terraform -chdir="$SCRIPT_DIR"/../project-deployment apply -input=false -auto-approve -var \"host_id="$hostname"\" -var \"image_version="$version"\""
terraform -chdir="$SCRIPT_DIR"/../project-deployment apply -input=false -auto-approve -var "host_id="$hostname"" -var "image_version="$version""
echo "Completed"


# Update ryo-host deployed-projects array for "$hostname"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/../configuration/configuration_"$hostname".yml)"

# Check existence of deployed-projects file and create it not existing
if [ ! -f "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml ]
then
  cp "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_TEMPLATE.yml "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml
fi

# Add project to deployed-project array for "$hostname"
if [ ! yq eval '. |= any_c(. == "$PROJECT_ID")' "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml ]
  yq eval -i '. += "$PROJECT_ID"' "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml
fi

# Delete the null entry if it exists:
yq eval -i 'del(.[] | select(. == null))' "$SCRIPT_DIR"/../../ryo-host/backup-restore/deployed-projects_"$hostname".yml
