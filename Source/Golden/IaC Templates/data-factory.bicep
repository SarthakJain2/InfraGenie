@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixshort string

@description('Set of core tags')
param coreTags object

param containerName string

@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param hypenlessNameSuffix string

var dataFactoryDataSetInName = 'adf-dataSetIn'
var dataFactoryDataSetOutName = 'adf-dateSetOut'
var pipelineName = 'adf-pipeline'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: 'st${hypenlessNameSuffix}'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
   name: '${storageAccount.name}/default/${containerName}'
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf-${nameSuffixshort}'
  location: location
  tags: coreTags
  identity: {
    type: 'SystemAssigned'
  }
}

resource dataFactoryLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'adfls-${nameSuffixshort}'
  parent: dataFactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
    }
  }
}

resource dataSetIn 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: dataFactoryDataSetInName
  parent: dataFactory 
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedService.name
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: containerName
        folderPath: 'Input'
        fileName: 'emp.txt'
      }
    }
  }
}

resource dataSetOut 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: dataFactoryDataSetOutName
  parent: dataFactory
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedService.name
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: containerName
        folderPath: 'Output'
      }
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: pipelineName
  parent: dataFactory
  properties: {
    activities: [
      {
        name: 'MyCopyActivity'
        type: 'Copy'
        typeProperties: {
          source:{
            type: 'BinarySource'
            storeSettings: {
              type: 'AzureBlobStorageReadSettings'
              recursive: true
            }
          }
          sink: {
            type: 'BinarySink'
            storeSettings: {
              type: 'AzureBlobStorageWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: dataSetIn.name
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: dataSetOut.name
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
