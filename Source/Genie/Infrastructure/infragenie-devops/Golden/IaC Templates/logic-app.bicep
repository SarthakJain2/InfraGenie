@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixshort string

@description('Set of core tags')
param coreTags object

param testUri string = 'https://status.azure.com/en-us/status/'

var workflowSchema = 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'

var frequency = 'Hour'
var interval = '1'
var type = 'recurrence'
var actionType = 'http'
var method = 'GET'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-${nameSuffixshort}'
  location: location
  tags: coreTags
  properties: {
    definition: {
      '$schema': workflowSchema
      contentVersion: '1.0.0.0'
      parameters: {
        testUri: {
          type: 'string'
          defaultValue: testUri
        }
      }
      triggers: {
        recurrence: {
          type: type
          recurrence: {
            frequency: frequency
            interval: interval
          }
        }
      }
      actions: {
        actionType: {
          type: actionType
          inputs: {
            method: method
            uri: testUri
          }
        }
      }
    }
  }
}
