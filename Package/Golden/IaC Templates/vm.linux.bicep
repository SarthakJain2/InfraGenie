@description('Specifies the environment this template deploys to')
#disable-next-line no-unused-params
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
param nameOverride string

@description('The computername on Windows can\'t be more than 15 characters')
param computerName string

@description('Provide a local administrator username')
param adminUsername string

@secure()
@description('Provide a local administrator password')
param adminPassword string

@description('Provide a VM Image Publisher')
param vmImagePublisher string

@description('Provide a VM Image Offer')
param vmImageOffer string

@description('Provide a VM Image Sku')
param vmImageSku string

@description('Required VM Size. Defaults to Standard DS1_v2')
param vmSize string = 'Standard_DS1_v2'

@description('The command to execute on VM startup')
param commandToExecute string

@description('Set of core tags')
param coreTags object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

var rg = resourceGroup().name
var index = substring(rg, lastIndexOf(rg, '-') + 1)

var vmOsType = 'Linux'
var vmName = (nameOverride == '') ? 'vm-${nameSuffix}-${index}' : nameOverride

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-${nameSuffix}'
  location: location
  tags: coreTags
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' existing = {
  name: 'nsg-${nameSuffixShort}'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-${nameSuffixShort}'
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'nic-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    ipConfigurations: [ {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      } ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
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
      linuxConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
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

resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: '${vmName}/CustomScriptExtension'
  location: location
  tags: coreTags

  dependsOn: [
    virtualMachine
  ]
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    settings: {
      commandToExecute: commandToExecute
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
var kvName = 'kv-${shared}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
}

resource secretUser 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: '${component}${adminUsername}'
  properties: {
    value: adminUsername
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: '${component}Password'
  properties: {
    value: adminPassword
  }
}

output vmVaultUsernametKey string = '${component}${adminUsername}'

#disable-next-line outputs-should-not-contain-secrets
output vmVaultPasswordKey string = '${component}Password'

output keyVaultId string = keyVault.id
