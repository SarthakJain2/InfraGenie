@description('Provide a  name suffix per CAF.  Ignore the resource type prefix')
param nameSuffix string

@description('Provide a name of the ssl Certificate')
param certName string

@secure()
@description('The base64 encoded SSL certificate in PFX format to be stored in Key Vault. CN and SAN must match the custom hostname of API Management Service.')
param sslCertValue string

@secure()
@description('The password for the PFX file.')
param sslCertPassword string

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: 'kv-${nameSuffix}'
}
resource keyVaultCert 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: certName
  parent: keyVault
  properties: {
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
    }
    value: sslCertValue
  }
}

output certUri string = keyVaultCert.properties.secretUriWithVersion
output certName string = keyVaultCert.name
