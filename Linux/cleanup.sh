#!/bin/bash

#WIP
#Tool to print list of unchanged jobs within the last 14 days
#Use with parameter "hipchat" to send message to MAW

rm JobsForDeletion
find ./*BrowserTest-C* -type f -mtime +14 >> tempListFile

while read p; do
  basedirectory=$(echo "$p" | awk -F "/" '{print $2}')
  echo $basedirectory >> tempListFile2
done <tempListFile


echo $(awk '!a[$0]++' tempListFile2) > tempListFile3
sed 's/\s\+/\n/g' tempListFile3 > JobsForDeletion

# #cleanup
rm tempListFile
rm tempListFile2
rm tempListFile3


echo "List have been finished"
if [[ "$1" == "hipchat" ]]
	then
	echo "test"
	sh ./hipchatmaw.sh "$(cat JobsForDeletion)"
fi
echo "Script finished"
