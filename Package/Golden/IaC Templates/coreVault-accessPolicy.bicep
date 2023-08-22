@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param nameSuffix string

@description('Provide the ObjectId of the managed Identity Or Service Principal Or User')
param objectId string

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: 'kv-${nameSuffix}'
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' ={
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        permissions: {
          keys: []
          secrets: [
                    'Get'
                    'List'
                  ]
          certificates: [
                        'Get'
                        'List'
                        'create'
                        'import'
                      ]
        }
        tenantId: keyVault.properties.tenantId
      }
    ]
  }
}


output keyVaultName string = keyVault.name
output keyVaultRg string = resourceGroup().id
output keyVaultURI string = keyVault.properties.vaultUri
