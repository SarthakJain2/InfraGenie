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

@description('Set of core tags')
param coreTags object

@description('Specifies the SKU of Cognitive Service to create. Default creates S0.')
@allowed([
  'F0','S0', 'S1', 'S2', 'S3'
])
param sku string = 'S0'

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
  'OpenAI'
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
param kind string = 'OpenAI'

param isPublic bool = false
param uniqueStr string = uniqueString(newGuid())

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' =  {
  name: 'oai-${nameSuffix}'
  location: location
  tags: coreTags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    customSubDomainName: 'oai-${nameSuffix}'
    publicNetworkAccess: 'Enabled'
    restore: false
  }
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
  name: 'oaiEndpoint'
  properties: {
    value: cognitiveService.properties.endpoint
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'oaiPrimaryAccessKey'
  properties: {
    value: cognitiveService.listKeys().key1
  }
}

output endpoint string = cognitiveService.properties.endpoint
output lookupKeys array = [ 'oaiEndpoint', 'oaiPrimaryAccessKey' ]

