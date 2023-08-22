targetScope = 'resourceGroup'

@description('Specifies the environment this template deploys to')
param env string

@description('Specify location')
param location string

@description('Specifies the application component this resource represents')
param component string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the resource type prefix')
param nameSuffixShort string

@description('Provide the Sku Name Eg: Standard_ZRS')
@allowed([ 'Standard_LRS', 'Standard_ZRS', 'Premium_LRS', 'Premium_ZRS' ])
param skuName string

@description('Provide the Kind Name Eg: StorageV2')
@allowed([ 'BlobStorage', 'BlockBlobStorage', 'Storage', 'StorageV2', 'FileStorage' ])
param kind string

@description('Provide the Kind Name Eg: Hot')
@allowed([ 'Hot', 'Cool', 'Premium' ])
param accessTier string

@description('Specifies the default action of allow or deny when no other rules match')
@allowed([ 'Deny', 'Allow' ])
param defaultAction string

@description('Hierarchical namespace enabled if sets to true')
param isHnsEnabled bool

@description('Address prefixes for the VNET.  Only needed if runPrereq is true')
param vnetAddressPrefixes array = []

@description('Address prefixes for the VNET.  Only needed if runPrereq is true')
param subnetAddressInfo object = {}

param existingNetworkId string = ''
param subnetName string = ''
param dnsZoneResourceGroupId string = ''

param apimNsgId string = ''

@allowed([ 'All', 'KeyVault', 'ServiceBus', 'SqlServer', 'StorageAccount', 'CognitiveServices', 'ContainerRegistry' ])
param dnsZonesToLaydown array = [ 'All' ]

@description('Set of core tags')
param coreTags object

param isPublic bool = false
param runPrereq bool = false
param replaceComponent string = ''

param whitelistedIPs array = []
@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module prerequisities 'storage-prerequisites.bicep' = if (runPrereq) {
  name: 'prerequisites'
  params: {
    env: env
    location: location
    nameSuffixShort: nameSuffixShort
    subnetAddressInfo: subnetAddressInfo
    vnetAddressPrefixes: vnetAddressPrefixes
    coreTags: coreTags
    apimNsgId: apimNsgId
    dnsZonesToLaydown: dnsZonesToLaydown
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

// Convert a plain list of IP addresses into IPRules object
var ipRules = [for ip in whitelistedIPs: { value: '${ip}', action: 'Allow' }]

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: empty(replaceComponent)?'st${hypenlessNameSuffix}': '${replaceComponent}${hypenlessNameSuffix}'
  location: location
  kind: kind
  tags: coreTags
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    networkAcls: {
      defaultAction: defaultAction
      ipRules: ipRules
    }
    publicNetworkAccess: isPublic ? 'Enabled' : 'Disabled'
    isHnsEnabled: isHnsEnabled
  }
}

module privateEndPoint 'private-end-point.bicep' = if (!isPublic) {
  name: 'privateEndPointBlobSA'
  dependsOn: [
    prerequisities
  ]
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: replace(nameSuffix, component, empty(replaceComponent)? 'st': replaceComponent)
    nameSuffixShort: nameSuffixShort
    serviceToLink: storageaccount.id
    groupIds: [
      'blob'
    ]
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
  }
}

module privateDnsZone 'private-dns-zone.bicep' = if (!isPublic) {
  name: 'privateDnsZoneBlobSA'
  dependsOn: [
    privateEndPoint
  ]
  params: {
    coreTags: coreTags
    nameSuffix: replace(nameSuffix, component, empty(replaceComponent)? 'st': replaceComponent)
    nameSuffixShort: nameSuffixShort
    privateDnsZoneName: globalConfig.outputs.storageAccountBolbDnsZoneFormat //format(globalConfig.outputs.keyVaultDnsZoneNameFormat, 'shrd')
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    subnetName: subnetName
  }
}

module addStorageKeyName './add-to-vault.bicep' = {
  name: 'addStorageKeyName-${uniqueStr}'
  params: {
    nameSuffix: nameSuffix
    key: '${storageaccount.name}-KeyName'
    value: storageaccount.listKeys().keys[0].keyName
  }
}

module addStorageKeyValue './add-to-vault.bicep' = {
  name: 'addStorageKeyValue-${uniqueStr}'
  params: {
    nameSuffix: nameSuffix
    key: '${storageaccount.name}-KeyName'
    value: storageaccount.listKeys().keys[0].value
  }
}

output name string = storageaccount.name
output id string = storageaccount.id
output storageAccountKeyName string = addStorageKeyName.outputs.key
output storageAccountKeyValueName string = addStorageKeyValue.outputs.key
