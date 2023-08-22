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
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
