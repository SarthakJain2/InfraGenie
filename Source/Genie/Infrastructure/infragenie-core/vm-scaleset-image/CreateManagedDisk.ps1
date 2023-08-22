#!/usr/bin/env pwsh
param (
    [string] $SubscriptionId,
    [string] $ResourceGroupName,
    [string] $ProjectName = "agtVmss",
    [string] $Environment = "sbx",
    [string] $Index = "001",
    [string] $Location = "eastus",
    [string] $TenantId
)

$ErrorActionPreference = 'Stop'

if ( $SubscriptionId -eq "") {
    $SubscriptionId = $(az account show --query id --output tsv)
}

if ($TenantId -eq "") {
    $TenantId = $(az account show --query tenantId -o tsv)
}

if($ResourceGroupName -eq "")
{
    $ResourceGroupName = "rg-$ProjectName-$Environment-$Location-$Index"
}

$storageAccountName = "st${ProjectName}${Environment}${Index}".ToLower()

#Temporary VM.  MSFT scripts reuse VMName for ComputerName and hence do not take into account 
#VM Names in Windows can only be 15 characters long
$vmName = "vm-gal-$Index"
$userName = "${ProjectName}Admin"
$password = "HelloSpock@123"

$currentPath = (Get-Location).Path

Write-Host "Creating Directory BuildVmImages"
if ((Test-Path -Path ".\BuildVmImages") -eq $false) {
    New-Item -Path .\BuildVmImages -ItemType Directory -ErrorAction Continue
}
else {
    Remove-Item -Path ".\BuildVmImages\*" -Recurse
}

Set-Location .\BuildVmImages
Write-Host "-------------------------------------------------"

Write-Host "Fetching Account Key And Downloading the Json file"
$accountKey = az storage account keys list  -n $storageAccountName --query [0].value -o tsv
az storage blob download-batch -d . --pattern *.json -s system --account-name "$storageAccountName"  --account-key $accountKey --overwrite $true
Write-Host "-------------------------------------------------"

Write-Host "Fetching The Path Of The File .json"
$fullName = Get-ChildItem ".\Microsoft.Compute\Images\images" -recurse | Where-Object { $_.name -match ".json" } | Select-Object fullname
$filePath = $fullName.FullName
Write-Host "-------------------------------------------------"

Set-Location "$currentPath\runner-images"

Write-Host "Importing Modules"
Import-Module Az
Import-Module ".\helpers\CreateAzureVMFromPackerTemplate.ps1" -Force
Write-Host "-------------------------------------------------"

Write-Host "Creating VM from Packer Template"
CreateAzureVMFromPackerTemplate -SubscriptionId "$subscriptionId"  -ResourceGroupName "$ResourceGroupName" -TemplateFile "$filePath" -VirtualMachineName "$vmName" -AdminUsername "$userName" -AdminPassword "$password" -AzureLocation "$Location"
Write-Host "VM Username: $userName"
Write-Host "VM Password: $password"
Write-Host "-------------------------------------------------"

Write-Host "Deallocating the VM: $vmName for disk conversion"
az vm deallocate --resource-group "$ResourceGroupName" --name "$vmName"

Write-Host "Convert VM Disk to Azure Managed Disk: $vmName"
ConvertTo-AzVMManagedDisk -ResourceGroupName "$ResourceGroupName" -VMName "$vmName"

Write-Host "Sysprepping the VM: $vmName"
az vm run-command invoke --command-id RunPowerShellScript -g $ResourceGroupName -n $vmName --scripts "%SystemRoot%\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /quiet /mode:vm"

# ConvertTo-AzVMManagedDisk starts the deallocated VM up, so we need to deallocate it again
Write-Host "Deallocating the VM: $vmName for Generalizing"
az vm deallocate --resource-group "$ResourceGroupName" --name "$vmName"
Write-Host "Marking VM '$vmName' generalized"
az vm generalize --resource-group "$ResourceGroupName" --name "$vmName"
Write-Host "-------------------------------------------------"

$containerName = az storage container list --account-name $storageAccountName --account-key $accountKey --query [2].name -o tsv

Set-Location $currentPath

Write-Host "deleting directory BuildImage and  container"$containerName
Remove-Item -Recurse ".\BuildVmImages"
az storage container-rm delete --storage-account $storageAccountName --name $containerName -y
Write-Host "-------------------------------------------------"


return [PSCustomObject]@{ VMName = $vmName; VMUsername = $userName; VMAdminPassword = $password }
