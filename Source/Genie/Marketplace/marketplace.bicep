targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

@description('Set of core tags')
param coreTags object

@description('Current Project Name')
param projectName string

param companyName string
param subdomain string
param contactName string
param contactEmail string

param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
// param hubVnetResourceGroupId string = ''
param coreStorageAccount string = 'stshareddev002'
param deployJumpbox string = 'false'
param whitelistedIPs array = []

param networkingType string = 'isolated'

param vmSize string = 'Standard_D2s_v3'

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

// @description('Managed identity supplied by azure marketplace')
// param principalId string

@description('Override the index in the Resource Group')
param indexOverride string = ''

param storageUrl string = 'core.windows.net'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param isPublic bool = true

// Compute current index
var rg = resourceGroup().name
var idx = lastIndexOf(rg, '-')
var nextIndex = (empty(indexOverride) && idx > 0) ? int(substring(rg, idx + 1)) : 1
var index = (indexOverride == '') ? padLeft(nextIndex, 3, '0') : indexOverride

// var tenantId = subscription().tenantId

var containerName = 'common'

module marketplace './empty.bicep' = {
  name: 'pid-926eb55b-1b56-469f-94b3-8f3f8166c5b1-partnercenter'
  params: {}
}

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

var nameSuffixShort = format(globalConfig.outputs.nameSuffixShortFormat, projectName, env, index)

module prerequisitesSlim 'prerequisites-slim.bicep' = {
  name: 'prerequisitesSlim'
  params: {
    coreTags: coreTags
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
    env: env
    existingNetworkId: (!empty(existingNetworkId)) ? existingNetworkId :''
    location: location
    nameSuffix: toLower(format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index))
    nameSuffixShort: nameSuffixShort
    vnetAddressPrefixes: [ '10.3.0.0/16' ]
    subnetAddressPrefixes: [
      {
        name: 'primary'
        addressPrefix: '10.3.0.0/24'
      }
    ]

  }
}

module virtualMachine 'vm-windows-mp.bicep' = {
  name: 'virtualMachine'
  dependsOn: [
    prerequisitesSlim
  ]
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ./marketplace.ps1 -SubscriptionId "${subscription().id}" -ResourceGroupName "${resourceGroup().name}" -ProjectName "${projectName}" -Environment "${env}" -Location "${location}" -ExistingNetworkId "${existingNetworkId}" -NetworkingType "${networkingType}" -DnsZoneResourceGroupId "${dnsZoneResourceGroupId}" -WhitelistedIPs "${whitelistedIPs}" -DeployJumpBox "${deployJumpbox}" -CompanyName "${companyName}" -Subdomain "${subdomain}" -ContactName "${contactName}" -ContactEmail "${contactEmail}"'
    computerName: 'vm-core-dev'
    coreTags: coreTags
    env: env
    fileUris: [
      'https://${coreStorageAccount}.blob.${storageUrl}/${containerName}/marketplace.ps1'
    ]
    location: location
    nameSuffix: toLower(format(globalConfig.outputs.nameSuffixFormat, projectName, globalConfig.outputs.sharedComponent, env, index))
    nameSuffixShort: nameSuffixShort
    vmImageOffer: 'WindowsServer'
    vmImagePublisher: 'MicrosoftWindowsServer'
    vmImageSku: '2022-Datacenter'
    vmSize: vmSize
    isPublic: isPublic
  }
}
