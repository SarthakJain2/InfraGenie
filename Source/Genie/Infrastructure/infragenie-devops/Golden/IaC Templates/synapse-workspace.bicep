@description('Specifies the environment this template deploys to')
param env string

@description('Specify location')
param location string

@description('Component this resource belongs to (e.g. "wfe" or "api" or "sql"')
param component string

@description('Provide a SQL administrator username')
param sqlAdministratorLogin string

@description('Provide a SQL administrator Password')
@secure()
param sqlAdministratorPassword string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the resource type prefix')
param nameSuffixShort string

@description('Set of core tags')
param coreTags object

param existingNetworkId string = ''
param subnetName string = ''

param dnsZoneResourceGroupId string = ''

@description('Give the default data lake storage file system name')
param defaultDataLakeStorageFilesystemName string = 'synadls'

@description('provide a User Object ID/Principal ID')
param principalId string

param whitelistedIPs array = []

param nodeSize string
param sparkPoolMinNodeCount int
param sparkPoolMaxNodeCount int

@description('Set to true if you want to make the workspace public')
param isPublic bool

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

// @description('Give the SQL pool name')
// param sqlPoolName string

var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: 'st${hypenlessNameSuffix}'
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blob
  name: defaultDataLakeStorageFilesystemName
  properties: {
    publicAccess: 'None'
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: 'syn-${nameSuffixShort}'
  location: location
  tags: coreTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorPassword
    defaultDataLakeStorage: {
      accountUrl: format(globalConfig.outputs.dataLakeDnsZoneNameFormat, storageAccount.name)
      filesystem: defaultDataLakeStorageFilesystemName
      createManagedPrivateEndpoint: false
    }
    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: false
    }
    cspWorkspaceAdminProperties: {
      initialWorkspaceAdminObjectId: principalId
    }
    publicNetworkAccess: (isPublic) ? 'Enabled' : 'Disabled'
    trustedServiceBypassEnabled: true
  }
}

resource serviceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceId('Microsoft.Storage/storageAccounts', 'syn-${nameSuffixShort}'), storageAccount.name)
  scope: storageAccount
  properties: {
    principalId: synapse.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
    principalType: 'ServicePrincipal'
  }
}

resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceId('Microsoft.Storage/storageAccounts', 'syn-${nameSuffixShort}'), principalId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
    principalType: 'User'
  }
}

resource sqlPool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: 'syndp${hypenlessNameSuffix}'
  location: location
  parent: synapse
  sku: {
    name: 'DW100c'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
  }
}

resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: 'synsp001'
  location: location
  parent: synapse
  properties: {
    nodeSize: nodeSize
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: sparkPoolMinNodeCount
      maxNodeCount: sparkPoolMaxNodeCount
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.2'
  }
}

resource azurefirewalls 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (isPublic) {
  name: 'AllowAllWindowsAzureIps'
  parent: synapse
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// var startIpAddress = !empty(whitelistedIPs) ? whitelistedIPs[0] : ''
// var endIpAddress = !empty(whitelistedIPs) && length(whitelistedIPs) == 2 ? whitelistedIPs[1] : startIpAddress

resource firewalls 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = [for (ip, index) in whitelistedIPs: if (isPublic) {
  name: 'AllowAccessPoint-${index}'
  parent: synapse
  properties: {
    startIpAddress: ip
    endIpAddress: ip
  }
}]

module synapsePrivateLink 'private-LinkHub-Synapse.bicep' = if (!isPublic) {
  name: 'synapsePrivateLinkHub'
  params: {
    location:location
    hypenlessNameSuffix: hypenlessNameSuffix
    coreTags: coreTags
  }
}

module privateEndPointSynSQL 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointSynSQL'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'synsql')
    nameSuffixShort: nameSuffixShort
    serviceToLink: synapse.id
    groupIds: [
      'sql'
    ]
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

module privateDnsZoneSynSQL 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneSynSQL'
  dependsOn: [
    privateEndPointSynSQL
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'synsql')
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.synapseSqlDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}
module privateEndPointSynDev 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointSynDev'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'syndev')
    nameSuffixShort: nameSuffixShort
    serviceToLink: synapse.id
    groupIds: [
      'dev'
    ]
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

module privateDnsZoneSynDev 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneSynDev'
  dependsOn: [
    privateEndPointSynDev
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'syndev')
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.synapseDevDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

module privateEndPointSynWeb 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointSynWeb'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'synweb')
    nameSuffixShort: nameSuffixShort
    serviceToLink: synapsePrivateLink.outputs.synapseprivatelinkId
    groupIds: [
      'web'
    ]
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

module privateDnsZoneSynWeb 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneSynWeb'
  dependsOn: [
    privateEndPointSynWeb
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'synweb')
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.synapseWebDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

output synapseWorkspaceName string = synapse.name
output whitelistedIPs array = whitelistedIPs
