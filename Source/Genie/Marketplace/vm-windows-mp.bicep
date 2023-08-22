@description('Specifies the environment this template deploys to')
param env string

@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a short name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Overriding VM Name')
param nameOverride string = ''

@description('Does the VM require a Public IP?')
param isPublic bool = false

@description('The computername on Windows can\'t be more than 15 characters')
param computerName string

param existingNetworkId string = ''
param dnsZoneResourceGroupId string = ''

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

@description('Provide a VM Image Publisher.  Defaults to MicrosoftWindowsServer')
param vmImagePublisher string

@description('Provide a VM Image Offer.  Defaults to WindowsServer')
param vmImageOffer string

@description('Provide a VM Image Sku.  Defaults to 2019 Data Center')
param vmImageSku string

@description('Required VM Size. Defaults to Standard D4s_v3')
param vmSize string

@description('Should install extensions?')
param installVMExtensions bool = true

@description('List of file Uris to be used in the command')
param fileUris array = []

@description('The command to execute on VM startup')
param commandToExecute string

// param storageAccountName string

// @secure()
// param storageAccountKey string

@description('Set of core tags')
param coreTags object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

var vmOsType = 'Windows'
var vmName = (nameOverride == '') ? 'vm-${nameSuffix}' : nameOverride

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

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
    subnetName: 'primary'
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
    subnetName: 'primary'
  }
}


resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  tags: coreTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: vmOsType
        name: 'disk-${vmName}'
        deleteOption: 'Delete'
      }

    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: computerName
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'ImageDefault'
        }
      }
      allowExtensionOperations: true
    }
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

resource ownerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope:  resourceGroup()
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('id-${nameSuffixShort}', virtualMachine.id, 'Microsoft.Authorization/roleAssignments')
  scope: virtualMachine
  properties: {
    roleDefinitionId: ownerRoleDefinition.id
    principalId: virtualMachine.identity.principalId
  }
}

resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (installVMExtensions) {
  parent: virtualMachine
  name: 'CustomScriptExtension'
  location: location
  tags: coreTags

  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      timestamp: 123456789
    }
    protectedSettings: {
      fileUris: fileUris
      commandToExecute: commandToExecute
    }

  }
}

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


output publicIpAddressId string = networkInterface.outputs.publicIpAddressId
