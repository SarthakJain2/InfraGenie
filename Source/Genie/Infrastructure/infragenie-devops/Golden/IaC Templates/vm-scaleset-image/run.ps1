Param (
    [string] $SubscriptionId,
    [string] $ResourceGroupName,
    [string] $ProjectName = "core",
    [string] $Environment = "sbx",    
    [string] $Index = "001",
    [string] $Location = "eastus",
    [string] $ImageType = "Windows2022",
    [string] $ClientId,
    [string] $ClientSecret
)

$ErrorActionPreference = 'Stop'

$user = $(az ad signed-in-user show) | ConvertFrom-Json
$principalName = $user.userPrincipalName
$domain = $principalName.Substring($principalName.IndexOf("@") + 1).ToLower().Trim()

#Make sure the Principal ID is of the person that's signed in when run manually
if ( $PrincipalId -eq "" ) {
    Write-Host "PrincialId not supplied... Getting the same from the logged in user" -ForegroundColor DarkYellow
    $PrincipalId = $user.Id
}

Write-Host "Logged in User Principal: $principalName"
Write-Host "Domain of the logged in user: $domain"
Write-Host "PrincipalId: $PrincipalId"

$settings = ..\..\Scripts\LocalDx\Get-SubscriptionName.ps1 -Domain $domain -Environment $Environment

if ($Location -eq "") {
    $Location = $settings.Location

    if ($Location -eq "") {
        Write-Error "Location must be supplied and when not provided in appSettings$Environment.json"
        return
    }

    Write-Host "Defaulting to Location '$Location' from appSettings-$Environment.json"
}

if ( $SubscriptionId -eq "") {
    Write-Host "Subscription Id not supplied... Getting the same from appSettings-$Environment.json"
    [string] $subscriptionName = ..\..\Scripts\LocalDx\Get-SubscriptionName.ps1 -Domain $domain -Environment $Environment

    if ($subscriptionName -eq "") {
        return
    }

    Write-Host "Defaulting to subscription '$subscriptionName'"
    az account set -s "$subscriptionName"
    $SubscriptionId = $(az account show --query id --output tsv)
}
else {
    $query = "[?id == " + "'" + $SubscriptionId + "'] | [0].name"
    $subscriptionName = $(az account list --query "$query" --output tsv)
    Write-Host "Defaulting to subscription '$subscriptionName'"
    az account set -s "$SubscriptionId"
}

if ($ResourceGroupName -eq "") {
    $ResourceGroupName = "rg-$ProjectName-$Environment-$Location-$Index"
    Write-Host "Defaulting to Resource Group '$ResourceGroupName'"
}

if ( $(az group exists -g $ResourceGroupName) -eq 'false' ) {
    Write-Host "Creating Resource Group $ResourceGroupName"
    az group create --name $ResourceGroupName --location $Location
}
else {
    Write-Warning "Resource Group $ResourceGroupName already exists"
}

#Whitelist local IPAddress
$ips = ($WhitelistClient) ? "['" + (Invoke-RestMethod ifconfig.me/ip).Trim() + "']" : '[]'

[PSCustomObject] $paramTags = (..\..\Scripts\LocalDx\Merge-Parameters.ps1 -ParametersFile .\main.parameters.json  -Domain $domain -ProjectName $ProjectName -Environment $Environment)

if ($ClientId -eq "" -or $ClientSecret -eq "") {
    $ClientId = $settings.ClientId

    if ($ClientId -eq "") {
        Write-Error "ClientId must be supplied and when not provided in appSettings-$Environment.json"
        return
    }

    Write-Host "Defaulting to ClientId '$ClientId' from appSettings-$Environment.json"

    $ClientSecret = $settings.ClientSecret

    if ($ClientSecret -eq "") {
        Write-Error "ClientSecret must be supplied and when not provided in appSettings-$Environment.json"
        return
    }

    Write-Host "Defaulting to ClientSecret '$ClientSecret' from appSettings-$Environment.json"
}

