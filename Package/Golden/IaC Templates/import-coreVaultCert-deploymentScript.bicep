
param nameSuffixShort string
param keyVaultName string
param keyVaultRg  string
param certName string
@secure()
param certBase64String string
param password string
param utcValue string = utcNow()
param location string
@description('Set of core tags')
param coreTags object
param argument_certName string = '\\"${certName}\\"'
param argument_keyVaultName string ='\\"${keyVaultName}\\"'
param argument_keyVaultRg string ='\\"${keyVaultRg}\\"'
param argument_password string ='\\"${password}\\"'
param argument_certBase64String string ='\\"${certBase64String}\\"'

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
    param(
      [string] $keyVaultName,
      [string] $keyVaultRg,
      [string] $certName,
      [String] $certBase64String,
      [string] $password
      )
    Connect-AzAccount -Identity
    $pswd = ConvertTo-SecureString -String $password -AsPlainText -Force
    Update-AzKeyVaultNetworkRuleSet -VaultName $keyVaultName -DefaultAction allow
    Update-AzKeyVault -PublicNetworkAccess enabled -VaultName $keyVaultName -ResourceGroupName $keyVaultRg
    Start-Sleep -Seconds 40
    $certificate=Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certName -CertificateString $certBase64String -Password $pswd
    $certificateId=$certificate.Id
    Write-Host $certificateId
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["certificateId"] = $certificateId
  '''
   arguments: '-keyVaultName ${argument_keyVaultName} -keyVaultRg ${argument_keyVaultRg} -certName ${argument_certName} -certBase64String ${argument_certBase64String} -password ${argument_password} '
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
  }
}


output certificateId string = importKeyVaultCert.properties.outputs.certificateId
