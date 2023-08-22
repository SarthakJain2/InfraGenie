@description('Specifies the environment this template deploys to')
param env string = 'dev'

@description('Short form of the component this resource is used for')
param component string = 'msv'

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string = 'vm-erwinaz-${component}-${env}-001'
@description('Current timestamp')
param now string = utcNow('u')

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueString(now)}'
  params: {
    env: env
  }
}

var shared = globalConfig.outputs.sharedComponent
var kvName = 'kv-${replace(nameSuffix, component, shared)}'

output vault object = {
  id: resourceId('Microsoft.KeyVault/vaults', kvName)
  name: kvName
  shared: shared

}
