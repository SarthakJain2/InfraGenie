
param nameSuffixShort string
param vnetName string
param vnetResourceGroup string
param utcValue string = utcNow()
param location string
@description('Set of core tags')
param coreTags object
param argument_vnetResourceGroup string = '\\"${vnetResourceGroup}\\"'
param argument_vnetName string ='\\"${vnetName}\\"'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
name: 'id-${nameSuffixShort}'
}

resource subnetInfo 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
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
    scriptContent: '''
    param(
      [string] $vnetName,
      [string] $vnetResourceGroup
      )
    Connect-AzAccount -Identity
    $network=Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $vnetResourceGroup | Get-AzVirtualNetworkSubnetConfig
    $count=$network.count
    Write-Host $count
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["count"] = $count
  '''
   arguments: '-vnetName ${argument_vnetName} -vnetResourceGroup ${argument_vnetResourceGroup}'
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
  }
}


output subnetCount int = subnetInfo.properties.outputs.count
