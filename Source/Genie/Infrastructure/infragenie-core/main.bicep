targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

@description('Current Project Name')
param projectName string

@description('Set of core tags')
param coreTags object

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

@allowed([['All'], ['KeyVault'],['ServiceBus'], ['SqlServer'],['StorageAccount'],['CognitiveServices'],['ContainerRegistry']])
param dnsZonesToLaydown array = ['All']

@description('The resource group name housing the DNS Zones.')
param dnsZoneResourceGroupId string = ''

@description('Provide the resourceId of an existing network id.  Leave blank to create a new network.')
param existingNetworkId string = ''

@description('Provide the existing subnet names of an existing network.  Skip the argument to default subnets of the new network.')
param existingSubnets array

param dnsZones array = []

@description('Provide the tech stack for App Service Plan Eg: DOTNETCORE|3.1')
@allowed(['DOTNETCORE|7.0', 'DOTNETCORE|6.0', 'JAVA|17-java17', 'TOMCAT|10.0-java17', 'TOMCAT|9.0-java17', 'TOMCAT|8.5-java17', 'JAVA|11-java11', 'JBOSSEAP|7-java11', 'TOMCAT|10.0-java11', 'TOMCAT|9.0-java11', 'TOMCAT|8.5-java11', 'JAVA|8-java8', 'JBOSSEAP|7-java8', 'TOMCAT|10.0-java8', 'TOMCAT|9.0-java8', 'TOMCAT|8.5-java8', 'NODE|18-lts','NODE|16-lts', 'NODE|14-lts', 'PHP|8.2', 'PHP|8.1', 'PHP|8.0', 'PYTHON|3.11', 'PYTHON|3.10', 'PYTHON|3.9', 'PYTHON|3.8', 'PYTHON|3.7', 'RUBY|2.7'])
param techStack string = 'DOTNETCORE|7.0'

@description('PrincipalId is the object id of the current logged in user \'az ad signed-in-user show --query id\' or the user context the deployment is running')
param principalId string

@description('Overriding VM Name')
param nameOverride string = ''

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

@description('Required VM Size. Defaults to Standard D4s_v3')
param vmSize string = 'Standard_D2s_v3'

@description('Should a jumpbox be deployed?')
param deployJumpbox bool = true

@description('Image Reference Id of an Azure Compute Image')
#disable-next-line no-unused-params
param imageReferenceId string

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed(['code','container', 'sws'])
param appServicePlanKind string = 'container'

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'windows'])
param osType string = 'linux'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

@description('Override the index in the Resource Group')
param indexOverride string = ''

param isPublic bool = true

// @description('If the value is set to TRUE it means the deployment will be isolated If the value is set to FALSE then the deployment will be private')
// param isolated bool 

@description('Should run prerequisites?')
param runPrerequisites bool = false

@description('Should run prerequisites?')
#disable-next-line no-unused-params
param runPostrequisites bool = true

@description('Current timestamp')
param now string = utcNow('u')

@description('SKU for the Storage Account')
param storageSku object = {
  name: 'Standard_LRS'
  kind: 'StorageV2'
  accessTier: 'Cool'
  isHnsEnabled: false
}

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

var nameSuffixShort = format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
var hypenlessNameSuffix = toLower(format(globalConfig.outputs.hyphenlessNameShortFormat, projectName, env, index))
var hypenlessNameShortSuffix = toLower(format(globalConfig.outputs.hyphenlessNameShortFormat, projectName, env, index))

var isolated = (!shouldAllowPublicAccess && empty(existingNetworkId))
var private = ((!shouldAllowPublicAccess) && (!empty(existingNetworkId)))

// var storageBaseLocation = 'https://${prerequisites.outputs.storageAccountName}.${globalConfig.outputs.storageAccountBolbDnsZoneFormat}'

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
    isPublic: isPublic
    nameSuffix: toLower(format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index))
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
    subnetName: existingSubnets[0]
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
    skuName: acrSku.name
    subnetName: existingSubnets[0]
    zoneRedundancy: acrSku.zoneRedundancy
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.containerRegistryComponent, env, index)
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    isPublic: isPublic
  }
}

