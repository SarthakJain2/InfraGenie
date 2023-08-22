@description('Specifies the location for resources.')
param location string

@description('Specifie the sku details')
param sku object

@description('Tags for the Bastion resources.  Must be of type ResourceTags')
param coreTags object

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

param nameSuffixShort string

@description('Overriding VM Name')
param nameOverride string = ''

param subnetName string = 'default'

param imageReferenceId string

@description('The admin username for the VM')
param adminUsername string

@secure()
@description('The admin password for the VM')
param adminPassword string

var vmNameSuffix = 'vm-${(nameOverride == '') ? nameSuffix : nameOverride}'

@description('Specifie the Orchestration Mode')
@allowed([ 'Uniform', 'Flexible' ])
param orchestrationMode string = 'Uniform'

param existingNetworkId string = ''
param uniqueStr string = uniqueString(utcNow('u'))

module nsg './nsg.windows.bicep' = {
  name: 'nsg-${nameSuffix}'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
  }
}

module getImageOsState './get-image-os-state.bicep' = {
  name: 'getImageOsState-${uniqueStr}'
  params: {
    imageReferenceId: imageReferenceId
  }
}

var osProfile = (getImageOsState.outputs.osState == 'Generalized') ? {
  adminPassword: adminPassword
  adminUsername: adminUsername
  computerNamePrefix: vmNameSuffix
} : null

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2022-11-01' = {
  name: 'vmss-${nameSuffix}'
  location: location
  tags: coreTags
  sku: sku
  properties: {
    upgradePolicy: {
      mode: 'Manual'
    }
    singlePlacementGroup: true
    virtualMachineProfile: {
      storageProfile: {
        imageReference: {
          id: imageReferenceId
        }
      }
      osProfile: osProfile
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-${nameSuffix}'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              networkSecurityGroup: {
                id: nsg.outputs.nsgId
              }
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: switchVnets.outputs.subnetId
                    }
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: false
        }
      }
    }

    orchestrationMode: orchestrationMode

  }
}

output id string = vmss.id
output name string = vmss.name
