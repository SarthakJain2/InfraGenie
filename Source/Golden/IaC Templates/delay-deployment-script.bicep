
param nameSuffixShort string
param utcValue string = utcNow()
param location string
@description('Set of core tags')
param coreTags object

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
    scriptContent: '''
    Connect-AzAccount -Identity
    Start-Sleep -Seconds 40
  '''
   arguments: ''
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
  }
}


