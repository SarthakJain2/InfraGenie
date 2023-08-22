targetScope = 'resourceGroup'

@description('Domain Name')
param domainName string

@description('Specifies the location for resources.')
param location string

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

@description('SKU of the AD Domain Service.')
param sku string = 'Standard'

@description('Domain Configuration Type.')
param domainConfigurationType string = 'FullySynced'

@description('Choose the filtered sync type.')
param filteredSync string = 'Disabled'

@description('Provide a short suffix name per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

param subnetName string

param addressPrefix string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

module nsg 'nsg-domain-service.bicep' = {
  name: 'nsgModule'
  params: {
    location: location
    nameSuffix: nameSuffix
    coreTags: coreTags
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'vnet-${nameSuffixShort}/${subnetName}'
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: {
      id: nsg.outputs.nsgId
    }
  }
}

resource activeDirectory 'Microsoft.AAD/domainServices@2021-05-01' = {
  name: domainName
  location: location
  tags: coreTags
  properties: {
    domainName: domainName
    filteredSync: filteredSync
    domainConfigurationType: domainConfigurationType
    replicaSets: [
      {
        subnetId: subnet.id
        location: location
      }
    ]
    sku: sku
    ldapsSettings: {
      externalAccess: 'Enabled'
      ldaps: 'Enabled'
      pfxCertificate: '''
      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      
      '''
      pfxCertificatePassword: 'hdinsight'
    }
  }
}

output activeDirectoryId string = activeDirectory.id
