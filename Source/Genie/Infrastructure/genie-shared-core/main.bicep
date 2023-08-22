targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

@description('Current Project Name')
param projectName string

@description('Should public access be allowed to the resources?')
param shouldAllowPublicAccess bool = false

@description('IPs to whitelist')
#disable-next-line no-unused-params
param whitelistedIPs array = []

@description('Address prefixes for the VNET')
param vnetAddressPrefixes array

@description('Should subnets be created if creating a VNET?')
param shouldCreateSubnets bool = true

@description('Address prefixes for the subnet')
param subnetAddressPrefixes array

@description('Should new DNS Zones to be created?')
param shouldCreateDnsZones bool = true

@allowed(['All', 'KeyVault','ServiceBus', 'SqlServer','StorageAccount','CognitiveServices','ContainerRegistry'])
param dnsZonesToLaydown array = ['All']

@description('The resource group name housing the DNS Zones.')
param dnsZoneResourceGroupId string = ''

@description('Provide the resourceId of an existing network id.  Leave blank to create a new network.')
param existingNetworkId string = ''

@description('Provide the existing subnet names of an existing network.  Skip the argument to default subnets of the new network.')
param existingSubnets array

param dnsZones array = []

@description('Set of core tags')
param coreTags object

@description('PrincipalId is the object id of the current logged in user \'az ad signed-in-user show --query id\' or the user context the deployment is running')
param principalId string

@description('SKU for the Storage Account')
param storageSku object = {
  name: 'Standard_LRS'
  kind: 'BlobStorage'
  accessTier: 'Cool'
  isHnsEnabled: false
}

@description('Current timestamp')
param now string = utcNow('u')

@description('Image Reference Id of an Azure Compute Image')
#disable-next-line no-unused-params
param imageReferenceId string

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

@description('Override the index in the Resource Group')
param indexOverride string = ''

@description('Should run prerequisites?')
#disable-next-line no-unused-params
param runPrerequisites bool = false

@description('Should run prerequisites?')
#disable-next-line no-unused-params
param runPostrequisites bool = true

// Compute current index
var rg = resourceGroup().name
var idx = lastIndexOf(rg, '-')
var nextIndex = (empty(indexOverride) && idx > 0) ? int(substring(rg, idx + 1)) : 1
var index = (indexOverride == '') ? padLeft(nextIndex, 3, '0') : indexOverride

var nameSuffix = format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index)
var nameSuffixShort = format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
var hypenlessNameSuffix = toLower(format(globalConfig.outputs.hyphenlessNameShortFormat, projectName, env, index))

var isolated = (!shouldAllowPublicAccess && empty(existingNetworkId))
var private = ((!shouldAllowPublicAccess) && (!empty(existingNetworkId)))

module globalConfig 'Golden/IaC Templates/global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module prerequisites 'Golden/IaC Templates/prerequisites.bicep' = {
  name: 'prerequisites'
  dependsOn: [
    globalConfig
  ]
  params: {
    env: env
    location: location
    coreTags: union(coreTags, {
        'created-on': now
        'last-updated': now
      })
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    dnsZonesToLaydown: dnsZonesToLaydown
    dnsZones: dnsZones
    existingNetworkId: existingNetworkId
    existingSubnets: existingSubnets
    hyphenlessNameSuffix: hypenlessNameSuffix
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    principalId: principalId
    subnetAddressPrefixes: subnetAddressPrefixes
    storageSku: storageSku
    shouldAllowPublicAccess: shouldAllowPublicAccess
    shouldCreateDnsZones: shouldCreateDnsZones
    shouldCreateSubnets: shouldCreateSubnets
    vnetAddressPrefixes: vnetAddressPrefixes
  }
}

module switchVnets 'Golden/IaC Templates/vnet-switcher.bicep' = if (isolated || private) {
  name: 'switchVnets-${uniqueStr}'
  dependsOn: [
    prerequisites
  ]
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetAddressPrefixes[0].name
    existingNetworkId: existingNetworkId
  }
}

module sendGrid 'Golden/IaC Templates/sendgrid.bicep' = {
  name: 'sendGrid'
  dependsOn: [
    prerequisites
    switchVnets
  ]
  params: {
    coreTags: coreTags
    location: 'global'
    nameSuffix: nameSuffixShort
    offerId: 'tsg-saas-offer'
    planId: 'free-100-2022'
    publisherId: 'sendgrid'
  }
}
