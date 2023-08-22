@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Set of core tags')
param coreTags object

@description('The name of the Bastion public IP address')
param applicationGatewayName string = 'agw-${nameSuffixShort}'

@description('Provide SKU Name Eg: Standard_v2')
param skuSize string

@description('Provide SKU Tier Eg: Standard_v2')
param tier string

@description('Provide min capacity of the app gateway')
param minCapacity int

@description('Provide max capacity of the app gateway')
param maxCapacity int

@description('The name of the Bastion public IP address')
param publicIpName string = 'agwpip-${nameSuffixShort}'

param subnetName string = 'ApplicationGatewaySubnet'
param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''

@description('Provide the name For appGateway Ip config Eg: ipconfig')
param frontendIPConfigurationName string = 'appGatewayIpConfig'

@description('Provide the name For Frontend  Eg: http')
param frontendPortName string = 'http_80'

@description('Provide the name For BackendPool')
param backendAddressPoolName string = 'default'

@description('Provide the name For BackendPoolsetting')
param backendHttpSettingsCollectionName string = 'http_setting'

@description('Provide the name For http Listener')
param httpListenerName string = 'ln-http'

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

var frontendIPConfiguration = resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, frontendIPConfigurationName)
var frontendPort = resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, frontendPortName)
var httpListener = resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerName)
var backendAddressPool = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendAddressPoolName)
var backendHttpSettings = resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttpSettingsCollectionName)

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module publicIpAddress 'public-ip-address.bicep' = {
  name: 'pip${uniqueStr}'
  params: {
    location: location
    nameSuffix: publicIpName
    coreTags: coreTags
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGatewayName
  location: location
  tags: coreTags
  properties: {
    sku: {
      name: skuSize
      tier: tier
    }
    gatewayIPConfigurations: [
      {
        name: 'IpConfig'
        properties: {
          subnet: {
            id: switchVnets.outputs.subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIpAddress.outputs.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsCollectionName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          frontendIPConfiguration: {

            id: frontendIPConfiguration
          }
          frontendPort: {
            id: frontendPort
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    listeners: []
    requestRoutingRules: [
      {
        name: 'route'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: httpListener
          }
          priority: 1000
          backendAddressPool: {
            id: backendAddressPool
          }
          backendHttpSettings: {
            id: backendHttpSettings
          }
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
  }
}
