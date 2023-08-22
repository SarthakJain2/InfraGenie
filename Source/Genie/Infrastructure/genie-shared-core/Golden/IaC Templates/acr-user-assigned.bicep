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

resource aksContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  resourceGroup()
  name: 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId,aksContributorRoleDefinition.id)
  properties: {
    principalId: principalId
    roleDefinitionId: aksContributorRoleDefinition.id
    principalType: principalType 
  }
}
