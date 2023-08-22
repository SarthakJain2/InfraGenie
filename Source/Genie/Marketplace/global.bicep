@allowed([
  'dev'
  'sbx'
  'qa'
  'uat'
  'prod'
])
param env string

var settings = {
  sqlServerDnsZoneNameFormat: 'privatelink${environment().suffixes.sqlServerHostname}'
  keyVaultDnsZoneNameFormat: 'privatelink.vaultcore.azure.net' //'privatelink.{0}${environment().suffixes.keyvaultDns}'
  storageAccountBolbDnsZoneFormat: 'privatelink.blob.${environment().suffixes.storage}'
  containerRegistryDnsZoneNameFormat: 'privatelink${environment().suffixes.acrLoginServer}'
  serviceBusDnsZoneNameFormat: 'privatelink.servicebus.windows.net'
  cognitiveServicesDnsZoneFormat: 'privatelink.cognitiveservices.azure.com'
  dataFactoryDnsZoneFormat: 'privatelink.datafactory.azure.net'
  synapseSqlDnsZoneFormat: 'privatelink.sql.azuresynapse.net'
  synapseDevDnsZoneFormat: 'privatelink.dev.azuresynapse.net'
  synapseWebDnsZoneFormat: 'privatelink.azuresynapse.net'
  adfWebDnsZoneFormat: 'privatelink.azuresynapse.net'
  dataLakeDnsZoneNameFormat: 'https://{0}.dfs.${environment().suffixes.storage}'
  apimDnsZoneNameFormat: 'privatelink.azure-api.net'
  apimDeveloperDnsNameFormat: 'privatelink.developer.azure-api.net'
  appServiceDnsNameFormat: 'privatelink.azurewebsites.net'
  aksDnsZoneNameFormat: 'privatelink.{0}.azmk8s.io'
  sharedKeyVaultNameFormat: 'kv-{0}-shrd-{1}-{2}'
  nameSuffixFormat: '{0}-{1}-{2}-{3}'
  nameSuffixShortFormat: '{0}-{1}-{2}'
  nameSuffixShortGalleryFormat: '{0}_{1}_{2}'
  hyphenlessNameShortFormat: '{0}{1}{2}'
  hyphenlessNameFormat: '{0}{1}{2}{3}'
  sharedComponent: 'shrd'
  vmssComponent: 'vmss'
  keyVaultComponent: 'kv'
  storageAccountComponent: 'st'
  containerRegistryComponent: 'cr'
  serviceBusComponent: 'sb'
  dbComponent: 'db'
  bastionComponent: 'bas'
  appServiceWebComponent: 'web'
  appServiceCliComponent: 'cli'
  marketplaceComponent: 'mp'

  dev: {
    isPublic: false
  }
  sbx: {
    isPublic: false
  }
  qa: {
    isPublic: false
  }
  uat: {
    isPublic: false
  }
  prod: {
    isPublic: false
  }
}

output isPublic bool = settings[env].isPublic
output sharedKeyVaultNameFormat string = settings.sharedKeyVaultNameFormat

output nameSuffixFormat string = settings.nameSuffixFormat
output nameSuffixShortFormat string = settings.nameSuffixShortFormat
output nameSuffixShortGalleryFormat string = settings.nameSuffixShortGalleryFormat

//Components
output sharedComponent string = settings.sharedComponent
output serviceBusComponent string = settings.serviceBusComponent
output dbComponent string = settings.dbComponent
output vmssComponent string = settings.vmssComponent
output keyVaultComponent string = settings.keyVaultComponent
output storageAccountComponent string = settings.storageAccountComponent
output containerRegistryComponent string = settings.containerRegistryComponent
output bastionComponent string = settings.bastionComponent
output appServiceWebComponent string = settings.appServiceWebComponent
output appServiceCliComponent string = settings.appServiceCliComponent
output marketplaceComponent string = settings.marketplaceComponent

//Private DNS Zone Name
output dataLakeDnsZoneNameFormat string = settings.dataLakeDnsZoneNameFormat
output sqlServerDnsZoneNameFormat string = settings.sqlServerDnsZoneNameFormat
output keyVaultDnsZoneNameFormat string = settings.keyVaultDnsZoneNameFormat
output storageAccountBolbDnsZoneFormat string = settings.storageAccountBolbDnsZoneFormat
output containerRegistryDnsZoneNameFormat string = settings.containerRegistryDnsZoneNameFormat
output synapseSqlDnsZoneNameFormat string = settings.synapseSqlDnsZoneFormat
output synapseDevDnsZoneNameFormat string = settings.synapseDevDnsZoneFormat
output synapseWebDnsZoneNameFormat string = settings.synapseWebDnsZoneFormat
output adfWebDnsZoneNameFormat string = settings.adfWebDnsZoneFormat
output serviceBusDnsZoneNameFormat string = settings.serviceBusDnsZoneNameFormat
output cognitiveServicesDnsZoneFormat string = settings.cognitiveServicesDnsZoneFormat
output dataFactoryServicesDnsZoneFormat string = settings.dataFactoryDnsZoneFormat
output apimDnsZoneNameFormat string = settings.apimDnsZoneNameFormat
output aksDnsZoneNameFormat string = settings.aksDnsZoneNameFormat
output appServiceDnsZoneNameFormat string = settings.appServiceDnsNameFormat

output hyphenlessNameShortFormat string = settings.hyphenlessNameShortFormat
output hyphenlessNameFormat string = settings.hyphenlessNameFormat
