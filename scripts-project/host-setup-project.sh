#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "host-setup-project.sh: Use ansible to configure a remote host for project deployment"
  echo ""
  echo "Help: host-setup-project.sh"
  echo "Usage: ./host-setup-project.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host to be configured"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or mandatory input variable is missing"
  echo "Use \"./host-setup-project.sh -h\" for help"
  exit 1
}

while getopts n:m:h flag
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


# Run host setup playbooks for project
echo ""
echo "Running project-specific host setup on "$hostname""
echo ""
echo "Executing project-specific host setup on "$hostname""
ansible-playbook -i "$SCRIPT_DIR"/../../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/../host-setup/main.yml --extra-vars "host_id="$hostname""
echo "Completed"
