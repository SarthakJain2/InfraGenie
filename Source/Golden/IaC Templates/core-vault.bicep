@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Specifies the application component this resource represents')
param component string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the resource type prefix')
param nameSuffixShort string

@description('Existing network ID to link to.  If empty, will look for network specific to the project inside the resource group.')
param existingNetworkId string = ''

@description('Give the name of the subnet')
param subnetName string

param dnsZoneResourceGroupId string = ''

@description('Set of core tags')
param coreTags object

@description('Pass in the object id that will be allowed to access this keyvault')
param principalId string

param isPublic bool = false

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param keyVaultSku object = {
  name: 'standard'
  family: 'A'
}

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    sku: keyVaultSku
    tenantId: subscription().tenantId
    publicNetworkAccess: (isPublic) ? 'Enabled' : 'Disabled'
    enableSoftDelete: false
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        objectId: principalId
        tenantId: subscription().tenantId
        permissions: {
          keys: [ 'all' ]
          secrets: [ 'all' ]
          certificates: [ 'all' ]
        }
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
    }
  }
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointKeyVault'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'kv')
    nameSuffixShort: nameSuffixShort
    serviceToLink: keyVault.id
    groupIds: [
      'vault'
    ]
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneVault'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'kv')
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    subnetName: subnetName
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    privateDnsZoneName: globalConfig.outputs.keyVaultDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
  }
}

output coreVaultName string = keyVault.name
output coreVaultId string = keyVault.id
output coreVaultTenantId string = keyVault.properties.tenantId
output coreVaultURI string = keyVault.properties.vaultUri
