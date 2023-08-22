// TODO: Where's env used?
@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Short form of the component this resource is used for')
param component string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

// TODO: Examine if this is required as we no longer create namesuffix out of constituent parts in the modules
@description('Overriding VM Name')
param nameOverride string = ''

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

@description('Set of core tags')
param coreTags object

param subnetName string
param existingNetworkId string = ''

module database 'sql.bicep' = {
  name: 'sqlDatabase'
  params: {
    env: env
    location: location
    component: component
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    nameOverride: nameOverride
    adminUsername: adminUsername
    adminPassword: adminPassword
    sqlSku: {
      name: 'GP_S_Gen5_2'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: 2
    }
    coreTags: coreTags
    subnetName: subnetName
    existingNetworkId: existingNetworkId
  }
}

output databaseUsernameKey string = database.outputs.sqlVaultUsernametKey
#disable-next-line outputs-should-not-contain-secrets
output databasePasswordKey string = database.outputs.sqlVaultPasswordKey
output databaseKeyVaultId string = database.outputs.keyVaultId
