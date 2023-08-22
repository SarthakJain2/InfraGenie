targetScope = 'resourceGroup'

@allowed([ 'United States', 'Europe', 'Asia Pacific', 'Australia' ])
@description('Give the location')
param location string = 'United States' // For reference   https://learn.microsoft.com/en-us/azure/active-directory-b2c/data-residency  

param b2cName string

@description('Provide the Country Code Eg: US, AU ')
@allowed([
  'US','CA', 'IN', 'AU'
])
param countryCode string = 'US'

@allowed([ 'PremiumP2', 'PremiumP1', 'Standard' ])
param skuName string = 'Standard'

@description('Set of core tags')
param coreTags object

resource b2cDirectory 'Microsoft.AzureActiveDirectory/b2cDirectories@2021-04-01' = {
  location: location
  name: '${b2cName}.onmicrosoft.com'
  sku: {
    name: skuName
    tier: 'A0'     //this is the only value it has
  }
  properties: {
    createTenantProperties: {
      countryCode: countryCode
      displayName: b2cName
    }
  }
  tags: coreTags
}
