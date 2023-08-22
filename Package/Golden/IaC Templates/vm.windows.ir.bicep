// vm.windows.ir.bicep
// Create a Windows VM from a shared image gallery image
// (c) 2023 Rhipheus LLC

@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Short form of the component this resource is used for')
param component string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Overriding VM Name')
param nameOverride string = ''

@description('The computername on Windows can\'t be more than 15 characters')
param computerName string

@description('Does the VM require a Public IP?')
param isPublic bool = false

// @description('The computername on Windows can\'t be more than 15 characters')
// param computerName string

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

param imageReferenceId string

@description('Required VM Size. Defaults to Standard D4s_v3')
param vmSize string

@description('Should install extensions?')
param installVMExtensions bool = true

// @description('List of file Uris to be used in the command')
// param fileUris array = []

// @description('The command to execute on VM startup')
// param commandToExecute string

@description('Set of core tags')
param coreTags object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''
param subnetName string

var vmOsType = 'Windows'
var vmName = (nameOverride == '') ? 'vm-${nameSuffix}' : nameOverride

module nsg './nsg.windows.bicep' = {
  name: 'nsg-${nameSuffix}'
  params: {
    coreTags: coreTags
    location: location
    nameSuffix: nameSuffix
  }
}

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
    nameSuffixShort: nameSuffixShort
    subnetName: subnetName
    existingNetworkId: existingNetworkId
    dnsZoneResourceGroupId: dnsZoneResourceGroupId
  }
}

module networkInterface './network-interface.bicep' = {
  name: 'nic-${nameSuffix}'
  dependsOn: [
    nsg
  ]
  params: {
    location: location
    nameSuffix: nameSuffix
    nameSuffixShort: nameSuffixShort
    coreTags: coreTags
    attachPublicIP: isPublic
    existingNetworkId: existingNetworkId
    subnetName: subnetName
  }
}

module getImageOsState './get-image-os-state.bicep' = {
  name: 'getImageOsState-${uniqueStr}'
  params: {
    imageReferenceId: imageReferenceId
  }
}

var osProfile = (getImageOsState.outputs.osState == 'Specialized') ? null : {
  adminUsername: adminUsername
  adminPassword: adminPassword
  computerName: length(computerName) > 15 ? substring(computerName, 0, 15) : computerName
  windowsConfiguration: {
    provisionVMAgent: true
    enableAutomaticUpdates: true
    patchSettings: {
      patchMode: 'AutomaticByOS'
    }
  }
  allowExtensionOperations: true
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  tags: coreTags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: imageReferenceId
      }
      osDisk: {
        createOption: 'FromImage'
        osType: vmOsType
        name: 'disk-${vmName}'
        deleteOption: 'Delete'
      }

    }
    osProfile: osProfile
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.outputs.nicId
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if(installVMExtensions) {
//   name: '${vmName}/CustomScriptExtension'
//   location: location
//   tags: coreTags

//   dependsOn: [
//     virtualMachine
//   ]
//   properties: {
//     autoUpgradeMinorVersion: true
//     publisher: 'Microsoft.Compute'
//     type: 'CustomScriptExtension'
//     typeHandlerVersion: '1.10'
//     settings: {
//       fileUris: fileUris
//       timestamp: 123456789
//     }
//     protectedSettings: {
//       commandToExecute: commandToExecute
//     }

//   }
// }

resource vmAntimalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vmOsType == 'Windows' && installVMExtensions) {
  parent: virtualMachine
  name: 'IaaSAntimalware'
  location: location
  tags: coreTags

  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    settings: {
      AntimalwareEnabled: true
      ScheduledScanSettings: {
        isEnabled: true
        scanType: 'Quick'
        day: 7
        time: 120
      }
    }
  }
}

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

var shared = replace(nameSuffix, component, 'shrd') //globalConfig.outputs.sharedComponent

module addDevBoxUsername './add-to-vault.bicep' = {
  name: 'addDevBoxUsername-${uniqueStr}'
  params: {
    nameSuffix: shared
    key: '${vmName}-AdminUsername'
    value: adminUsername
  }
}

module addDevBoxPassword './add-to-vault.bicep' = {
  name: 'addDevBoxPassword-${uniqueStr}'
  params: {
    nameSuffix: nameSuffix
    key: '${vmName}-Password'
    value: adminPassword
  }
}

output publicIpAddressId string = networkInterface.outputs.publicIpAddressId
output devBoxUsernameKey string = addDevBoxUsername.outputs.key

// This actually doesn't contain any secret.  Just key to the secret... yikes... that sounds bad!
#disable-next-line outputs-should-not-contain-secrets
output devBoxPasswordKey string = addDevBoxPassword.outputs.key
