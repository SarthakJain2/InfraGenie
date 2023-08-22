using './main.bicep'

param env = 'dev'
param projectName = 'genie'
param vnetAddressPrefixes = [ '10.2.0.0/16' ]
param subnetAddressPrefixes = [
  {
    name: 'primary'
    addressPrefix: '10.205.0.0/17'
  }
  {
    name: 'secondary'
    addressPrefix: '10.205.128.0/18'
  }
  {
    name: 'AzureContainerAppsSubnet'
    addressPrefix: '10.205.220.0/23'
    nsgId: ''
  }
  {
    name: 'APIManagementSubnet'
    addressPrefix: '10.205.232.0/24'
  }
  {
    name: 'ApplicationGatewaySubnet'
    addressPrefix: '10.205.233.0/24'
    nsgId: ''
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.205.234.0/24'
    nsgId: ''
  }
  {
    name: 'AzureCognitiveServicesSubnet'
    addressPrefix: '10.205.235.0/24'
    serviceEndPoints: [
      'Microsoft.CognitiveServices'
    ]
  }
  {
    name: 'AzureFunctionsSubnet'
    addressPrefix: '10.205.236.0/24'
    serviceEndPoints: [
      'Microsoft.Web'
    ]
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.205.243.0/26'
    nsgId: ''
  }
  {
    name: 'AppServiceSubnet'
    addressPrefix: '10.205.243.64/26'
    serviceEndPoints: [
      'Microsoft.Web'
    ]
    delegations: [
      'Microsoft.Web/serverfarms'
    ]
  }
  {
    name: 'AppServiceSubnet2'
    addressPrefix: '10.205.194.0/26'
    serviceEndPoints: [
      'Microsoft.Web'
    ]
    delegations: [
      'Microsoft.Web/serverfarms'
    ]
  }
  {
    name: 'AppServiceSubnet3'
    addressPrefix: '10.205.195.0/24'
    serviceEndPoints: [
      'Microsoft.Web'
    ]
    delegations: [
      'Microsoft.Web/serverfarms'
    ]
  }
  {
    name: 'reserved'
    addressPrefix: '10.205.248.0/21'
  }
]
param existingSubnets = [ 'primary', 'secondary','AzureContainerAppsSubnet','APIManagementSubnet','ApplicationGatewaySubnet','AzureBastionSubnet','AzureCognitiveServicesSubnet','AzureFunctionsSubnet','AzureFirewallSubnet','AppServiceSubnet','AppServiceSubnet2','AppServiceSubnet3','reserved' ]
param principalId = 'af41beae-74c0-4397-bd19-281e749d17c1'
param dnsZones = [ 'privatelink.vaultcore.azure.net','privatelink.blob.core.windows.net','privatelink.applicationinsights.azure.com','privatelink.azurecr.io','privatelink.azurewebsites.net','privatelink.cognitiveservices.azure.com' ]
