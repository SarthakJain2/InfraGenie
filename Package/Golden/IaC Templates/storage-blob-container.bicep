param storageAccountName string
param containerName string
param blobName string

resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccountName}/${blobName}/${containerName}'

}
