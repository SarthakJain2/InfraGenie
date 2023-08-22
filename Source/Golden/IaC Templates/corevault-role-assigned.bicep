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

resource keyVaultSecretsUserRoleDefinitionId 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  resourceGroup()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('id-${nameSuffixShort}',keyVaultSecretsUserRoleDefinitionId.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId.id
    principalType:'ServicePrincipal' 
  }
}

output roleAssignmentId string = managedIdentity.id
