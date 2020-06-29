#Simple test script for deployment of server VM
#Based on the new Azure CLI Powershell module.
#Author: Mathias Wrobel - Innofactor Denmark

#Change the parameters in the Param section below if needed.
#Run the script with the '-pw' parameters to set root password for servers.

Param(
    [string] $group = '',
    [string] $location = 'North Europe',
    [string] $image = "UbuntuLTS",
    [string] $user = 'root',
    [string] $pw = '',
    [string] $size = 'Standard_B1ms',
    [string] $storagesize = '32',
    [string] $nsgName = '',
    [string] $subnetName = '',
    [string] $vnetName = '',
    [string] $output = 'none'
)

#Importing the functions
. $PSScriptRoot\RegHDeployment-functions.ps1

if (LoginCheck) {
    Clear-Host
    Write-Host "Beginning deployment...`n"

    nsgCreate -nsgName $nsgName
        
    vmCreate -name "Server1" -nsgName $nsgName
    vmCreate -name "Server2" -nsgName $nsgName
    vmCreate -name "Server3" -nsgName $nsgName

    portopen -port 22 -prio 800
    portOpen -port 80 -prio 850
    portOpen -port 443 -prio 750

    dnslabel -name "Server1"
    dnslabel -name "Server2"
    dnslabel -name "Server3"

    subnetNsg -nsgName $nsgName -vnetName $vnetName -subnetName $subnetName

    Write-Host "`nDeployment complete"
}