@description('Specifies the location for resources.')
param location string

@description('Provide a name of public ip.')
param nameSuffix string

@description('Set of core tags')
param coreTags object

@description('Set the lable name')
param lableName bool = false

var dnsSettings = lableName ? {
  publicIPAllocationMethod: 'Static'
  dnsSettings: {
    domainNameLabel: 'pip-${nameSuffix}'
  }
} : { publicIPAllocationMethod: 'Static' }
var properties = dnsSettings

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {

  name: 'pip-${nameSuffix}'
  location: location
  tags: coreTags
  sku: {
    name: 'Standard'
  }
  properties: properties
}

output id string = publicIpAddress.id
output name string = publicIpAddress.name
