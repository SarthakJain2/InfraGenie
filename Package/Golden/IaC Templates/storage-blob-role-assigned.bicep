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

resource storageBlobRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('id-${nameSuffixShort}',storageBlobRoleDefinition.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: storageBlobRoleDefinition.id
    principalType:'ServicePrincipal' 
  }
}

output roleAssignmentId string = managedIdentity.id
