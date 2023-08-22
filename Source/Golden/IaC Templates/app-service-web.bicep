@description('Specifies the location for resources.')
param location string

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffixShort string

@description('Provide the instance Numeber of the ASP Eg: 1')
param capacity int

@description('Provide the SKU for App Service Plan Eg: S3')
@allowed([ 'B1', 'P1V2', 'P1V3', 'P2V2', 'P2V3', 'P3V2', 'P3V3', 'S1', 'S2', 'S3' ])
param skuname string

param linuxFxVersion string

param branch string = 'main'
param repoUrl string = ''

param isPublic bool

@description('Set of core tags')
param coreTags object


module appServicePlan 'app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    nameSuffixshort: nameSuffixShort
    capacity: capacity
    skuname: skuname
    coreTags: coreTags
  }
}

resource webapp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'ase-${nameSuffixShort}'
  location: location
  tags: coreTags
  identity: {
     type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    }
    serverFarmId: appServicePlan.outputs.azureServicePlanId
    publicNetworkAccess: isPublic ? 'Enabled' : 'Disabled'
  }
}

resource webAppSourceControl 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = if(contains(repoUrl,'http')) {
  name: 'web'
  parent: webapp
  properties: {
    repoUrl: repoUrl
    branch: branch
    isManualIntegration: true 
  }
}

