targetScope = 'subscription'

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Policy Display name')
param policyDisplayName string

@description('Give the policy definition')
param definitionDescription string

@description('Policy assignment name')
param policyAssignmentName string

@description('Give the tage which have to be in the policy')
param coreTags object

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'pd-${nameSuffix}'
  properties: {
    displayName: 'Append a tag and its value to resources With coreTags'
    description: definitionDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'Name of the tag, such as "environment"'
        }
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag Value'
          description: 'Value of the tag, such as "production"'
        }
      }
    }
    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
        // equals: '[parameters(\'tagValue\')]'
        exists: false
      }
      then: {
        effect: 'append'
        details: [
          {
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
            value: '[parameters(\'tagValue\')]'
          }
        ]
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = [ for coreTag in items(coreTags): {
  
   name: '${policyAssignmentName}-${coreTag.key}'
    properties: {
    policyDefinitionId: policyDefinition.id
    displayName: policyDisplayName
    parameters: {
      tagName: {
        value: coreTag.value.name
      }
      tagValue: {
        value: coreTag.value.value
      }
    }

  }
} ]
