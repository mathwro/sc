#Tool to quickly tagging all repositories for releases
#Adjust workspace accordingly to own setup

#!/bin/bash

echo ""
read -p "What version of WSF?: `echo $'\n> '`" VERSION


WORKSPACE=$HOME/repo
echo ""

#Tagging Function
tag_current_repo () {
	git checkout master
	git pull
	git tag -m "Release of $VERSION" $VERSION
	git push origin $VERSION
	cd $WORKSPACE
}  > /dev/null 2>&1

#Clients
cd $WORKSPACE/clients
echo "Tagging Client"
tag_current_repo



#Server
cd $WORKSPACE/wsf/wsf-server
echo "Tagging WSF-Server"
tag_current_repo 

#Dashboard
cd $WORKSPACE/wsf/dashboard
echo "Tagging Dashboard"
tag_current_repo

#services
cd $WORKSPACE/wsf/services
echo "Tagging Services"
tag_current_repo

#configui
cd $WORKSPACE/wsf/configui
echo "Tagging ConfigUI"
tag_current_repo

#Storage
cd $WORKSPACE/wsf/storage
echo "Tagging Storage"
tag_current_repo

#Categorizer
cd $WORKSPACE/wsf/categorizer
echo "Tagging Categorizer"
tag_current_repo

#Old Controller
cd $WORKSPACE/wsf/wsf-controller
echo "Tagging (old) controller"
tag_current_repo



#Build tools
cd $WORKSPACE/cicd/codesealer_build_tools
echo "Tagging Build Tools"
tag_current_repo

#Browsertest
cd $WORKSPACE/cicd/browsertest
echo "Tagging Browsertests"
tag_current_repo

#WSFBT
cd $WORKSPACE/cicd/wsf-browser-tests
echo "Tagging WSFBT"
tag_current_repo

#WOWTOOLS
cd $WORKSPACE/cicd/wowtools
echo "WOWTOOLS"
tag_current_repo



#GO Bootloader
cd $WORKSPACEbootloader/go-bootloader
echo "Tagging GO-bootloader"
tag_current_repo


#Obfuscator
cd $WORKSPACE/obfuscator
echo "Tagging Obfuscator"
tag_current_repo

echo "All repositories is now tagged with $VERSION"
