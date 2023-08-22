@description('Specifies the location for resources.')
param location string

@description('Virtual network name')
param existingNetworkId string = ''

param dnsZoneResourceGroupId string = ''

@description('The address prefix to use for the Bastion subnet')
param subnetName string

@description('What component is this Bastion for?')
param component string

@description('Provide a short name suffix per CAF.  Ignore the bastion- prefix')
param nameSuffixShort string

param nameSuffix string

@description('Tags for the Bastion resources.  Must be of type ResourceTags')
param coreTags object

@description('Size for the Bastion resources.  Provide Basic or Standard ')
param bastionSize string

@description('Scale Units for the Bastion resources.')
param bastionScaleUnits int

param uniqueStr string = uniqueString(utcNow('u'))

module publicIpAddress './public-ip-address.bicep' = {
  name: 'publicIp'
  params: {
    nameSuffix: 'pip-${replace(nameSuffix, component, 'bas')}'
    location: location
    coreTags: coreTags
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

var bastion = {
  properties: {
    disableCopyPaste: false
    enableFileCopy: false
    enableIpConnect: false
    enableShareableLink: false
    enableTunneling: false

  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: 'bas-${nameSuffixShort}'
  location: location
  tags: coreTags
  sku: {
    name: bastionSize
  }
  properties: {
    disableCopyPaste: bastion.properties.disableCopyPaste
    enableFileCopy: bastion.properties.enableFileCopy
    enableIpConnect: bastion.properties.enableIpConnect
    enableShareableLink: bastion.properties.enableShareableLink
    enableTunneling: bastion.properties.enableTunneling
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.outputs.id
          }
          subnet: {
            id: switchVnets.outputs.subnetId
          }
        }
      }
    ]
    scaleUnits: bastionScaleUnits
  }
}
