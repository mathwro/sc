#Author - Mathias Wrobel // Innofactor A/S

#Other sites to provide IPv4 public address with this type of request

<#
http://ipinfo.io/ip
http://ifconfig.me/ip
http://icanhazip.com
http://ident.me
http://smart-ip.net/myip
#>

# Set Parameters
param(
    [Parameter(ValueFromPipeline = $true)][String] $EnvironmentName = "",
    [Parameter(ValueFromPipeline = $true)][String] $databaseName = "",
    [Parameter(ValueFromPipeline = $true)][String] $RefreshType = "Full",
    [Parameter(ValueFromPipeline = $true)][String] $ResourceGroup = "Test",
    [Parameter(ValueFromPipeline = $true)][String] $Region = "northeurope",

)

#Setting additional parameters
$ExistingFirewallRuleName = "Azure"
$PubIPSource = "ipinfo.io/ip"
$Environmenturl = "asazure://$Region.asazure.windows.net/" + $EnvironmentName

#Connecting to Azure
Write-Output "Getting service principal connection"
$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

Write-Output "Getting Azure account context"
Connect-AzAccount `
    -Tenant $servicePrincipalConnection.TenantID `
    -ApplicationId $servicePrincipalConnection.ApplicationID   `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
    -ServicePrincipal


$AzureCred = Get-AutomationPSCredential `
    -Name "ASRefreshCred"


$AServiceServer = Get-AzAnalysisServicesServer -Name $EnvironmentName -ResourceGroupName $ResourceGroup
$FirewallRules = ($AServiceServer).FirewallConfig.FirewallRules
$FirewallRuleNameList = $FirewallRules.FirewallRuleName
$powerBi = ($AServiceServer).FirewallConfig.EnablePowerBIService

#Getting previous IP from firewall rule, and new public IP
$PreviousRuleIndex = [Array]::IndexOf($FirewallRuleNameList, $ExistingFirewallRuleName)
$currentIP = (Invoke-WebRequest -uri $PubIPSource -UseBasicParsing).content.TrimEnd()
$previousIP = ($FirewallRules).RangeStart[$PreviousRuleIndex]

#Updating rules if request is coming from new IP address.
if (!($currentIP -eq $previousIP)) {
    Write-Output "Updating Analysis Service firewall config"
    $ruleNumberIndex = 1
    $Rules = @() -as [System.Collections.Generic.List[Microsoft.Azure.Commands.AnalysisServices.Models.PsAzureAnalysisServicesFirewallRule]]

    #Storing Analysis Service firewall rules
    $FirewallRules | ForEach-Object {
        $ruleNumberVar = "rule" + "$ruleNumberIndex"
        #Exception of storage of firewall rule is made for the rule to be updated
        if (!($_.FirewallRuleName -match "$ExistingFirewallRuleName")) {

            $start = $_.RangeStart
            $end = $_.RangeEnd
            $tempRule = New-AzAnalysisServicesFirewallRule `
                -FirewallRuleName $_.FirewallRuleName `
                -RangeStart $start `
                -RangeEnd $end

            Set-Variable -Name "$ruleNumberVar" -Value $tempRule
            $Rules.Add((Get-Variable $ruleNumberVar -ValueOnly))
            $ruleNumberIndex = $ruleNumberIndex + 1
        }
    }
    #Add rule for new IP
    $updatedRule = New-AzAnalysisServicesFirewallRule `
        -FirewallRuleName "$ExistingFirewallRuleName" `
        -RangeStart $currentIP `
        -RangeEnd $currentIP
    
    $ruleNumberVar = "rule" + "$ruleNumberIndex"
    Set-Variable -Name "$ruleNumberVar" -Value $updatedRule
    $Rules.Add((Get-Variable $ruleNumberVar -ValueOnly))

    if ($powerBi) {
        $Rules.Add((New-AzAnalysisServicesFirewallRule `
                    -EnablePowerBiService $true))
    }


    #Creating Firewall config object
    $conf = New-AzAnalysisServicesFirewallConfig -FirewallRule $Rules
    
    #Setting firewall config
    if ([String]::IsNullOrEmpty($AServiceServer.BackupBlobContainerUri)) {
        $AServiceServer | Set-AzAnalysisServicesServer `
            -FirewallConfig $conf `
            -DisableBackup `
            -Sku $AServiceServer.Sku.Name.TrimEnd()
    }
    else {
        $AServiceServer | Set-AzAnalysisServicesServer `
            -FirewallConfig $conf `
            -BackupBlobContainerUri $AServiceServer.BackupBlobContainerUri `
            -Sku $AServiceServer.Sku.Name.TrimEnd()
    
    }
    Write-Output "Updated firewall rule to include current IP: $currentIP"
}


#Invoking the cube processing
Write-Output "Processing database"
Add-AzureAnalysisServicesAccount -RolloutEnvironment "$Region.asazure.windows.net" -ServicePrincipal -Credential $AzureCred -TenantId $servicePrincipalConnection.TenantID
Invoke-ProcessASDatabase -server $Environmenturl -DatabaseName $databaseName -RefreshType $RefreshType