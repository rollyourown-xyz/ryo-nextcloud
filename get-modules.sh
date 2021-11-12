#!/bin/bash

echo "Getting project-specific modules from repositories..."
echo ""

## Common to almost all projects - service proxy module repository
## Remove if not required
if [ -d "../ryo-service-proxy" ]
then
   echo "Module ryo-service-proxy already cloned to this control node"
else
   echo "Cloning ryo-service-proxy repository. Executing 'git clone' for ryo-service-proxy repository"
   #git clone https://github.com/rollyourown-xyz/ryo-service-proxy ../ryo-service-proxy
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-service-proxy ../ryo-service-proxy
fi

## Project specific submodules
# if [ -d "../<MODULE_DIRECTORY>" ]
# then
#    echo "Module <MODULE_NAME> already cloned to this control node"
# else
#    echo "Cloning <MODULE_NAME> repository. Executing 'git clone' for <MODULE_NAME> repository"
#    #git clone https://github.com/rollyourown-xyz/<MODULE_NAME> ../<MODULE_NAME>
#    git clone https://git.rollyourown.xyz/ryo-projects/<MODULE_NAME> ../<MODULE_NAME>
# fi