param nameSuffixShort string

@description('Existing network ID to link to.  If empty, will look for network specific to the project inside the resource group.')
param existingNetworkId string = ''
param subnetName string = 'primary'
param dnsZoneResourceGroupId string = ''

var vnetName = empty(existingNetworkId) ? 'vnet-${nameSuffixShort}' : substring(existingNetworkId, lastIndexOf(existingNetworkId, '/') + 1)
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

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (!empty(existingNetworkId)) {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

resource spokeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = if (!empty(existingNetworkId)) {
  parent: spokeVirtualNetwork
  name: subnetName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (empty(existingNetworkId)) {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

// Existing subnets can be in any resource group and hence snetResourceGroup could be different from where the VNET is present
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = if (empty(existingNetworkId)) {
  name: subnetName
  parent: virtualNetwork
}

output subscriptionId string = subscriptionId
output subnetName string = empty(existingNetworkId) ? subnet.name : spokeSubnet.name
output subnetId string = empty(existingNetworkId) ? subnet.id : spokeSubnet.id
output subnet object = empty(existingNetworkId) ? subnet : spokeSubnet
output networkId string = empty(existingNetworkId) ? virtualNetwork.id : spokeVirtualNetwork.id
output networkName string = empty(existingNetworkId) ? virtualNetwork.name : spokeVirtualNetwork.name
output networkRg string = vnetResourceGroup
output dnsZoneSubscriptionId string = dnsZoneSubscriptionId
output dnsZoneRg string = empty(dnsZoneResourceGroupId) ? vnetResourceGroup : dnsZoneResourceGroup
