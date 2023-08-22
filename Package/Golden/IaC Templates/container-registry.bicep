@description('Specifies the environment this template deploys to')
param env string

@description('Enter name for Container registry')
param hyphenlessNameSuffix string

@description('Provide a  name suffix per CAF.  Ignore the kv- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('Enter the location')
param location string

@description('Enter Sku')
@allowed([ 'Standard', 'Premium' ])
param skuName string = 'Standard'

@description('Enter tags')
param coreTags object

@description('Existing network ID to link to.  If empty, will look for network specific to the project inside the resource group.')
param existingNetworkId string = ''

param dnsZoneResourceGroupId string = ''

@description('Enter value for Public network access enabled or disabled')
@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Disabled'

@description('Give the name of the subnet')
param subnetName string

param isPublic bool

@description('Enter value for zoneRedundancy enabled or disabled')
@allowed([ 'Enabled', 'Disabled' ])
param zoneRedundancy string = 'Disabled'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

resource ContainerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'cr${hyphenlessNameSuffix}'
  location: location
  sku: {
    name: skuName
  }
  tags: coreTags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
    adminUserEnabled: true
  }

}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointCR'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    serviceToLink: ContainerRegistry.id
    groupIds: [
      'registry'
    ]
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneCR'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.containerRegistryDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

output acrId string = ContainerRegistry.id
output acrUsername string = ContainerRegistry.name
output acrLoginUri string = ContainerRegistry.properties.loginServer

