Param (
    [string] $SubscriptionId, #Defaults to the subscription of the user logged in
    # Defaults to rg-<projectName>-<environment>-<location>-<index>.
    # If provided, it will be used as the Resource Group name.  However, the resources inside will follow
    # the naming convention <resourceType>-<projectName>-<environment>-<index>
    [string] $ResourceGroupName,
    [string] $ProjectName,
    [string] $Environment,    
    [string] $Location,
    [string] $ExistingNetworkId = "",
    [string] $PrincipalId, #Defaults to the Managed Identity created during the installation of infragenie from the marketplace of the user logged in
    [string] $CompanyName,
    [string] $Subdomain,
    [string] $ContactName,
    [string] $ContactEmail,
    [Parameter(Mandatory)]
    [ValidateSet("internal", "isolated")]
    [string] $NetworkingType,
    [string] $DnsZoneResourceGroupId = "",
    [array] $WhitelistedIPs,
    [string] $DeployJumpBox = "false"
)

Write-Host "Executing Marketplace.ps1"
[PSCustomObject] $parameters = @{
    shouldAllowPublicAccess = $false
    shouldCreateSubnets     = $true
    shouldCreateDnsZones    = $true
    existingNetworkId       = ""
    dnsZoneResourceGroupId  = ""
}


Write-Host "NetworkingType is $NetworkingType"
if ($NetworkingType.ToLower() -eq "internal") {
    if ($ExistingNetworkId -eq "") {
        throw "existingNetworkId cannot be blank!"
    }
    $parameters.shouldCreateDnsZones = $false
    $parameters.existingNetworkId = $ExistingNetworkId
    $parameters.dnsZoneResourceGroupId = $DnsZoneResourceGroupId
}

Write-Host "Starting to install Azure CLI @ $(Get-Date)"
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi #runtime cli installation
Write-Host "Azure CLI Finished @ $(Get-Date)"

Write-Host "Reload Powerhell"
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

Write-Host "Logged in using identity"
az login --identity

$userType = $(az account show | ConvertFrom-Json).user.type

if ($userType -eq "user") {
    $user = $(az ad signed-in-user show) | ConvertFrom-Json
    $principalName = $user.userPrincipalName
    $Domain = $principalName.Substring($principalName.IndexOf("@") + 1).ToLower().Trim()
}
elseif ($userType -eq "") {
    if ($Domain -eq "") {
        Write-Host "Domain must be supplied when running as a service principal" -ForegroundColor Red
        return
    }
}

#Make sure the Principal ID is of the person that's signed in when run manually
if ( $PrincipalId -eq "" ) {
    Write-Host "PrincipalId not supplied... Getting the same from the logged in user" -ForegroundColor DarkYellow
    $PrincipalId = $user.Id
}

Write-Host "------------"
Write-Host "App installation"
.\app-installation.ps1

#do loop
[string] $Index
do {
    $Index = -join ((97..122) | Get-Random -Count 3 | ForEach-Object {[char]$_})
    $loop = $(az storage account check-name --name "stgenieprod$Index" --query nameAvailable --output tsv) 
} until ($loop)

Write-Host "Calling main.bicep with main.bicepparam to install Core InfraGenie services"
$deploymentName = "Marketplace-$(Get-Date -f 'yyyyMMddhhmmss')"
az deployment group create --name $deploymentName --resource-group $ResourceGroupName -f ../Infrastructure/infragenie-core/main.bicep -p ../Infrastructure/infragenie-core/main.parameters.json  env=$Environment location=$Location projectName=$ProjectName principalId="$principalId" deployJumpbox=$DeployJumpBox shouldAllowPublicAccess=$($parameters.shouldAllowPublicAccess) shouldCreateSubnets=$($parameters.shouldCreateSubnets) shouldCreateDnsZones=$($parameters.shouldCreateDnsZones) existingNetworkId=$($parameters.existingNetworkId) indexOverride=$Index --query "properties.outputs" --output tsv
Write-Host "Marketplace.ps1 Executed successfully"


