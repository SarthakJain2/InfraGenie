targetScope = 'resourceGroup'

@description('Give the name private link name')
param privateLinkName string

@description('Give the name load balancer name')
param loadBalancerName string

@description('Give the name private endpoint name')
param privateEndpointName string

@description('Give the location name')
param location string
@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

param subnetName string

var loadBalancerFrontEndIpConfigurationName = 'myFrontEnd'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
   name: 'vnet-${nameSuffixShort}/${subnetName}'
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2022-05-01' = {
   name: loadBalancerName
   location: location
   sku: {
      name: 'Standard'
   }
   properties: {
      frontendIPConfigurations: [
         {
            name: loadBalancerFrontEndIpConfigurationName
            properties: {
               privateIPAllocationMethod: 'Dynamic'
               subnet: {
                  id: subnet.id
               }
            }
         }
      ]
   }
}

resource privateLink 'Microsoft.Network/privateLinkServices@2022-05-01' = {
   name: privateLinkName
   location: location
   properties: {
      enableProxyProtocol: false
      loadBalancerFrontendIpConfigurations: [
         {
            id: loadBalancer.properties.frontendIPConfigurations[0].name
         }
      ]
      ipConfigurations: [
         {
            name: 'ipConfig'
            properties: {
               privateIPAllocationMethod: 'Dynamic'
               privateIPAddressVersion: 'IPv4'
               subnet: {
                  id: loadBalancer.properties.frontendIPConfigurations[0].properties.subnet.id
               }
            }
         }
      ]
   }
}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
   name: privateEndpointName
   location: location
   properties: {
      subnet: {
         id: subnet.id
      }
      privateLinkServiceConnections: [
         {
            name: privateEndpointName
            properties: {
               privateLinkServiceId: privateLink.id
            }
         }
      ]
   }
   dependsOn: [
      subnet
   ]
}
output name string = privateLink.name
output privateEndpointId string = privateEndpoint.id
