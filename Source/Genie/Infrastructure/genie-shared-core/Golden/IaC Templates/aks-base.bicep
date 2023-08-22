@description('Specifies the location for resources')
param location string

param env string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Set of core tags')
param coreTags object

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param count int = 1

@description('The size of the Virtual Machine.')
param vmSize string = 'Standard_D2s_v3'

@description('The type of operating system.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

param aksClusterSku object = {
  name: 'Basic'
  tier: 'Free'
}

param kubernetesVersion string = '1.25.6'

param agentPoolName string

param clientId string = 'msi'

param aksClusterSettings object = {
  networkPlugin: 'azure'
  networkPolicy: 'azure'
  podCidr: '10.244.0.0/16'
  serviceCidr: '10.0.0.0/16'
  dnsServiceIP: '10.0.0.10'
  dockerBridgeCidr: '172.17.0.1/16'
}

param loadBalancerSku string = 'standard'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param existingNetworkId string = ''

@description('The name of the subnet')
param subnetName string

param dnsZoneResourceGroupId string = ''

@description('Should public access be allowed to the resources?')
param shouldAllowPublicAccess bool 

@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
  'LACluster'
  'Premium'
  'Standard'
  'Standalone'
])
@description('Specifie the sku details')
param wokspace_sku_Name string = 'PerGB2018'

param managedIdentityId string 

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

var aksDnsZoneNameFormat = format(globalConfig.outputs.aksDnsZoneNameFormat, location)


module switchVnets './vnet-switcher.bicep' ={
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}


resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: aksDnsZoneNameFormat
  scope: resourceGroup(switchVnets.outputs.dnsZoneSubscriptionId, switchVnets.outputs.dnsZoneRg)
}
module workspace 'log-analytics-workspace.bicep' = {
  name: 'logAnalyticsWorkspce'
  params: {
    nameSuffixShort: nameSuffixShort
    location: location
    coreTags: coreTags
    skuName: wokspace_sku_Name
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' = {
  name: 'aks-${nameSuffixShort}'
  location: location
  tags: coreTags
  identity: {
     type: 'UserAssigned'
     userAssignedIdentities: {
      '${managedIdentityId}':{}
     }
  }
  sku: {
    name: aksClusterSku.name
    tier: aksClusterSku.tier
  }
  properties: {
    enableRBAC: true
    dnsPrefix: 'aks-${nameSuffixShort}-dns'
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: (shouldAllowPublicAccess) ? [] : [
       {
        name: agentPoolName
        osDiskSizeGB: osDiskSizeGB
        count: count
        vmSize: vmSize
        osType: osType
        kubeletDiskType: 'OS'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        vnetSubnetID: switchVnets.outputs.subnetId         
       }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspace.outputs.workspaceId
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
            enableSecretRotation: 'false'
            rotationPollInterval: '2m'
        }
      }
    }
    servicePrincipalProfile: {
      clientId: clientId
    }
    networkProfile: {
      networkPlugin: aksClusterSettings.networkPlugin
      networkPolicy: aksClusterSettings.networkPolicy
      podCidr: aksClusterSettings.podCidr
      serviceCidr: aksClusterSettings.serviceCidr
      dnsServiceIP: aksClusterSettings.dnsServiceIp
      dockerBridgeCidr: aksClusterSettings.dockerBridgeCidr
      loadBalancerSku: loadBalancerSku
       
    }
    apiServerAccessProfile: {
       enablePrivateCluster: true
       enablePrivateClusterPublicFQDN: false
       privateDNSZone: privateDnsZone.id

    }
  }
}

output aksClusterId string = aksCluster.id
