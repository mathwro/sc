#!/bin/bash

#Clean up from previous updates
rm -f -r ${HOME}/dependenciesTemp


#Setup
mkdir ${HOME}/dependenciesTemp
cd ${HOME}/dependenciesTemp


#Update indivual artifact
updateDependency () {
		cd ${HOME}/dependenciesTemp
		${HOME}/workspace/cicd/codesealer_build_tools/go/updateDependency.sh ${url} ${name} all
		echo ""
	}


#Dependencies:

#go-junit-report
url=github.com/lobatt/go-junit-report
name=go-junit-report
updateDependency

#golint
url=github.com/golang/lint/golint
name=golint
updateDependency

#go-nats
url=github.com/nats-io/gnatsd
name=nats-io
updateDependency

#gocov-xml
url=github.com/AlekSi/gocov-xml
name=gocov-xml
updateDependency

#gocov
url=github.com/axw/gocov/gocov
name=gocov
updateDependency


#Cleanup
rm -f -r ${HOME}/dependenciesTemp