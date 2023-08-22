@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Set of core tags')
param coreTags object

@description('Provide the SKU for App Service Plan Eg: S3')
@allowed([ 'B1', 'B2', 'B3', 'P1V2', 'P1V3', 'P2V2', 'P2V3', 'P3V2', 'P3V3', 'S1', 'S2', 'S3' ])
param skuname string

@description('Provide the instance Numeber of the ASP Eg: 1')
param capacity int

param tier string = 'Dynamic'

@description('Provide the OS of the App service plan by default it is set to windows')
@allowed([ 'linux', 'windows' ])
param osType string


resource azureServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${nameSuffix}'
  location: location
  tags: coreTags
  kind: osType == 'linux' ? 'linux' : 'app'
  sku: {
    name: skuname
    capacity: capacity
    tier: tier
  }
  properties: {
    zoneRedundant: false
    reserved: osType == 'linux'
  }
}
output azureServicePlanId string = azureServicePlan.id
