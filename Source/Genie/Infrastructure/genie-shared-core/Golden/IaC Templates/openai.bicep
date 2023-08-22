targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the name of the service with component name')
param nameSuffix string

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
  }
}
