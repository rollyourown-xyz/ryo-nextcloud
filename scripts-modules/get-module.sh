#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "get-module.sh: Clone/update rollyourown.xyz module"
  echo ""
  echo "Help: get-module.sh"
  echo "Usage: ./get-module.sh -m module"
  echo "Flags:"
  echo -e "-m module \t\t(Mandatory) The module to clone or update"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./get-module.sh -h\" for help"
  exit 1
}

while getopts m:h flag
do
  case "${flag}" in
    m) module=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$module" ]
then
  errorMessage
fi

# Clone or update module
if [ -d ""$SCRIPT_DIR"/../../"$module"" ]
then
  echo "Module "$module" already cloned to this control node, refreshing with git pull"
  cd "$SCRIPT_DIR"/../../"$module" && git pull
else
  echo "Cloning "$module" repository. Executing 'git clone' for "$module" repository"
  #git clone https://github.com/rollyourown-xyz/"$module" "$SCRIPT_DIR"/../../"$module"
  git clone https://git.rollyourown.xyz/ryo-projects/"$module" "$SCRIPT_DIR"/../../"$module"
fi
