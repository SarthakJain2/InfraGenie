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
@allowed([ 'linux', 'windows'])
param osType string

@allowed(['code','container', 'sws'])
param appServicePlanKind string

@description('Provide the tech stack for App Service Plan Eg: DOTNETCORE|3.1')
@allowed(['DOTNETCORE|7.0', 'DOTNETCORE|6.0', 'JAVA|17-java17', 'TOMCAT|10.0-java17', 'TOMCAT|9.0-java17', 'TOMCAT|8.5-java17', 'JAVA|11-java11', 'JBOSSEAP|7-java11', 'TOMCAT|10.0-java11', 'TOMCAT|9.0-java11', 'TOMCAT|8.5-java11', 'JAVA|8-java8', 'JBOSSEAP|7-java8', 'TOMCAT|10.0-java8', 'TOMCAT|9.0-java8', 'TOMCAT|8.5-java8', 'NODE|18-lts','NODE|16-lts', 'NODE|14-lts', 'PHP|8.2', 'PHP|8.1', 'PHP|8.0', 'PYTHON|3.11', 'PYTHON|3.10', 'PYTHON|3.9', 'PYTHON|3.8', 'PYTHON|3.7', 'RUBY|2.7'])
param techStack string 
param appSettings object
@allowed(['AllAllowed', 'Disabled', 'FtpsOnly'])
param ftpsState string = 'FtpsOnly'

@description('Provide the SKU for App Service Plan Eg: S3')
@allowed([ 'B1', 'P1V2', 'P1V3', 'P2V2', 'P2V3', 'P3V2', 'P3V3', 'S1', 'S2', 'S3' ])
param skuname string

@description('app insights Instrumentation Key')
param appiInstrumentationKey string

@description('app insights Instrumentation Key')
param appiConnectionString string
param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
param subnetName string 
param isPublic bool

@description('Give the health check path.')
param healthCheckPath string = '/path'

param appServiceStorage string = 'false'

param httpsOnly bool = true

param alwaysOn bool = true

@description('Set of core tags')
param coreTags object
param uniqueStr string = uniqueString(utcNow('u'))

@description('Configure the AppService with Azure Container Registry if yes give true and if no give false')
param registry bool

param component string

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    existingNetworkId: existingNetworkId
    subnetName: subnetName
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module appServicePlan 'app-service-plan.bicep' = {
  name: 'azureAppService-${component}'
  params: {
    location: location
    nameSuffixshort: nameSuffixShort
    capacity: capacity
    skuname: skuname
    coreTags: coreTags
    osType: osType
    
  }
}

var acrexisting = appServicePlanKind=='container' ? osType=='linux' ?  [
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
] : osType=='linux' ? [
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

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing =  if (appServicePlanKind == 'container' ) {
  name: 'cr${hyphenlessNameSuffix}'
}

var siteConfig = osType == 'linux' ? {
      alwaysOn: alwaysOn
      linuxFxVersion: techStack
      healthCheckPath: healthCheckPath
      ftpsState: ftpsState
      appSettings: appSettings == null ? acrexisting : appSettings
    }: {
      alwaysOn: alwaysOn
      healthCheckPath: healthCheckPath
      appSettings: appSettings == null ? acrexisting : appSettings
      metadata: [
        {
            name: 'CURRENT_STACK'
            value: ''
        }
    ]
    }

resource webapp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'ase-${nameSuffix}'
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

