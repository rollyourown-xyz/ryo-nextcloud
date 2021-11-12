#!/bin/bash

echo "Getting project-specific modules from repositories..."
echo ""

## Service proxy module
if [ -d "../ryo-service-proxy" ]
then
   echo "Module ryo-service-proxy already cloned to this control node"
else
   echo "Cloning ryo-service-proxy repository. Executing 'git clone' for ryo-service-proxy repository"
   #git clone https://github.com/rollyourown-xyz/ryo-service-proxy ../ryo-service-proxy
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-service-proxy ../ryo-service-proxy
fi

## MariaDB Database module
if [ -d "../ryo-mariadb" ]
then
   echo "Module ryo-mariadb already cloned to this control node"
else
   echo "Cloning ryo-mariadb repository. Executing 'git clone' for ryo-mariadb repository"
   #git clone https://github.com/rollyourown-xyz/ryo-mariadb ../ryo-mariadb
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-mariadb ../ryo-mariadb
fi