var components = [
  {
    name: 'api'
    subnetIndex: 6
    peSubnetIndex: 0
  }
  {
    name: 'cli'
    subnetIndex: 5
    peSubnetIndex: 0
  }
  {
    name: 'web'
    subnetIndex: 4
    peSubnetIndex: 0
  }
]
@batchSize(1)
module appService 'app-service.bicep' = [for component in components:  {
  dependsOn: [
    switchVnets
    appInsights
    containerRegistry
  ]
  name: 'azureAppService-${component.name}'
  params: {
    appServicePlanKind: appServicePlanKind
    appiConnectionString: appInsights.outputs.appInsightConnectionString
    appiInstrumentationKey: appInsights.outputs.appInsightKey
    capacity: 2
    component: component.name
    coreTags: coreTags
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    env: env
    existingNetworkId: existingNetworkId
    hyphenlessNameSuffix: hypenlessNameSuffix
    isPublic: isPublic
    location: location
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, component.name, env, index)
    nameSuffixShort: format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
    osType: osType
    skuname: 'B1'
    subnetName: existingSubnets[component.subnetIndex]
    peSubnetName: existingSubnets[component.peSubnetIndex]
    storageAccountName: prerequisites.outputs.storageAccountName
    techStack: techStack
     
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
    component: 'core'
    env: env
    nameSuffixShort: nameSuffixShort
    isPublic: isPublic
    subnetName: existingSubnets[2]
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module functionApp 'function-app.bicep' = {
  name: 'functionApp'
  dependsOn: [
    prerequisites
    appInsights
  ]
  params: {
    location: 'eastus'
    coreTags: coreTags
    component: 'core'
    nameSuffixShort: nameSuffixShort
    nameSuffix: format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
    hypenlessNameSuffix: hypenlessNameSuffix
    capacity: 2
    skuname: 'B1'
    osType: osType
    env: env
    isPublic: isPublic
    subnetName: existingSubnets[3]
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId

  }
}

module sendGrid 'sendgrid.bicep' = {
  name: 'sendGrid'
  dependsOn: [
    appService
  ]
  params: {
    coreTags: coreTags
    location: 'Global'
    nameSuffix: format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)
    autoRenew: true
    azureSubscriptionId: subscription().subscriptionId
    offerId: 'tsg-saas-offer'
    planId: 'free-100-2022'
    publisherId: 'sendgrid'
    publisherTestEnvironment: ''
    quantity: 1
    termId: 'gmz7xq9ge3py'
  }
}

module roleAssigned 'user-role-assigned.bicep' = {
  name: 'roleAssigned'
  dependsOn: [
    prerequisites
  ]
  params: {
    location: location
    coreTags: coreTags
    nameSuffixShort: nameSuffixShort
  }
}

module devBox 'vm.windows.ir.bicep' = if (deployJumpbox || (deployJumpbox != false && empty(existingNetworkId))) {
  name: 'devBox'
  dependsOn: [
    appService
  ]
  params: {
    env: env
    location: location
    component: globalConfig.outputs.sharedComponent
    nameSuffix: format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index)
    nameSuffixShort: nameSuffixShort
    nameOverride: nameOverride
    imageReferenceId: imageReferenceId
    vmSize: vmSize
    computerName: '${projectName}-devbox'
    adminUsername: adminUsername
    adminPassword: adminPassword
    // installVMExtensions: true
    // fileUris: [
    //   '${storageBaseLocation}/installers/erwin Mart Server 12.1 (64-bit)_3602.exe'
    //   '${storageBaseLocation}/installers/install-mart-server.cmd'
    // ]
    // commandToExecute: 'cmd /c install-mart-server.cmd'
    coreTags: coreTags
    existingNetworkId: existingNetworkId
    subnetName: existingSubnets[0]
  }
}

output networkId string = switchVnets.outputs.networkId
output networkName string = switchVnets.outputs.networkName

output coreVaultId string = (runPrerequisites) ? prerequisites.outputs.coreVaultId : ''
output coreVaultName string = (runPrerequisites) ? prerequisites.outputs.coreVaultName : ''
