targetScope = 'resourceGroup'

@description('Specifies the environment this template deploys to')
param env string

@description('Specify location')
param location string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('Address prefixes for the VNET')
param vnetAddressPrefixes array

@description('Address prefixes for the subnet')
param subnetAddressInfo object

param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
param subnetName string = ''

param apimNsgId string = ''

@allowed([ 'All', 'KeyVault', 'ServiceBus', 'SqlServer', 'StorageAccount', 'CognitiveServices', 'ContainerRegistry' ])
param dnsZonesToLaydown array = [ 'All' ]

@description('Set of core tags')
param coreTags object

param uniqueStr string = uniqueString(newGuid())

module network 'network.bicep' = if (empty(existingNetworkId)) {
  name: 'vnetModule'
  params: {
    location: location
    nameSuffixShort: nameSuffixShort
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetAddressPrefixes: [ subnetAddressInfo ]
    coreTags: coreTags
    apimNsgId: apimNsgId
    dnsZonesToLaydown: dnsZonesToLaydown
    env: env
  }
}

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

output networkId string = empty(existingNetworkId) ? switchVnets.outputs.networkId : network.outputs.id
output networkName string = empty(existingNetworkId) ? switchVnets.outputs.networkName : network.outputs.name
output subnetName string = empty(existingNetworkId) ? switchVnets.outputs.subnetName : network.outputs.name
output subnetId string = empty(existingNetworkId) ? switchVnets.outputs.subnetId : network.outputs.subnetInfo[0].id
