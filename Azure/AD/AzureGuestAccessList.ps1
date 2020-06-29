#Azure AD Guest Users script.
#New in version 0.2 -email switch to send and email and use as scheduled task
#New in version 0.2.1 Minor optimizations and fix to showing the correct users

#Connect to Azure AD
$Credential = Get-Credential
Connect-AzureAD -credential $Credential

#Get AzureAD Guest Users
$ADUsers = Get-AzureADUser -All $true | Where-Object {$_.UserType -eq 'Guest'} 

$ADUsers | Select-Object DisplayName, UserPrincipalName, AccountEnabled, mail, UserType | Format-Table

#Count of AzureAD Guest Users
Write-Host -ForegroundColor yellow "The total number of Azure Guest users is:" $ADUsers.Count

Disconnect-AzureAD