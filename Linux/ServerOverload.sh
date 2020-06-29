#Tool to create multiple instances of WSF servers
#Place script in the directory with the version of WSF needed to be tested


#!/bin/bash

killall -9 wsf dashboard configui controller 2>&1 > /dev/null
rm startOverload.sh 2>&1 > /dev/null
rm -r wsf_* 2>&1 > /dev/null

sleep 0.5

read -p "How many instances of WSF?: `echo $'\n> '`" number

x=1 y=number z=25100

cp './start.sh' './startOverload.sh'
for ((i=x; i<=y; i++))
do
	cp -r "./wsf" "./wsf_$i"
	sed -i -e "s/wsf_01/wsf_$i/g" "./wsf_$i/config.json"
	echo "wsf_$i/wsf -config=wsf_$i/config.json&" >> 'startOverload.sh'
	cat << EOF > "./workspace/config/wsf_$i.json"
{
	"network": {
		"address": ":$(($z+$i))"
	}
}
EOF
done
