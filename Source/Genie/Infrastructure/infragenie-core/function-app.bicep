@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Set of core tags')
param coreTags object

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide the instance Numeber of the ASP Eg: 1')
param capacity int

@description('Provide the SKU for App Service Plan Eg: S3')
@allowed([ 'B1', 'P1V2', 'P1V3', 'P2V2', 'P2V3', 'P3V2', 'P3V3', 'S1', 'S2', 'S3' ])
param skuname string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

param uniqueStr string = uniqueString(utcNow('u'))

param workerRuntime string = 'dotnet'

param component string

param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
param subnetName string
param isPublic bool

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'windows'])
param osType string

var functionName = 'MyHttpTriggeredFunction'

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module appInsights 'application-insight.bicep' = {
  name: 'applicationInsight'
  params: {
    nameSuffixShort: nameSuffixShort
    location: location
    coreTags: coreTags
    kind: 'web'
    wokspace_sku_Name: 'PerGB2018'
  }
}

module appServicePlan 'app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    capacity: capacity
    coreTags: coreTags
    nameSuffix: nameSuffix
    skuname: skuname
    osType: osType
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: 'st${hypenlessNameSuffix}'
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'fn-${nameSuffixShort}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.outputs.azureServicePlanId
    enabled: true
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.outputs.appInsightKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.outputs.appInsightKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: workerRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        // {
        //   name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        //   value: 'DefaultEndpointProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        // }
        {
          name: 'AzureWebJobsDisableHomepage'
          value: 'true'
        }
      ]
    }
    httpsOnly: true
  }
}

// resource function 'Microsoft.Web/sites/functions@2022-03-01' = {
//   name: functionName
//   parent: functionApp
//   properties: {
//     config: {
//       disabled: false
//       bindings: [
//         {
//           name: 'req'
//           type: 'httpTrigger'
//           direction: 'in'
//           authLevel: 'anonymous'
//           methods: [
//             'get'
//           ]
//         }
//         {
//           name: '$return'
//           type: 'http'
//           direction: 'out'
//         }
//       ]
//     }
//     files: {}
//   }
// }

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointFunctionApp'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'func')
    nameSuffixShort: nameSuffixShort
    serviceToLink: functionApp.id
    groupIds: [
      'sites'
    ]
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneFunctionApp'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'func')
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.appServiceDnsZoneNameFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}


output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionName
