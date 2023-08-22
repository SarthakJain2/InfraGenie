@description('Specifies the location for resources.')
@allowed([ 'centralus', 'eastus2', 'eastasia', 'westeurope', 'westus2' ])
param location string

@description('Give the static web name')
param name string

@description('Set of core tags')
param coreTags object

@description('Provide the SKU for static web app')
@allowed ([ 'Free', 'Standard' ])
param sku string 

@description('Path of the app artifacts (located)')
param appArtifactLocation string

@description('URL for the repository of the static site. E.g https://github.com/reponame')
param repositoryUrl string

@description('The target branch in the repository')
param branch string

@description('Github repository token')
param repositoryToken string

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: 'stapp-${name}'
  location: location
  tags: coreTags
  sku: {
    name: sku
  }
  properties: {
    buildProperties: {
      appArtifactLocation: appArtifactLocation
    }
    repositoryUrl: repositoryUrl
    branch: branch
    repositoryToken: repositoryToken
  } 
}

output siteName string = staticWebApp.id
output siteUrl string = staticWebApp.properties.defaultHostname
