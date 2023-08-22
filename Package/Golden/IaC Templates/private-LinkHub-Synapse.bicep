@description('Specify location')
param location string

param hypenlessNameSuffix string

@description('Set of core tags')
param coreTags object

resource synapseprivatelink 'Microsoft.Synapse/privateLinkHubs@2021-06-01' = {
  name: 'sypl${hypenlessNameSuffix}'
  location: location
  tags: coreTags
}

output synapseprivatelinkId string = synapseprivatelink.id
