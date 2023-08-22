@description('Specifies the location for resources.')
param location string

@description('Tags for the App-Insight resources.  Must be of type ResourceTags')
param coreTags object

@description('Provide a  name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

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
param skuName string

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-${nameSuffixShort}'
  location: location
  tags: coreTags
  properties: {
    features: {
      immediatePurgeDataOn30Days: false
    }
    sku: {
      name: skuName
    }
  }
}
output workspaceId string = workspace.id

