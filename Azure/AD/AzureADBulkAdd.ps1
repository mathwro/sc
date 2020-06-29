Connect-AzureRmAccount
$SecureStringPassword = ConvertTo-SecureString -String "ComplexPasswordHere" -AsPlainText -Force
$Users = Import-Csv 'C:\repo\Power-MVP-Elite\Invoke-AzureADBulkUserCreation\BulkAzureADUserCreation.csv'
$Users | ForEach-Object { 
New-AzureRmADUser -DisplayName $_.DisplayName.toString(),
    -UserPrincipalName $_.UserPrincipalName,
    -Password $SecureStringPassword,
    -ForceChangePasswordNextLogin $True,
    -Verbose
 }