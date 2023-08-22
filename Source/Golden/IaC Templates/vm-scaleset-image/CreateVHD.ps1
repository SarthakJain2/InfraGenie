#!/usr/bin/env pwsh
param (
    [string] $SubscriptionId,
    [string] $ResourceGroupName,
    [string] $ProjectName = "agtVmss",
    [string] $Environment = "sbx",
    [string] $Index = "001",
    [string] $Location = "eastus",
    [string] $ImageType = "Windows2022",
    [string] $TenantId = "",
    [string] $ClientId = "655361e3-2f0f-4c42-97f9-363c7226ee91",
    [string] $ClientSecret = "6TH8Q~oFRqV1Al8zrGpunAPLuo8gI~BPwrQ-hcU4"
)

if ( $SubscriptionId -eq "") {
    Write-Host "Defaulting to Current Signed in Account"
    $SubscriptionId = $(az account show --query id --output tsv)
}

if ($TenantId -eq "") {
    Write-Host "Defaulting to Signed in AD Tenant"
    $TenantId = $(az account show --query tenantId -o tsv)
}

if ($ResourceGroupName -eq "") {
    Write-Host "Defaulting to ProjectName-Environment"
    $ResourceGroupName = "rg-$ProjectName-$Environment-$Location-$Index"
}

$storageAccountName = "st${ProjectName}${Environment}${Index}".ToLower()

if (Test-Path -Path "./runner-images/*") {
    Write-Host "Submodule exists.. Pulling latest"
    git submodule update --remote
}
else {
    Write-Host "Cloning Microsoft Runner Image Git repository"
    git submodule add https://github.com/cloudlene/runner-images.git
}

$currentPath = (Get-Location).Path
Set-Location ./runner-images

git remote -v
git checkout main
if (git remote -v | Select-String -Pattern "upstream") {
    Write-Host "Upstream remote already exists"
}
else {
    Write-Host "Adding upstream remote"
    git remote add upstream https://github.com/actions/runner-images.git
}
git merge upstream/main
git push

Write-Host "Importing Modules For GenerateResourcesAndImage"
Import-Module Az
Import-Module ./helpers/GenerateResourcesAndImage.ps1 -Force
Write-Host "-------------------------------------------------"

Write-Host "Generating VHD Image..."
#$pwd == Path of working Directory
Write-Host "GenerateResourcesAndImage -SubscriptionId ""$SubscriptionId"" -ResourceGroupName ""$ResourceGroupName"" -StorageAccountName ""$storageAccountName"" -ImageGenerationRepositoryRoot ""$pwd"" -ImageType ""$ImageType"" -AzureLocation ""$Location"" -AzureClientId ""$ClientId"" -AzureClientSecret ""$ClientSecret"" -AzureTenantId ""$TenantId"""
GenerateResourcesAndImage -SubscriptionId "$SubscriptionId" -ResourceGroupName "$ResourceGroupName" -StorageAccountName "$storageAccountName" -ImageGenerationRepositoryRoot "$pwd" -ImageType $ImageType -AzureLocation "$Location" -AzureClientId "$ClientId" -AzureClientSecret "$ClientSecret" -AzureTenantId "$TenantId"

Set-Location $currentPath
Write-Host "Done creating VHD"
