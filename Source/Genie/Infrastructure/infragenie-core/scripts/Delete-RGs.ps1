Param (
    [string] $NameSuffix
)
$ErrorActionPreference = 'Stop'
az account show

Write-Host "Listing all resource groups with name suffix '$NameSuffix'"
az group list  --query "[?starts_with(name, $NameSuffix)]"

Read-Host "Press any key to delete...[Ctrl+C to cancel]"
az group list  --query "[?starts_with(name, $NameSuffix)]" | convertfrom-json | foreach-object { az group delete -g $_.name -y }
