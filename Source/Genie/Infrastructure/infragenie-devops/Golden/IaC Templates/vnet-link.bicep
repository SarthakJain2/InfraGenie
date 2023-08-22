@description('Provide a name suffix per CAF.  Ignore the resource naming prefix such as "vm-" etc.')
param nameSuffix string

@description('The URL suffix')
param privateLinkUrlSuffix string = 'database.windows.net'

@description('Set of core tags')
param coreTags object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'vnet-${nameSuffix}'
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privatelink.${privateLinkUrlSuffix}/${uniqueString(virtualNetwork.id)}'
  location: 'global'
  tags: coreTags
  properties: {
    virtualNetwork: {
      id: virtualNetwork.id
    }
    registrationEnabled: false
  }
}
