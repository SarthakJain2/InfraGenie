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

param linuxFxVersion string = ''

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

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'app' ])
param appServicePlanKind string = 'linux'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

@description('Override the index in the Resource Group')
param indexOverride string = ''

// @description('If the value is set to TRUE it means the deployment will be isolated If the value is set to FALSE then the deployment will be private')
// param isolated bool 

@description('Should run prerequisites?')
#disable-next-line no-unused-params
param runPrerequisites bool = false

@description('Should run prerequisites?')
#disable-next-line no-unused-params
param runPostrequisites bool = true

@description('SKU for the Azure Container Registry')
param acrSku object = {
  name: 'Premium'
  zoneRedundancy: 'Disabled'
}

// Compute current index
var rg = resourceGroup().name
var idx = lastIndexOf(rg, '-')
var nextIndex = (empty(indexOverride) && idx > 0) ? int(substring(rg, idx + 1)) : 1
var index = (indexOverride == '') ? padLeft(nextIndex, 3, '0') : indexOverride

var nameSuffix = format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index)
var nameSuffixShort = format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
var hypenlessNameSuffix = toLower(format(globalConfig.outputs.hyphenlessNameShortFormat, projectName, env, index))
var hypenlessNameShortSuffix = toLower(format(globalConfig.outputs.hyphenlessNameShortFormat, projectName, env, index))

var isolated = (!shouldAllowPublicAccess && empty(existingNetworkId))
var private = ((!shouldAllowPublicAccess) && (!empty(existingNetworkId)))

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module prerequisites 'prerequisites.bicep' = {
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

module switchVnets './vnet-switcher.bicep' = if (isolated || private) {
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

module appInsights 'application-insight.bicep' = {
  name: 'applicationInsight'
  dependsOn: [
    prerequisites
  ]
  params: {
    nameSuffixShort: nameSuffixShort
    location: location
    coreTags: coreTags
    kind: 'web'
    wokspace_sku_Name: 'PerGB2018'
  }
}

module containerRegistry 'container-registry.bicep' = {
  name: 'containerRegistry'
  dependsOn: [
    prerequisites
  ]
  params: {
    env: env
    hyphenlessNameSuffix: hypenlessNameShortSuffix
    location: location
    coreTags: coreTags
    publicNetworkAccess: shouldAllowPublicAccess ? 'Enabled' : 'Disabled'
    skuName: acrSku.name
    subnetName: existingSubnets[0]
    zoneRedundancy: acrSku.zoneRedundancy
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.containerRegistryComponent, env, index)
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    isPublic: shouldAllowPublicAccess

  }
}

module appService 'app-service.bicep' = {
  dependsOn: [
    appInsights
    containerRegistry
  ]
  name: 'azureAppService'
  params: {
    appiConnectionString: appInsights.outputs.appInsightConnectionString
    appiInstrumentationKey: appInsights.outputs.appInsightKey
    appServicePlanKind: appServicePlanKind
    capacity: 2
    coreTags: coreTags
    existingNetworkId: existingNetworkId
    isPublic: shouldAllowPublicAccess
    linuxFxVersion: linuxFxVersion
    location: location
    nameSuffixShort: nameSuffixShort
    skuname: 'P2V3'
    subnetName: existingSubnets[9]
    hyphenlessNameSuffix: hypenlessNameShortSuffix
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.appServiceCliComponent, env, index)
   registry: false
  }
}

module webApp 'app-service-web.bicep' = [for component in [ 'web', 'api' ]: {
  dependsOn: [
    appInsights
  ]
  name: 'azureAppService-${component}'
  params: {
    location: location
    coreTags: coreTags
    nameSuffixShort: format(globalConfig.outputs.nameSuffixFormat, projectName, component, env, index)
    capacity: 2
    skuname: 'P2V3'
    isPublic: shouldAllowPublicAccess
    linuxFxVersion: linuxFxVersion
    appServicePlanKind: appServicePlanKind
  }
}]

module openAI 'openai.bicep' = {
  name: 'openAI'
  dependsOn: [
    prerequisites
  ]
  params: {
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, 'core', env, index)
    coreTags: coreTags
    location: location
  }
}

module frontDoor 'front-door.bicep' = {
  name: 'frontDoor'
  dependsOn: [
    prerequisites
    appInsights
  ]
  params: {
    location: 'global'
    coreTags: coreTags
    nameSuffixshort: nameSuffixShort
    hypenlessNameSuffix: hypenlessNameSuffix
    skuName: 'Standard_AzureFrontDoor'
    appServicePlanKind: appServicePlanKind
  }
}

