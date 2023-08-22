targetScope = 'resourceGroup'

param env string

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Component this resource belongs to (e.g. "wfe" or "api" or "sql"')
param component string

@description('Specifies the name of the service with component name')
param nameSuffix string

// param subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-${nameSuffix}', 'primary')

@description('Provide a short name suffix per CAF.  Ignore the resource type prefix')
param nameSuffixShort string

param existingNetworkId string = ''
param subnetName string = ''

param dnsZoneResourceGroupId string = ''

@description('Should public access be allowed to the resources?')
param shouldAllowPublicAccess bool

@description('Set of core tags')
param coreTags object

@description('Specifies the SKU of Cognitive Service to create. Default creates S0.')
@allowed([
  'F0', 'S1', 'S2', 'S3'
])
param sku string = 'F0'

@allowed([
  'CognitiveServices'
  'Face'
  'Speech'
  'SpeechTranslation'
  'TextAnalytics'
  'TextTranslation'
  'AnomalyDetector'
  'CustomSpeech'
  'ComputerVision'
  'ContentModerator'
  'FormRecognizer'
  'InkRecognizer'
  'LUIS'
  'QnAMaker'
  'Recommendations'
  'SpeakerRecognition'
  'SpeechDevices'
  'SpeechServices'
  'VideoIndexer'
  'WebLM'
])
@description('Specifies the Kind of Cognitive Service to create. Default creates all kinds.')
param kind string = 'ComputerVision'

param whitelistedIPs array = []

param isPublic bool = shouldAllowPublicAccess
param uniqueStr string = uniqueString(newGuid())

var isolated = (!shouldAllowPublicAccess && empty(existingNetworkId))
var private = ((!shouldAllowPublicAccess) && (!empty(existingNetworkId)))

// Convert a plain list of IP addresses into IPRules object
var ipRules = [for ip in whitelistedIPs: { value: '${ip}' }]

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module switchVnets './vnet-switcher.bicep' = if (isolated || private) {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' =  {
  name: 'cog-${nameSuffix}'
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    apiProperties: {
      statisticsEnabled: true
    }
    customSubDomainName: 'cog-${nameSuffix}'
    publicNetworkAccess: 'Disabled'

    restore: false
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: ipRules
      virtualNetworkRules: (shouldAllowPublicAccess) ? [] : [
        {
          id: switchVnets.outputs.subnetId
          // ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
  }

  tags: coreTags
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPoint-${uniqueStr}'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, 'cog')
    nameSuffixShort: nameSuffixShort
    serviceToLink: cognitiveService.id
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
    groupIds: [
      'account'
    ]
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZone-${uniqueStr}'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, 'cog')
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.cognitiveServicesDnsZoneFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
  }
}

var kvName = 'kv-${replace(nameSuffix, component, 'shrd')}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
}

resource secretUser 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'cvEndpoint'
  properties: {
    value: cognitiveService.properties.endpoint
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'cvPrimaryAccessKey'
  properties: {
    value: cognitiveService.listKeys().key1
  }
}

output endpoint string = cognitiveService.properties.endpoint
output lookupKeys array = [ 'cvEndpoint', 'cvPrimaryAccessKey' ]

