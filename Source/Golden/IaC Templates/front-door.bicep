
@description('Specifies the location for resources.')
@allowed(['global'])
param location string = 'global'

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixshort string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Set of core tags')
param coreTags object

@description('Provide the SKU for front door profile Eg. Standard_AzureFrontDoor')
param skuName string = 'Standard_AzureFrontDoor'

// param hostName string = 'rhipheus.azurewebsites.net'

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'windows'])
param osType string

module functionApp 'function-app.bicep' = {
  name: 'functionApp'
  params: {
    location: 'eastus'
    coreTags: coreTags
    frontDoorId: frontDoor.properties.frontDoorId
    nameSuffixshort: nameSuffixshort
    nameSuffix: nameSuffix
    hypenlessNameSuffix: hypenlessNameSuffix
    capacity: 2
    skuname: 'P2V3'
    osType: osType
  }
}

resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: 'afd-${nameSuffixshort}'
  location: location
  tags: coreTags
  sku: {
    name: skuName
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' = {
  name: 'afde-${nameSuffixshort}'
  location: location
  parent: frontDoor
  properties: {
     enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' = {
  name: 'afdog-${nameSuffixshort}'
  parent: frontDoor
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 50
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  name: 'afdo-${nameSuffixshort}'
  parent: frontDoorOriginGroup
  properties: {
    hostName: functionApp.outputs.functionAppHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: functionApp.outputs.functionAppHostName
    priority: 1
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2022-11-01-preview' = {
  name: 'afdr-${nameSuffixshort}'
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin
  ]
  properties: {
    originGroup: {
       id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointFunction string = 'https://${frontDoorEndpoint.properties.hostName}/api/${functionApp.outputs.functionName}'
output functionAppUri string = 'https://${functionApp.outputs.functionAppHostName}/api/${functionApp.outputs.functionName}'
