targetScope = 'resourceGroup'
@description('Specifies the environment this template deploys to')
param env string

@description('Give the location name')
param location string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
#disable-next-line no-unused-params
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('The name of the component for the API Management service.  Usually it\'shrd\')')
param component string

param existingNetworkId string = ''

@description('The name of the subnet')
param subnetName string

@description('Set of core tags')
param coreTags object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

@description('The pricing tier of this API Management service')
@allowed([
   'Basic'
   'Premium'
   'Developer'
   'Standard'
])
param sku string

@description('The instance size of this API Management service.')
param skuCount int

@description('Give the virtualNetwork type for Api Management')
@allowed([
   'External'
   'None'
   'Internal'
])
param virtualNetworkType string

#disable-next-line no-unused-params
param isPublic bool = false

param dnsZoneResourceGroupId string = ''

@description('Managed service identity of the Api Management service.')
@allowed([
   'None'
   'SystemAssigned'
   'SystemAssigned, UserAssigned'
   'UserAssigned'
])
param identityType string

@description('The publisher email address of the service ')
param publisherEmail string

@description('The publisher name address of the service')
param publisherName string

param apimCustomDomainName string = 'rhipheus.cloud'

@description('Provide the ssl Certificate id from the keyVault')
param keyVaultURI string

@description('Provide a name of the ssl Certificate in Key Vault.  Default is apimSSLCert')
param certName string = 'apimSSLCert'

var loggerType = 'applicationInsights'
var publicIpName = 'pip-${replace(nameSuffixShort, component, 'apim')}'

module globalConfig 'global.bicep' = {
   name: 'configModule${uniqueStr}'
   params: {
      env: env
   }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' existing = {
   name: 'pip-${publicIpName}'
}

module switchVnets './vnet-switcher.bicep' = {
   name: 'switchVnets-${uniqueStr}'
   params: {
      nameSuffixShort: nameSuffixShort
      subnetName: subnetName
      existingNetworkId: existingNetworkId
      dnsZoneResourceGroupId: dnsZoneResourceGroupId
   }
}
resource appInsight 'Microsoft.Insights/components@2020-02-02' existing = {
   name: 'appi-${nameSuffixShort}'
}

// publicNetworkAccess must be 'Enabled' initially even if the service is not public
resource apiManagement 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
   location: location
   name: 'apim4-${nameSuffixShort}'
   sku: {
      name: sku
      capacity: skuCount
   }
   tags: coreTags
   properties: {
      publisherEmail: publisherEmail
      publisherName: publisherName
      virtualNetworkType: virtualNetworkType
      virtualNetworkConfiguration: {
         subnetResourceId: switchVnets.outputs.subnetId
      }
      publicNetworkAccess: 'Enabled'
      publicIpAddressId: publicIpAddress.id
      hostnameConfigurations: [
         {
            type: 'DeveloperPortal'
            hostName: 'apim-${env}-developer.${apimCustomDomainName}'
            keyVaultId: '${keyVaultURI}secrets/${certName}/'
            certificateSource: 'KeyVault'
         }
         {
            type: 'Management'
            hostName: 'apim-${env}-management.${apimCustomDomainName}'
            keyVaultId: '${keyVaultURI}secrets/${certName}/'
            certificateSource: 'KeyVault'
         }
         {
            type: 'Proxy'
            hostName: 'apim-${env}.${apimCustomDomainName}'
            keyVaultId: '${keyVaultURI}secrets/${certName}/'
            defaultSslBinding: true
            certificateSource: 'KeyVault'
            negotiateClientCertificate: false

         }
         {
            type: 'Scm'
            hostName: 'scm-apim-${env}.${apimCustomDomainName}'
            keyVaultId: '${keyVaultURI}secrets/${certName}/'
            certificateSource: 'KeyVault'
         }

      ]
   }

   identity: {
      type: identityType
   }

}

resource logger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
   parent: apiManagement
   name: appInsight.name
   properties: {
      credentials: {
         instrumentationKey: appInsight.properties.InstrumentationKey
      }
      loggerType: loggerType
      resourceId: appInsight.id
   }
}

output apimName string = apiManagement.name
output apimId string = apiManagement.id
