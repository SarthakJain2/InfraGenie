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

@description('The custom domain name for the APIM service')
#disable-next-line no-unused-params
param apimCustomDomainName string = 'rhipheus.cloud'

@description('Provide a name of the ssl Certificate in Key Vault.  Default is apimSSLCert')
param certName string = 'apimSSLCert'

var publicIpName = 'pip-${replace(nameSuffixShort, component, 'apim')}'

module globalConfig 'global.bicep' = {
   name: 'configModule${uniqueStr}'
   params: {
      env: env
   }
}

module publicIpAddress 'public-ip-address.bicep' = {
   name: 'pip${uniqueStr}'
   params: {
      location: location
      coreTags: coreTags
      nameSuffix: publicIpName
      lableName: true
   }
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
      publicIpAddressId: publicIpAddress.outputs.id
      restore: false
   }

   identity: {
      type: identityType
   }

}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview'  existing= {
   name: 'id-${nameSuffixShort}'

}


module accessPolicy 'coreVault-accessPolicy.bicep' = {
   name: 'keyVaultAccessPolicy'
   params: {
      nameSuffix: nameSuffix
      objectId: apiManagement.identity.principalId
   }
}
module accessPolicyManagedIdentity 'coreVault-accessPolicy.bicep' = {
   name: 'keyVaultAccessPolicyMI'
   params: {
      nameSuffix: nameSuffix
      objectId: managedIdentity.properties.principalId
   }
}
//creating a delay for 40-50 secs.
module certDeploymentScript 'delay-deployment-script.bicep' = {
   name: 'certDeploymentScript'
   params: {
      coreTags: coreTags
      location: location
      nameSuffixShort: nameSuffixShort
   }
}

module apiManagementHostName 'api-management-hostName.bicep' = {
   name: 'apiManagementCustomHost'
   dependsOn: [
      apiManagement
      accessPolicy
      certDeploymentScript
   ]
   params: {
      location: location
      sku: sku
      component: component
      coreTags: coreTags
      env: env
      identityType: identityType
      nameSuffix: nameSuffix
      nameSuffixShort: nameSuffixShort
      publisherEmail: publisherEmail
      publisherName: publisherName
      skuCount: skuCount
      subnetName: subnetName
      virtualNetworkType: virtualNetworkType
      apimCustomDomainName: apimCustomDomainName
      existingNetworkId: existingNetworkId
      dnsZoneResourceGroupId: dnsZoneResourceGroupId
      certName: certName
      keyVaultURI: accessPolicy.outputs.keyVaultURI

   }

}

output apimName string = apiManagement.name
output apimId string = apiManagement.id
