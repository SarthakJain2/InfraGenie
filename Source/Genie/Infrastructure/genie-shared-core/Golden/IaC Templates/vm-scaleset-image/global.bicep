@allowed([
  'dev'
  'sbx'
])
param env string

var settings = {
  sqlServerDnsZoneNameFormat: 'privatelink${environment().suffixes.sqlServerHostname}'
  keyVaultDnsZoneNameFormat: 'privatelink.vaultcore.azure.net' //'privatelink.{0}${environment().suffixes.keyvaultDns}'
  storageAccountBolbDnsZoneFormat: 'privatelink.blob.${environment().suffixes.storage}'
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

  dev: {
    isPublic: false
  }
  sbx: {
    isPublic: false
  }  
}

output isPublic bool = settings[env].isPublic
output sharedKeyVaultNameFormat string = settings.sharedKeyVaultNameFormat

output nameSuffixFormat string = settings.nameSuffixFormat
output nameSuffixShortFormat string = settings.nameSuffixShortFormat
output nameSuffixShortGalleryFormat string = settings.nameSuffixShortGalleryFormat

output sharedComponent string = settings.sharedComponent
output vmssComponent string = settings.vmssComponent
output keyVaultComponent string = settings.keyVaultComponent
output storageAccountComponent string = settings.storageAccountComponent
output containerRegistryComponent string = settings.containerRegistryComponent

output sqlServerDnsZoneNameFormat string = settings.sqlServerDnsZoneNameFormat
output keyVaultDnsZoneNameFormat string = settings.keyVaultDnsZoneNameFormat
output storageAccountBolbDnsZoneFormat string = settings.storageAccountBolbDnsZoneFormat

output hyphenlessNameShortFormat string = settings.hyphenlessNameShortFormat
output hyphenlessNameFormat string = settings.hyphenlessNameFormat



