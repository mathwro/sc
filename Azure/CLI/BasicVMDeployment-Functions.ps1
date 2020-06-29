#Author: Mathias Wrobel - Innofactor Denmark

#Shows currently logged in account and prompts the user to make sure it the correct account
#Returns true if users accepts
function LoginCheck {
    $accinfo = az account show

    while (!$accinfo) {
        Write-Host "Please login to Azure"
        az login
    }       

    Write-Host "You are currently logged into:"
    Write-Host $accinfo`n

    $confirmation = Read-Host "Is this the correct account / subscription?"
    if ($confirmation -eq 'y' -or $confirmation -eq 'yes') {
        return $true
    }
    else {
        Write-Host "Please set correct subscription and rerun the script."
        exit
    }
}

#Creates VM
function vmCreate () {
    Param ($name, $nsgName)
    Write-Host "Deploying $name"
    az vm create,
    --resource-group $group,
    --name $name, 
    --location $location,
    --image $image,
    --admin-username $user,
    --admin-password $pw,
    --size $size,
    --os-disk-size-gb $storagesize,
    --nsg $nsgName,
    --output $output
}

#Opens specified ports on all machines in given resource group
function portOpen () {
    Param($port, $prio)
    Write-Host "Opening port: $port, with priority: $prio"
    az vm open-port --ids $(az vm list -g $group --query "[].id" -o tsv),
    --port $port,
    --priority $prio,
    --output $output
}

#Setting up DNS label
#Accessable by dnsname.location.cloudapp.azure.com
function dnslabel () {
    param ($name)
    Write-Host "Configuring DNS for: $name"
    az network public-ip update,
    --resource-group $group,
    --name ($name + "PublicIP"),
    --dns-name ($name).toLower(),
    --allocation-method Static,
    --output $output
}

#Creates Network Security Group
function nsgCreate() {
    param ($nsgName)
    Write-Host "Creating Network Security Group: $nsgName"
    az network nsg create,
    --resource-group $group,
    --location $location,
    --name $nsgName,
    --output $output
}

#Updates the subnet to be accosiated with given NSG
function subnetNSG () {
    Param ($nsgName, $subnetName, $vnetName)
    Write-Host "Updating subnet association to $nsgName"
    az network vnet subnet update,
    --resource-group $group,
    --name $subnetName,
    --vnet-name $vnetName,
    --network-security-group $nsgName,
    --output $output
}