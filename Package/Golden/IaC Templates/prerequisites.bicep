targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

param nameSuffix string

param nameSuffixShort string

param hyphenlessNameSuffix string

@description('Should public access be allowed to the resources?')
param shouldAllowPublicAccess bool = false

@description('Address prefixes for the VNET')
param vnetAddressPrefixes array = []

@description('Should subnets be created if creating a VNET?')
param shouldCreateSubnets bool = true

@description('Address prefixes for the subnet')
param subnetAddressPrefixes array

@description('Should new DNS Zones to be created?')
param shouldCreateDnsZones bool = true

@description('The resource group name housing the DNS Zones.')
param dnsZoneResourceGroupId string = ''

param existingNetworkId string = ''
param existingSubnets array = []

@description('PrincipalId is the object id of the current logged in user "az ad signed-in-user show --query id" or the user context the deployment is running')
param principalId string

@allowed([ 'All', 'KeyVault', 'ServiceBus', 'SqlServer', 'StorageAccount', 'CognitiveServices', 'ContainerRegistry' ])
param dnsZonesToLaydown array = [ 'All' ]
param dnsZones array

@description('Set of core tags')
param coreTags object

// param whitelistedIPs array = []

param uniqueStr string = uniqueString(utcNow('u'))

@description('Current timestamp')
param now string = utcNow('u')

param storageSku object = {
  name: 'Standard_LRS'
  kind: 'BlobStorage'
  accessTier: 'Cool'
  isHnsEnabled: true
}

@description('IPs to whitelist')
param whitelistedIPs array = []

param indexOverride string = ''
// Compute current index
var rg = resourceGroup().name
var idx = lastIndexOf(rg, '-')
var nextIndex = (empty(indexOverride) && idx > 0) ? int(substring(rg, idx + 1)) : 1
#disable-next-line no-unused-vars
var index = empty(indexOverride) ? padLeft(nextIndex, 3, '0') : indexOverride

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueString(now)}'
  params: {
    env: env
  }
}

var isolated = (!shouldAllowPublicAccess && empty(existingNetworkId))
var private = ((!shouldAllowPublicAccess) && (!empty(existingNetworkId)))
// var public = (shouldAllowPublicAccess && empty(existingNetworkId))

// TODO: Should we not deploy NSG when existingNetworkId is supplied?
module nsg 'nsg.bicep' = if (isolated) {
  name: 'nsg'
  params: {
    location: location
    coreTags: union(coreTags, {
        purpose: 'Shared NSG'
        'created-on': now
      }
    )
    nameSuffix: nameSuffix
  }
}

module apim './nsg-api-management.bicep' = if (isolated) {
  name: 'apimNsg'
  params: {
    location: location
    coreTags: union(coreTags, {
        purpose: 'Shared NSG'
        'created-on': now
      }
    )
    component: globalConfig.outputs.sharedComponent
    nameSuffix: nameSuffix
  }
}

module network 'network.bicep' = if (isolated || private) {
  name: 'vnetModule'
  dependsOn: [
    nsg
  ]
  params: {
    location: location
    nameSuffixShort: nameSuffixShort
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetAddressPrefixes: subnetAddressPrefixes
    nsgId: (isolated) ? nsg.outputs.id : ''
    coreTags: coreTags
    apimNsgId: (isolated) ? apim.outputs.nsgId : ''
    env: env
    existingNetworkId: existingNetworkId
    shouldAllowPublicAccess: shouldAllowPublicAccess
    shouldCreateDnsZones: shouldCreateDnsZones
    shouldCreateSubnets: shouldCreateSubnets
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    dnsZonesToLaydown: dnsZonesToLaydown
    dnsZones: dnsZones
  }
}

module switchVnets './vnet-switcher.bicep' = if (isolated || private) {
  name: 'switchVnets-${uniqueStr}'
  dependsOn: [
    network
  ]
  params: {
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: existingSubnets[0]
  }
}

module coreVault 'core-vault.bicep' = {
  name: 'coreVault'
  dependsOn: [
    globalConfig
    network
    switchVnets
  ]
  params: {
    env: env
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    component: globalConfig.outputs.sharedComponent
    existingNetworkId: existingNetworkId
    isPublic: shouldAllowPublicAccess
    subnetName: existingSubnets[0]
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    coreTags: union(coreTags, {
        purpose: 'KeyVault to contain all deployment secrets'
        'created-on': now
      })
    principalId: principalId
  }

}

module storageAccount './storage-account.bicep' = {
  name: 'storageAccount'
  dependsOn: [
    coreVault
  ]
  params: {
    env: env
    location: location
    coreTags: coreTags
    component: globalConfig.outputs.sharedComponent
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    hypenlessNameSuffix: hyphenlessNameSuffix
    existingNetworkId: existingNetworkId
    subnetName: existingSubnets[0]
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    defaultAction: 'Deny'
    isPublic: shouldAllowPublicAccess
    runPrereq: false
    skuName: storageSku.name
    kind: storageSku.kind
    accessTier: storageSku.accessTier
    isHnsEnabled: storageSku.isHnsEnabled
    whitelistedIPs: whitelistedIPs
  }
}

output networkId string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.networkId
output networkName string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.networkName
output subnetId string = (shouldAllowPublicAccess)? '' : switchVnets.outputs.subnetId

output coreVaultId string = coreVault.outputs.coreVaultId
output coreVaultName string = coreVault.outputs.coreVaultName

output storageAccountId string = storageAccount.outputs.id
output storageAccountName string = storageAccount.outputs.name
