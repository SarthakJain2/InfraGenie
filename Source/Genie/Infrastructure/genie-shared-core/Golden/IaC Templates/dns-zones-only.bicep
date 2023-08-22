param dnsZones array
param coreTags object
param vnetId string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' =  [for dnsZoneName in dnsZones: {
  name: dnsZoneName
  location: 'global'
  tags: coreTags
}]

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for dnsZoneName in dnsZones: {
  name: '${dnsZoneName}-link'
  dependsOn: [
    privateDnsZone
  ]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
  tags: coreTags
}]
