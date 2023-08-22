using './marketplace.bicep'

param env = 'prod'
param coreTags = {
  Created_by: 'Vyas Bharghava'
  env: 'prod'
  project_name: 'infragenie'
}
param projectName = 'genie'
param adminUsername = 'marketplaceAdmin'
param adminPassword = 'HelloSpock@123'
param managedIdentity = 'af41beae-74c0-4397-bd19-281e749d17c1'
param existingNetworkId = '/subscriptions/ece96d80-c934-4839-bb90-c2f9ff7c94f9/resourceGroups/rg-core-dev-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-spoknet-dev-001'
param dnsZoneResourceGroupId = ''

