targetScope = 'resourceGroup'

@description('Give the location name')
param location string

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

@description('Set of core tags')
param coreTags object

@description('Provide a the id of the log Analytics workspace')
param WorkspaceResourceId string

param subnetName string = 'primary'
param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''

param uniqueStr string = uniqueString(utcNow('u'))

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  location: location
  name: 'cae-${nameSuffixShort}'
  tags: coreTags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(WorkspaceResourceId, '2021-06-01').customerId
        sharedKey: listKeys(WorkspaceResourceId, '2021-06-01').primarySharedKey

      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: switchVnets.outputs.subnetId
    }
  }
}

resource containerApps 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: 'ca-${nameSuffixShort}'
  location: location
  tags: coreTags
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: 'ca-${nameSuffixShort}'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
    }

  }
}

output containerName string = containerApps.name
