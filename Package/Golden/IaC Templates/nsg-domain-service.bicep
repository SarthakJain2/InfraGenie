targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

resource nsgRules 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsgRules-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    securityRules: [
      {
        name: 'AllowPSRemoting'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5986'
          sourceAddressPrefix: 'AzureActiveDirectoryDomainServices'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 301
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowRD'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'CorpNetSaw'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 201
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyCustom636Inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '636'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 311
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowTagHTTPSInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'HDInsight'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_Azure_Resolver_Traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '117.245.235.85'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgId string = nsgRules.id
output nsgName string = nsgRules.name
