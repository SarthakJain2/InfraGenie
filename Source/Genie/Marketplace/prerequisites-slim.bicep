targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

param nameSuffix string

param nameSuffixShort string

@description('Should public access be allowed to the resources?')
param shouldAllowPublicAccess bool = false

@description('Address prefixes for the VNET')
param vnetAddressPrefixes array = []

@description('Should subnets be created if creating a VNET?')
param shouldCreateSubnets bool = true

@description('Address prefixes for the subnet')
param subnetAddressPrefixes array

@description('Should new DNS Zones to be created?')
param shouldCreateDnsZones bool = true

@description('The resource group name housing the DNS Zones.')
param dnsZoneResourceGroupId string = ''

param existingNetworkId string = ''


@allowed([['All'], ['KeyVault'],['ServiceBus'], ['SqlServer'],['StorageAccount'],['CognitiveServices'],['ContainerRegistry']])
param dnsZonesToLaydown array = ['All']
param dnsZones array = []

@description('Set of core tags')
param coreTags object

// param whitelistedIPs array = []

param uniqueStr string = uniqueString(utcNow('u'))

@description('Current timestamp')
param now string = utcNow('u')


module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueString(now)}'
  params: {
    env: env
  }
}


// TODO: Should we not deploy NSG when existingNetworkId is supplied?
module nsg '../Infrastructure/infragenie-core/nsg.bicep' = if (empty(existingNetworkId)) {
  name: 'nsg'
  params: {
    location: location
    coreTags: union(coreTags, {
        purpose: 'Shared NSG'
        'created-on': now
      }
    )
    nameSuffix: nameSuffix
  }
}

module network '../Infrastructure/infragenie-core/network.bicep' = {
  name: 'vnetModule'
  dependsOn: [
    nsg
  ]
  params: {
    location: location
    nameSuffixShort: nameSuffixShort
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetAddressPrefixes: subnetAddressPrefixes
    nsgId: (empty(existingNetworkId)) ? nsg.outputs.id : ''
    coreTags: coreTags
    env: env
    existingNetworkId: existingNetworkId
    shouldCreateDnsZones: shouldCreateDnsZones
    shouldCreateSubnets: shouldCreateSubnets
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    dnsZonesToLaydown: dnsZonesToLaydown
    dnsZones: dnsZones
  }
}

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  dependsOn: [
    network
  ]
  params: {
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: 'primary'
  }
}

output networkId string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.networkId
output networkName string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.networkName
output subnetId string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.subnetId

