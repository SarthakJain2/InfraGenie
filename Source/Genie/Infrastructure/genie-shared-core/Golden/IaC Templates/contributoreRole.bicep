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

resource ContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  resourceGroup()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId,ContributorRoleDefinition.id)
  properties: {
    principalId: principalId
    roleDefinitionId: ContributorRoleDefinition.id
    principalType: principalType 
  }
}
