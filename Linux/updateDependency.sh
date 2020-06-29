#!/bin/bash


#Tool to update a single dependency

#First argument should be the URL to pick up the dependency from
#Second argument is the path on artifactory in which the dependency should be placed, relative to "artifactory:8081/third-party/"


#Setup
export GOB=`which go`
mkdir ${HOME}/dependenciesTemp >/dev/null 2>/dev/null
GP=$(echo $GOPATH)
export GOPATH=${HOME}/dependenciesTemp
githuburl=$1
artifactorydir=$2
filename=$(echo $githuburl | sed 's/.*\///')

	cd ${HOME}/dependenciesTemp

	echo "Downloading $githuburl"
	${GOB} get -u "$githuburl"

	echo "Compiling $githuburl"
	${GOB} build "$githuburl"
	ubuntuartifact=
	echo "Compiling for windows '$githuburl'"
	GOOS=windows ${GOB} build "$githuburl"

	echo "Uploading to artifactory" 
	curl --user admin:codesealer -X PUT "http://artifactory:8081/artifactory/third-party/github/${artifactorydir}/ubuntu64/${filename}" -T ~/dependenciesTemp/${filename} >/dev/null 2>/dev/null
	curl --user admin:codesealer -X PUT "http://artifactory:8081/artifactory/third-party/github/${artifactorydir}/windows64/${filename}.exe" -T ~/dependenciesTemp/${filename}.exe >/dev/null 2>/dev/null
	echo ""

#Cleanup
export GOPATH=$(echo $GP)
if [ "$3" == "all" ]; then
	:
elif [ -z "$3" ]; then
	rm -f -r "${HOME}"/dependenciesTemp
fi