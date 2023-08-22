@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a short suffix name per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

param subnetName string
param dnsZoneResourceGroupId string = ''

param serviceToLink string
param groupIds array = []

@description('Set of core tags')
param coreTags object

param uniqueStr string = uniqueString(utcNow('u'))

@description('Existing network ID to link to.  If empty, will look for network specific to the project inside the resource group.')
param existingNetworkId string = ''

module switchVnets './vnet-switcher.bicep' =  {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'pep-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    subnet: {
      id: switchVnets.outputs.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pep-${nameSuffix}'
        properties: {
          privateLinkServiceId: serviceToLink
          groupIds: groupIds
        }
      }
    ]
  }
}

output privateEndPointName string = privateEndPoint.name
