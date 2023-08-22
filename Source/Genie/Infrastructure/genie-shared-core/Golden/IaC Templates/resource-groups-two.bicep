targetScope='subscription'

@description('Provide a short name suffix per CAF.  Ignore the bastion- prefix')
param nameSuffixShort string

@description('Give the Location')
param location string


resource rgFirst 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-first-${nameSuffixShort}'
  location: location
  properties: {}
}

resource rgSecond 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-second-${nameSuffixShort}'
  location: location
  properties: {}
}

