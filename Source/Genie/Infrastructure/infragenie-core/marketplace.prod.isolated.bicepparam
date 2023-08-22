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
param existingNetworkId = ''
param dnsZoneResourceGroupId = ''
