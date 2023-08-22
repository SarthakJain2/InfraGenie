param nameSuffix string
param key string
param value string
param valueObject object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'kv-${nameSuffix}'
}

resource keyName 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: key
  properties: {
    value: (empty(value)) ? string(valueObject) : value
  }
}

output key string = keyName.name
output vaultId string = keyVault.id
