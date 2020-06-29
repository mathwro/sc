#Author: Mathias Wrobel - Innofactor A/S

#Variables
#Set paths
Param (
    [String] $path = '',
    [String] $Archive = '',
    [string] $LogPath = ''
)

#Setup
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Azure\5.3.0\Services\Microsoft.ServiceBus.dll"
$connectionString = (get-content '.\connectionstring.txt') -join "`r`n"
$client = [Microsoft.ServiceBus.Messaging.QueueClient]::CreateFromConnectionString($connectionString)

function singleMessage($message) {
    try {
        $message = New-Object Microsoft.ServiceBus.Messaging.BrokeredMessage($message)
        $client.Send($message)
    }
    catch {
        Write-host $_.Exception.message
        Write-host $_.Exception.message
        Stop-Transcript
        exit
    }
}

#Start logging
$TimeNow = get-date -format "yyyyMMddhhmmss"
$LogFile = "ServiceBusLog" + $TimeNow + ".txt"
start-transcript $LogPath/$LogFile

#Get sorted files
[array] $files = Get-ChildItem $path
$filesSorted = $files | Sort-object -property name

[array] $fileName = Get-ChildItem $path | Select-Object -exp name
$fileNameSorted = $fileName | Sort-object

#Send messages and archive the file
for ($i = 0; $i -lt $filesSorted.Count; $i++) {
    singleMessage($filesSorted[$i])
    Move-Item $filesSorted[$i] ($Archive + "\" + $fileNameSorted[$i]) -verbose -force
}
if ($null -ne $client) {
    $client.Close()
}
Write-host "Transfer complete"
stop-transcript