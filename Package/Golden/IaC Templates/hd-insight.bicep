targetScope = 'resourceGroup'

// @description('Give the hdInsight name')
// param hdInsightName string

@description('Specify location')
param location string

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

@description('Specifies the environment this template deploys to')
param env string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

@description('The type of the HDInsight cluster to create.')
param clusterType string = 'hadoop'

@description('These credentials can be used to submit jobs to the cluster and to log into cluster dashboards.')
param clusterLoginUserName string

@description('The password must be at least 10 characters in length and must contain at least one digit, one upper case letter, one lower case letter, and one non-alphanumeric character except (single-quote, double-quote, backslash, right-bracket, full-stop). Also, the password must not contain 3 consecutive characters from the cluster username or SSH username.')
@minLength(10)
@secure()
param clusterLoginPassword string

@description('These credentials can be used to remotely access the cluster. The username cannot be admin.')
param sshUserName string

@description('SSH password must be 6-15 characters long and must contain at least one digit, one upper case letter, and one lower case letter.  It must not contain any 3 consecutive characters from the cluster login name')
@minLength(6)
@maxLength(15)
@secure()
param sshPassword string

@description('Provide a short suffix name per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Domain Name')
param domainName string

param subnetAddressPrefix object

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module nsg 'nsg-domain-service.bicep' = {
  name: 'nsgModule'
  params: {
    location: location
    nameSuffix: nameSuffix
    coreTags: coreTags
  }
}

resource activeDirectory 'Microsoft.AAD/domainServices@2022-09-01' existing = {
  name: domainName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'id-${nameSuffixShort}'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'vnet-${nameSuffixShort}'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: virtualNetwork
  name: subnetAddressPrefix.name
  properties: {
    addressPrefix: subnetAddressPrefix.addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
       id:nsg.outputs.nsgId
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'st${hypenlessNameSuffix}'
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties:{}
}

resource hdInsight 'Microsoft.HDInsight/clusters@2021-06-01' = {
  name:'hadoop-${nameSuffixShort}'
  location: location
  tags: coreTags
  properties: {
    tier: 'Premium'
    osType: 'Linux'
    clusterVersion: '4.0'
    clusterDefinition: {
      kind: clusterType
      componentVersion: {
        '${clusterType}': '3.1'
      }
      configurations: {
        gateway: {
          'restAuthCredential.isEnabled': true
          'restAuthCredential.username': clusterLoginUserName
          'restAuthCredential.password': clusterLoginPassword
        }
      }
    }
    storageProfile: {
      storageaccounts: [
        {
          name: replace(replace(concat(storageAccount.properties.primaryEndpoints.blob), 'https:', ''), '/', '')
          isDefault: true
          container: 'hadoop-${nameSuffixShort}'
          key: listKeys(storageAccount.name, '2022-09-01').keys[0].value
        }
      ]
    }
    computeProfile: {
      roles: [
        {
          name: 'headnode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: 'Standard_D3_v2'
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
          virtualNetworkProfile: {
            id: virtualNetwork.id
            subnet:subnet.id
          }
        }
        {
          name: 'workernode'
          targetInstanceCount: 1
          hardwareProfile: {
            vmSize: 'Standard_D3_v2'
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
          virtualNetworkProfile: {
            id: virtualNetwork.id
            subnet:subnet.id
          }
        }
      ]       
    }
     securityProfile: {
      aaddsResourceId: activeDirectory.id
      msiResourceId: managedIdentity.id
      directoryType: 'ActiveDirectory'
      domain: domainName
      domainUsername: 'sukhvir@${domainName}'
      domainUserPassword: 'Sbx@9870'
      ldapsUrls: [
        'ldaps://${domainName}:636'     
      ]
     } 
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities:{
      '${managedIdentity.id}': {}
    } 
  }
}

output storage object =  storageAccount.properties
output hdInsightId string = hdInsight.id
