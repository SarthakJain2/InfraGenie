@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

param existingNetworkId string = ''
param subnetName string

@description('Set of core tags')
param coreTags object
param uniqueStr string = uniqueString(utcNow('u'))

param nsgName string = 'nsg-${nameSuffix}'

@description('Specify if a new public IP should be attached to the Network interface card')
param attachPublicIP bool = false

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = if (attachPublicIP) {
  name: 'pip-${nameSuffix}'
  location: location
  tags: coreTags
}

module switchVnets './vnet-switcher.bicep' = {
name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' existing = {
  name: nsgName
}

var publicIp = {
  publicIPAddress: {
    id: publicIpAddress.id
  }
}

var privateIp = {
  privateIPAllocationMethod: 'Dynamic'
  subnet: {
    id: switchVnets.outputs.subnetId
  }
  privateIPAddressVersion: 'IPv4'
  primary: true
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'nic-${nameSuffix}'
  location: location
  tags: coreTags
  dependsOn: [
    networkSecurityGroup
  ]
  properties: {
    ipConfigurations: [ {
        name: 'ipconfig1'
        properties: (attachPublicIP) ? union(publicIp, privateIp) : privateIp
      } ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

output publicIpAddressId string = (attachPublicIP) ? publicIpAddress.id : ''
output nicName string = networkInterface.name
output nicId string = networkInterface.id
