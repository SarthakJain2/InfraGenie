targetScope = 'resourceGroup'

@allowed([ 'United States', 'Europe', 'Asia Pacific', 'Australia' ])
@description('Give the location')
param location string = 'United States' // For reference   https://learn.microsoft.com/en-us/azure/active-directory-b2c/data-residency  

param name string

@description('Provide the Country Code Eg: US, AU ')
param countryCode string = 'US'

@allowed([ 'PremiumP2', 'PremiumP1' ])
param skuName string = 'PremiumP2'

@description('Set of core tags')
param coreTags object

resource b2cDirectory 'Microsoft.AzureActiveDirectory/b2cDirectories@2021-04-01' = {
  #disable-next-line no-hardcoded-location
  location: location
  name: '${name}.onmicrosoft.com'
  sku: {
    name: skuName
    tier: 'A0' //this is the only value it has
  }
  properties: {
    createTenantProperties: {
      countryCode: countryCode
      displayName: name
    }
  }
  tags: coreTags
}