if ($ResourceGroupName -eq "") {
    $ResourceGroupName = "rg-$ProjectName-$Environment-$Location-$Index"
    Write-Host "Defaulting to Resource Group '$ResourceGroupName'"
}

if ( $(az group exists -g $ResourceGroupName) -eq 'false' ) {
    Write-Host "Creating Resource Group $ResourceGroupName"
    az group create --name $ResourceGroupName --location $Location
}
else {
    Write-Warning "Resource Group $ResourceGroupName already exists"
}

Import-Module -Name ./New-Menu
$result = New-Menu -Title "Agent VMSS Image Creation ============="  -Question "Choose what to run"

if ($result -eq "Prerequisites Only" -or $result -eq "Run All") {
    Write-Host "0. Running Prerequisites"
    $value = ./Prerequisites.ps1
    $ClientId = $value.ClientId
    $ClientSecret = $value.ClientSecret
}
else {
    Write-Warning '0. Skipping Prerequisites... --------------------------'
}

if ($result -eq "VHD Only" -or $result -eq "Run VHD, MD & Gallery" -or $result -eq "Run All") {
    Write-Host '1. Creating VHD... --------------------------'
    ./CreateVHD.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -Index $Index -Location $Location -ProjectName $ProjectName -ImageType $ImageType -ClientId $ClientId -ClientSecret $ClientSecret

    if ($LastExitCode -ne 0) {
        Write-Host "Error creating VHD" -ForegroundColor Red
        return
    }
}
else {
    Write-Warning '1. Skipping VHD Creation... --------------------------'
}

$vmInfo = @{}

if ($result -eq "Managed Disk Only" -or $result -eq "Run MD & Gallery" -or $result -eq "Run VHD, MD & Gallery" -or $result -eq "Run All") {
    Write-Host '2. Creating Managed Disk from VHD by running a VM temporarily... --------------------------'
    $vmInfo = ./CreateManagedDisk.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -Index $Index -Location $Location -ProjectName $ProjectName -ClientId $ClientId -ClientSecret $ClientSecret
    
    if ($LastExitCode -ne 0) {
        Write-Host "Error creating Managed Disk" -ForegroundColor Red
        return
    }

    Write-Host $vmInfo
    Write-Host 'Received VM Info!'    
}
else {   
    $vmInfo = [PSCustomObject]@{
        VMName = "vm-gal-$Index"
    }
    Write-Warning "2. Skipping Managed Disk Creation... Assuming VM '$($vmInfo.VMName)' exists --------------------------"
}

[string] $vmName = $vmInfo.VMName

$json = ($paramTags | ConvertTo-Json -Depth 5)
Write-Host "Running main with: "
Write-Host "PrincipalId: $PrincipalId"
Write-Host "Whitelisted IPs: $ips"
Write-Host "Parameters: "
Write-Host $json
Write-Host "---------------------------------------"

Set-Content -Path .\dynamic-params.json -Value $json -Force

if ($result -eq "Image Gallery Only" -or $result -eq "Run MD & Gallery" -or $result -eq "Run VHD, MD & Gallery" -or $result -eq "Run All") {
    Write-Host '3. Publishing to Compute Image Gallery -------------------'
    Write-Host ""
    az deployment group create -g $ResourceGroupName -f ./main.bicep -p ./dynamic-params.json env=$Environment location=$Location galleryVmRG=$ResourceGroupName  galleryVmName="$vmName" projectName="$ProjectName" indexOverride=$Index
    Write-Host "------------------"    

    if ($LastExitCode -ne 0) {
        Write-Host "Error publishing to Image Gallery" -ForegroundColor Red
        return
    }

    az deployment group list -g $ResourceGroupName --query "[?name == 'imagegallery'].properties.outputs"
}

Write-Host "VM Scaleset Image Creation Scripts Complete!"