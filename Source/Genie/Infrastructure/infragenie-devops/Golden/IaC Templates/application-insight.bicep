@description('Specifies the location for resources.')
param location string

@description('Tags for the App-Insight resources.  Must be of type ResourceTags')
param coreTags object

@description('Provide a  name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('The kind of application that this componet refers to, used to customize UI.')
@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'

@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
  'LACluster'
  'Premium'
  'Standard'
  'Standalone'
])
@description('Specifie the sku details')
param wokspace_sku_Name string

module workspace 'log-analytics-workspace.bicep' ={
  name: 'logAnalyticsWorkspce'
  params: {
    nameSuffixShort: nameSuffixShort
    location: location
    coreTags: coreTags
    skuName: wokspace_sku_Name
  }
}

resource appInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${nameSuffixShort}'
  location: location
  tags: coreTags
  kind: kind
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: workspace.outputs.workspaceId
  }
}

output appInsightName string = appInsight.name
output appInsightId string = appInsight.id
output appInsightKey string = appInsight.properties.InstrumentationKey
output appInsightConnectionString string = appInsight.properties.ConnectionString
output WorkspaceResourceId string = workspace.outputs.workspaceId
