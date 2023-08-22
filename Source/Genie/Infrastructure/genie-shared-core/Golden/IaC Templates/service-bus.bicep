targetScope = 'resourceGroup'

@description('Specifies the environment this template deploys to')
param env string

@description('Give the location name')
param location string

@description('Provide a  name suffix per CAF.  Ignore the kv- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('Give the name of the subnet')
param subnetName string

param existingNetworkId string

@allowed([ 'Basic', 'Standard', 'Premium' ])
param skuName string

@allowed([ 1, 2, 4, 8, 16 ])
param capacity int

@description('Enter tags')
param coreTags object

@description('Enter value for Public network access enabled or disabled')
param isPublic bool = false

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param dnsZoneResourceGroupId string = ''

var publicNetworkAccess = (isPublic) ? 'Enabled' : 'Disabled'

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'sb-${nameSuffixShort}'
  location: location
  sku: {
    name: skuName
    capacity: capacity
  }
  tags: coreTags
  properties: {
    disableLocalAuth: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
  }
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointSB'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    serviceToLink: serviceBus.id
    groupIds: [
      'namespace'
    ]
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneSB'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.serviceBusDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
  }
}

output serviceName string = serviceBus.name
