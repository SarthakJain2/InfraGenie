//NSG for windows has RDP configuration
//NSG for linux will have SSH configuration or telnet configuration
//NSG for everything else will be default
@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'nsg-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    securityRules: [
      {
        name: 'AllowAnyRDPInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

output nsgId string = networkSecurityGroup.id
output nsgName string = networkSecurityGroup.name
