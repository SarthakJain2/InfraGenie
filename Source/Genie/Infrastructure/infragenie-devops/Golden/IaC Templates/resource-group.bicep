targetScope='subscription'

@description('Provide a short name suffix per CAF.  Ignore the bastion- prefix')
param nameSuffixShort string

@description('Give the Location')
param location string

resource rgFirst 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${nameSuffixShort}'
  location: location
  properties: {}
}


