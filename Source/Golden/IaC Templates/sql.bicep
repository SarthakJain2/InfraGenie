@description('Specifies the environment this template deploys to')
#disable-next-line no-unused-params
param env string

@description('Specifies the location for resources.')
param location string

@description('Short form of the component this resource is used for')
param component string

@description('Provide a name suffix per CAF.  Ignore the sql- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the sql- prefix')
param nameSuffixShort string

@description('Overriding SQL Database Name')
param nameOverride string = ''

@description('Does the resource require a Public IP?')
param isPublic bool = false

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

@description('SQL Sku name, tier, family & capacity')
param sqlSku object

@description('Set of core tags')
param coreTags object

@description('for creating a unique string')
param uniqueStr string = uniqueString(newGuid())

var sqlserverName = 'sqlserver-${nameSuffixShort}'
var sqlDbName = (nameOverride == '') ? 'sql-${nameSuffix}' : nameOverride

param subnetName string = 'primary'
param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlserverName
  location: location
  tags: coreTags
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    publicNetworkAccess: (isPublic) ? 'Enabled' : 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  tags: coreTags
  sku: sqlSku
}

resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-02-01-preview' = {
  name: 'current'
  parent: sqlServerDatabase
  properties: {
    state: 'Enabled'
  }
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointSql'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    serviceToLink: sqlServer.id
    groupIds: [
      'sqlServer'
    ]
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneSql'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.sqlServerDnsZoneNameFormat //format(globalConfig.outputs.sqlServerDnsZoneNameFormat, component)
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
    existingNetworkId: existingNetworkId
  }
}

var shared = replace(nameSuffix, component, 'shrd') //globalConfig.outputs.sharedComponent
var kvName = 'kv-${shared}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
}

resource secretUser 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: '${component}${adminUsername}'
  properties: {
    value: adminUsername
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: '${component}Password'
  properties: {
    value: adminPassword
  }
}

output sqlVaultUsernametKey string = '${component}${adminUsername}'

#disable-next-line outputs-should-not-contain-secrets
output sqlVaultPasswordKey string = '${component}Password'

output keyVaultId string = keyVault.id
