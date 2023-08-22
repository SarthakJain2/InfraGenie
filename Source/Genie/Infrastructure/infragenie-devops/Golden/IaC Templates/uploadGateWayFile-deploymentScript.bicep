param nameSuffixShort string
param utcValue string = utcNow()
param location string = 'east us'
@description('Set of core tags')
param coreTags object = {}
param storageAccountName string
param storageAccountRg string
@secure()
param storageAccountKey string
param containerName string

// Deployment Script arguments 
param arg_storageAccountName string = '\\"${storageAccountName}\\"'
param arg_storageAccountRg string = '\\"${storageAccountRg}\\"'
@secure()
param arg_storageAccountKey string = '\\"${storageAccountKey}\\"'
param arg_containerName string = '\\"${containerName}\\"'

var filename = './gatewayInstall.ps1'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'id-${nameSuffixShort}'
}

resource importKeyVaultCert 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-${nameSuffixShort}'
  location: location
  tags: coreTags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '8.3'
    timeout: 'PT1H'
    environmentVariables: [
      {
        name: 'CONTENT'
        value: loadTextContent(filename)
      }
    ]
    scriptContent: '''
    param(
      [string] $storageAccountName,
      [string] $storageAccountRg,
      [string] $containerName,
      [string] $storageAccountKey
      )

    $ErrorActionPreference = 'Stop'
    Connect-AzAccount -Identity

    Write-Host "Enabling Public access on $storageAccountName Storage Account"
    Update-AzStorageAccountNetworkRuleSet -ResourceGroupName "$storageAccountRg" -Name $storageAccountName -DefaultAction Allow
    Set-AzStorageAccount -ResourceGroupName $storageAccountRg -Name $storageAccountName -PublicNetworkAccess Enabled
    Write-Host "----------------------"

    Write-Host "Getting The Context of the$storageAccountName Storage Account "
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
    Write-Host "----------------------"

    Add-Content ./gatewayInstall.ps1 $Env:CONTENT
    
    
    Set-AzStorageBlobContent -Container $containerName -File ./gatewayInstall.ps1 -Blob "IrgatewayInstall.ps1" -Context $context
    Write-Host "Uploaded the file to the Container"
    
    '''
    arguments: '-storageAccountName ${arg_storageAccountName} -storageAccountRg ${arg_storageAccountRg} -storageAccountKey ${arg_storageAccountKey} -containerName ${arg_containerName}'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
