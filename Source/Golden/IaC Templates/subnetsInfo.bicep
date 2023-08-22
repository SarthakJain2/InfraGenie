targetScope = 'resourceGroup'

param vnetName string
param vnetResourceGroup string
param subnetCount int

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}
output subnetInfo array = [for i in range(0, subnetCount): {
  id: virtualNetwork.properties.subnets[i].id
  name: virtualNetwork.properties.subnets[i].name
}]
