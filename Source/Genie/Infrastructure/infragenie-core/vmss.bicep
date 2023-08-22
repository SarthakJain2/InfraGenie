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

@allowed([
  'windowsServer2022DatacenterAzureEdition'
  'windowsServer2019DatacenterGen2'
  'windowsServer2016DatacenterGen2'
  'windows10proGen2'
  'windows11proGen2'
  ''
])
param image string=''

module nsg './nsg.windows.bicep' = {
  name: 'nsg-${nameSuffix}'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
  }
}

module getImageOsState './get-image-os-state.bicep' = if (!empty(imageReferenceId)) {
  name: 'getImageOsState-${uniqueStr}'
  params: {
    imageReferenceId: imageReferenceId
  }
}

var osProfile = (getImageOsState.outputs.osState == 'Generalized') ? {
  adminPassword: adminPassword
  adminUsername: adminUsername
  computerNamePrefix: vmNameSuffix
} : { adminPassword: adminPassword
      adminUsername: adminUsername
      computerNamePrefix: vmNameSuffix
      windowsConfiguration: {
      provisionVmAgent: true
  }}


var imageReference= (image=='windowsServer2022DatacenterAzureEdition') ? {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
  version: 'latest'
}: (image=='windowsServer2019DatacenterGen2') ? {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-datacenter-gensecond'
  version: 'latest'
} : (image=='windowsServer2016DatacenterGen2') ?  {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2016-datacenter-gensecond'
  version: 'latest'
}: (image=='windows10proGen2') ? {
  publisher: 'MicrosoftWindowsDesktop'
  offer: 'Windows-10'
  sku: 'win10-22h2-pro-g2'
  version: 'latest'
}:{}



@description('used to validate the logic to give the Image to the VMSS')
var storageProfile = !empty(image) ? { 
  osDisk: {
  createOption: 'FromImage'
  caching: 'ReadWrite'
  managedDisk: {
    storageAccountType: 'StandardSSD_LRS'
  }
}

imageReference: imageReference

} : { imageReference: {
    id: imageReferenceId
  }}

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
      storageProfile: storageProfile
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
