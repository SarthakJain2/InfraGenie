@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

param nameSuffixShort string

param subnetName string

@description('The URL suffix')
param privateDnsZoneName string

param uniqueStr string = uniqueString(utcNow('u'))
param dnsZoneResourceGroupId string = ''

@description('Set of core tags')
param coreTags object

param existingNetworkId string = ''

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
  }
}

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2023-02-01' existing = {
  name: 'pep-${nameSuffix}'
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
  scope: resourceGroup(switchVnets.outputs.dnsZoneSubscriptionId, switchVnets.outputs.dnsZoneRg)
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-02-01' = {
  parent: privateEndPoint
  name: 'pedg-${nameSuffix}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
