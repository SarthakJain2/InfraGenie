@description('env')
param env string

@description('Specifies the location for resources.')
param location string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Should the resources be public and not bound to a network?')
param shouldAllowPublicAccess bool = false

@description('Address prefixes for the VNET')
param vnetAddressPrefixes array

@description('Address prefixes for the subnet')
param subnetAddressPrefixes array

@description('Should subnets be created if creating a VNET?')
param shouldCreateSubnets bool = true

@description('Should new DNS Zones to be created?')
param shouldCreateDnsZones bool = true

@allowed([ 'All', 'KeyVault', 'ServiceBus', 'SqlServer', 'StorageAccount', 'CognitiveServices', 'ContainerRegistry', 'SynapseSql' ])
param dnsZonesToLaydown array = [ 'All' ]

param dnsZoneResourceGroupId string = ''
param dnsZones array = []

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

param uniqueStr string = uniqueString(utcNow('u'))

param existingNetworkId string = ''

param nsgId string = ''
param apimNsgId string = ''

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

var subnets = [for subnet in subnetAddressPrefixes: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    // if nsgId property is present in the configuration and is empty, no NSG is attached to the subnet
    // if no nsgId is supplied through configuration for APIManagementSubnet, apimNsgId is used
    //  otherwise, use what is supplied through configuration
    // if no nsgId is supplied through configuration for any other subnet, the Shared NSG is used
    //  the local parameter nsgId usually contains the Shared NSG Id
    networkSecurityGroup: (contains(subnet, 'nsgId') && empty(subnet.nsgId)) ? null : {
      id: subnet.name == 'APIManagementSubnet' ? ((contains(subnet, 'nsgId') && (!empty(subnet.nsgId))) ? subnet.nsgId : apimNsgId) : ((contains(subnet, 'nsgId') && (!empty(subnet.nsgId))) ? subnet.nsgId : nsgId)
    }
    delegations: contains(subnet, 'delegations') ? [ {
        name: 'delegation'
        properties: { serviceName: subnet.delegations[0] } } ] : []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: contains(subnet, 'serviceEndPoints') ? [ { service: subnet.serviceEndPoints[0] } ] : []
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = if (empty(existingNetworkId) && !(shouldAllowPublicAccess)) {
  name: 'vnet-${nameSuffixShort}'
  location: location
  tags: coreTags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

// New subnets can be in any resource group and hence snetResourceGroup could be different from where the VNET is present
// subnetResourceGroup is NOT used when creating new subnets
// Uncomment scope to experince it firsthand
@batchSize(1)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = [for subnet in subnets: if (empty(existingNetworkId) && shouldCreateSubnets && !(shouldAllowPublicAccess)) {
  name: subnet.name
  parent: virtualNetwork
  properties: subnet.properties
  //scope: resourceGroup(subnetResourceGroup)
}]

module switchVnets './vnet-switcher.bicep' = if (!shouldAllowPublicAccess) {
  name: 'switchVnets-${uniqueStr}'
  dependsOn: [
    virtualNetwork
    subnet
  ]
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnets[0].name
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    existingNetworkId: existingNetworkId
  }
}

var startIdx = (indexOf(existingNetworkId, '/resourceGroups/') + length('/resourceGroups/'))
var endIdx = indexOf(existingNetworkId, '/providers') - startIdx
var vnetResourceGroup = empty(existingNetworkId) ? resourceGroup().name : substring(existingNetworkId, startIdx, endIdx)

var dnzStartIdxRg = (indexOf(dnsZoneResourceGroupId, '/resourceGroups/') + length('/resourceGroups/'))
var dnsZoneResourceGroup = empty(dnsZoneResourceGroupId) ? vnetResourceGroup : substring(dnsZoneResourceGroupId, dnzStartIdxRg)

///subscriptions/0040c20d-9fbe-42ac-b3f9-f83269a753d1/resourceGroups/rg-core-sbx-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-core-sbx-001
var subStartIdx = (indexOf(existingNetworkId, '/subscriptions/') + length('/subscriptions/'))
var subEndIdx = indexOf(existingNetworkId, '/resourceGroups') - subStartIdx
var subscriptionId = empty(existingNetworkId) ? subscription().subscriptionId : substring(existingNetworkId, subStartIdx, subEndIdx)

var dnzStartIdx = (indexOf(dnsZoneResourceGroupId, '/subscriptions/') + length('/subscriptions/'))
var dnzEndIdx = indexOf(dnsZoneResourceGroupId, '/resourceGroups') - dnzStartIdx
var dnsZoneSubscriptionId = empty(dnsZoneResourceGroupId) ? subscriptionId : substring(dnsZoneResourceGroupId, dnzStartIdx, dnzEndIdx)

module privateDnsZone 'private-dns-zone-only.bicep' = [for dnsZoneName in dnsZones: if ((!shouldAllowPublicAccess) && shouldCreateDnsZones && !empty(dnsZonesToLaydown) && (contains(dnsZonesToLaydown, 'All'))) { 
  name: dnsZoneName
  dependsOn: [
    switchVnets
    virtualNetwork
  ]
  scope: resourceGroup(dnsZoneSubscriptionId, dnsZoneResourceGroup)
  params: {
    coreTags: coreTags
    dnsZoneName: dnsZoneName
    vnetId: switchVnets.outputs.networkId
  }
}]

output id string = switchVnets.outputs.networkId
output name string = switchVnets.outputs.networkName
output subnetInfo array = [for i in range(0, length(subnets)): {
  id: subnet[i].id
  name: subnet[i].name
}]
