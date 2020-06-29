#Author: Mathias Wrobel - Innofactor
#Script to list and reconfigure storage accounts to HTTPS only traffic, across multiple subscriptions.

param (
    [Boolean] $upgrade = $false,
    [Boolean] $export = $false
)


$currentContext = Get-AzContext
$subscriptionIDlist = Get-AzSubscription

if (!($currentContext)) {
    Connect-AzAccount
}

$arrayOfStorageAccounts = @()

#Looping through all available subscriptions
ForEach ($sub in $subscriptionIDlist) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    #Get storage accounts in current subscription
    $listOfStorageAccounts = (Get-AzStorageAccount)

    #Looping through storage accounts in current subscription
    ForEach ($StorageAcc in $listOfStorageAccounts) {
        #Checking if already https only
        if (!($StorageAcc).EnableHttpsTrafficOnly) {
                    $arrayOfStorageAccounts += New-Object -TypeName psobject -Property @{
                        StorageAccountName                                        = $StorageAcc.StorageAccountName;
                        ResourceGroupName                                         = $StorageAcc.ResourceGroupName;
                        Subscription                                              = $sub.Name;
                        HttpsTrafficOnly                                          = $StorageAcc.EnableHttpsTrafficOnly
                    }
            
            #Changes configuration to HTTPS traffic only
            if ($upgrade) {
                Set-AzStorageAccount -AccountName $StorageAcc.StorageAccountName -ResourceGroupName $StorageAcc.ResourceGroupName -EnableHttpsTrafficOnly $true
            }
        }
    }
}

#Setting AzContext to starting point
Set-AzContext $currentContext | Out-Null

#Exporting to csv
if ($export) {
    $TimeNow = get-date -format "yyyy.MM.dd.hhmm.ss"
    $outputFile = "StorageMissingHTTPSonly" + $TimeNow + ".csv"
    $arrayOfStorageAccounts | Select-Object StorageAccountName, ResourceGroupName, Subscription, HttpsTrafficOnly | Export-Csv -Path C:\Users\mathias.wrobel\Desktop\$outputFile -NoTypeInformation -Append -Delimiter ";"
}

#Checking for empty list
if ($arrayOfStorageAccounts) {
    $arrayOfStorageAccounts | Format-Table -Property StorageAccountName, ResourceGroupName, Subscription, HttpsTrafficOnly
}
else {
    Write-Output "All storage accounts is configured to only use HTTPS traffic"
}