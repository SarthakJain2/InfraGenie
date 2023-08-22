@description('Specifies the location for resources.')
param location string

@description('Set of core tags')
param coreTags object

@description('Provide a name suffix per CAF.')
param nameSuffixShort string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-${nameSuffixShort}'
  location: location
  tags: coreTags
}

resource ownerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  resourceGroup()
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('id-${nameSuffixShort}',ownerRoleDefinition.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: ownerRoleDefinition.id
    principalType:'ServicePrincipal' 
  }
}

output roleAssignmentId string = managedIdentity.id
