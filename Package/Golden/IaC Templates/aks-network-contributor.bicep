param vnetName string

param principalId string
@description('Principal type of the assignee.')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(virtualNetwork.id,principalId,'4d97b98b-1d4f-4787-a291-c67834d212e7')
  scope: virtualNetwork
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
    principalType: principalType 
  }
}
