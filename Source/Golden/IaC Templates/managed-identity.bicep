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

output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityName string = managedIdentity.name
