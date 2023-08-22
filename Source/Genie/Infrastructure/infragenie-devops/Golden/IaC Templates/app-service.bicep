@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Specifies the name of the service with component name')
param nameSuffix string

@description('Enter name for Container registry')
param hyphenlessNameSuffix string

@description('Provide the instance Numeber of the ASP Eg: 1')
param capacity int

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'windows' ])
param osType string

@allowed([ 'code', 'container', 'sws' ])
param appServicePlanKind string

@description('Provide the tech stack for App Service Plan Eg: DOTNETCORE|3.1')
@allowed([ 'DOTNETCORE|7.0', 'DOTNETCORE|6.0', 'JAVA|17-java17', 'TOMCAT|10.0-java17', 'TOMCAT|9.0-java17', 'TOMCAT|8.5-java17', 'JAVA|11-java11', 'JBOSSEAP|7-java11', 'TOMCAT|10.0-java11', 'TOMCAT|9.0-java11', 'TOMCAT|8.5-java11', 'JAVA|8-java8', 'JBOSSEAP|7-java8', 'TOMCAT|10.0-java8', 'TOMCAT|9.0-java8', 'TOMCAT|8.5-java8', 'NODE|18-lts', 'NODE|16-lts', 'NODE|14-lts', 'PHP|8.2', 'PHP|8.1', 'PHP|8.0', 'PYTHON|3.11', 'PYTHON|3.10', 'PYTHON|3.9', 'PYTHON|3.8', 'PYTHON|3.7', 'RUBY|2.7' ])
param techStack string
param appSettings array = []
@allowed([ 'AllAllowed', 'Disabled', 'FtpsOnly' ])
param ftpsState string = 'FtpsOnly'

@description('Provide the SKU for App Service Plan Eg: S3')
@allowed([ 'B1', 'B2', 'B3', 'P1V2', 'P1V3', 'P2V2', 'P2V3', 'P3V2', 'P3V3', 'S1', 'S2', 'S3' ])
param skuname string

@description('app insights Instrumentation Key')
param appiInstrumentationKey string

@description('app insights Instrumentation Key')
param appiConnectionString string
param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
param subnetName string
param peSubnetName string
param isPublic bool

@description('Give the health check path.')
param healthCheckPath string = '/path'

param appServiceStorage string = 'false'

param httpsOnly bool = true

param alwaysOn bool = true

@description('Set of core tags')
param coreTags object
param uniqueStr string = uniqueString(utcNow('u'))

param component string

param storageAccountName string = ''
param attachStorageAccount bool = false

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    subnetName: subnetName
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module appServicePlan 'app-service-plan.bicep' = {
  name: 'azureAppServicePlan-${component}'
  params: {
    location: location
    nameSuffix: nameSuffix
    capacity: capacity
    skuname: skuname
    coreTags: coreTags
    osType: osType

  }
}

var acrexisting = appServicePlanKind == 'container' ? osType == 'linux' ? [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appiInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'Recommended'
  }
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: appServiceStorage
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
    value: listCredentials(resourceId('Microsoft.ContainerRegistry/registries', acr.name), '2022-02-01-preview').passwords[0].value
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: acr.properties.loginServer
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
    value: acr.name
  }

] : [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appiInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'Recommended'
  }
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: appServiceStorage
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
    value: listCredentials(resourceId('Microsoft.ContainerRegistry/registries', acr.name), '2022-02-01-preview').passwords[0].value
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: acr.properties.loginServer
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
    value: acr.name
  }
  {
    name: 'WEBSITE_NODE_DEFAULT_VERSION'
    value: 'nodeVersion'
  }
] : osType == 'linux' ? [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appiInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'Recommended'
  }
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: appServiceStorage
  }
] : [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appiInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'Recommended'
  }
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: appServiceStorage
  }
  {
    name: 'WEBSITE_NODE_DEFAULT_VERSION'
    value: 'nodeVersion'
  }
]

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = if (appServicePlanKind == 'container') {
  name: 'cr${hyphenlessNameSuffix}'
}

var siteConfig = osType == 'linux' ? {
  alwaysOn: alwaysOn
  linuxFxVersion: (appServicePlanKind == 'code') ? techStack : 'DOCKER|nginx'
  healthCheckPath: healthCheckPath
  ftpsState: ftpsState
  appSettings: empty(appSettings) ? acrexisting : appSettings
} : {
  alwaysOn: alwaysOn
  healthCheckPath: healthCheckPath
  appSettings: empty(appSettings) ? acrexisting : appSettings
  metadata: [
    {
      name: 'CURRENT_STACK'
      value: ''
    }
  ]
}

resource webapp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    httpsOnly: httpsOnly
    siteConfig: siteConfig
    virtualNetworkSubnetId: switchVnets.outputs.subnetId
    serverFarmId: appServicePlan.outputs.azureServicePlanId
    publicNetworkAccess: isPublic ? 'Enabled' : 'Disabled'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = if(attachStorageAccount) {
  name: storageAccountName
}

resource storageBlob 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01'  existing = if (attachStorageAccount){
  name: 'default'
  parent: storageAccount
}
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = if (attachStorageAccount){
  name: webapp.name
  parent: storageBlob
}
resource storageSetting 'Microsoft.Web/sites/config@2021-01-15' = if(attachStorageAccount) {
  name: 'azurestorageaccounts'
  parent: webapp
  properties: {
    '${storageContainer.name}': {
      type: 'AzureBlob'
      shareName: storageContainer.name
      mountPath: '/files'
      accountName: storageAccount.name      
      accessKey:  storageAccount.listKeys().keys[0].value                 
    }
  }
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointApp-${component}'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    serviceToLink: webapp.id
    groupIds: [
      'sites'
    ]
    subnetName: peSubnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneApp-${component}'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.appServiceDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    subnetName: peSubnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

output stack string = appServicePlanKind
