@description('Specifies the location for resources.')
param location string

param component string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Tags for the network resources.  Must be of type ResourceTags')
param coreTags object

var nsgName = 'nsg-${replace(nameSuffix, '${component}', 'apim')}'
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  tags: coreTags
  properties: {
    securityRules: [
      {
        name: 'Management_endpoint_for_Azure_portal_and_Powershell'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_to_sync_Rate_Limit_Inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 135
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Azure_SQL'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache_outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'Depenedency_To_sync_RateLimit_Outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 165
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Infrastructure_Load_Balancer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 180
          direction: 'Inbound'
        }
      }
      {
        name: 'Publish_DiagnosticLogs_And_Metrics'
        properties: {
          description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 185
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
            '12000'
            '1886'
          ]
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_For_SendingEmails'
        properties: {
          description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
        }
      }
      {
        name: 'Authenticate_To_Azure_Active_Directory'
        properties: {
          description: 'Connect to Azure Active Directory for developer portal authentication or for OAuth 2 flow during any proxy authentication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'APIM service dependency on Azure blob and Azure table storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Publish_Monitoring_Logs'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 300
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_KeyVault'
        properties: {
          description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
          access: 'Allow'
          priority: 350
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
          ]
        }
      }
      {
        name: 'Deny_All_Internet_Outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 999
          direction: 'Outbound'
        }
      }
    ]
  }
}

output nsgId string = networkSecurityGroup.id
output nsgName string = networkSecurityGroup.name
