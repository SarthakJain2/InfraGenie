targetScope = 'resourceGroup'
@description('Provide a short name suffix per CAF.  Ignore the prefix')
param nameSuffixShortGallery string
@description('The location of Private gallery resource')
param location string
@description('Set of core tags')
param coreTags object
@description('Provide the name of the VM For Image Gallery')
param galleryVmName string
@description('Provide the name of the RG where VM is stored')
param galleryVmRG string
@description('Provide the type of the VM being added')
param galleryVmType string
@description('Identrify the SKU of the VM')
param galleryVmSku object
param imageVersionName string
param osState string = 'Generalized'
resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' existing = {
  name: galleryVmName
  scope: resourceGroup(galleryVmRG)
}
resource imageGallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: 'gal_${nameSuffixShortGallery}'
  location: location
  tags: coreTags
}
resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  parent: imageGallery
  name: 'gal_def_${nameSuffixShortGallery}'
  location: location
  tags: coreTags
  properties: {
    osType: galleryVmType
    osState: osState
    identifier: galleryVmSku
    recommended: {
      vCPUs: {
        min: 2
        max: 8
      }
      memory: {
        min: 16
        max: 32
      }
    }
    hyperVGeneration: 'V1'
  }
}
resource imageVersion 'Microsoft.Compute/galleries/images/versions@2022-03-03' = {
  parent: imageDefinition
  name: imageVersionName
  location: location
  tags: coreTags
  properties: {
    safetyProfile: {
      allowDeletionOfReplicatedLocations: false
    }
    storageProfile: {
      source: {
        id: vm.id
      }
    }
    publishingProfile: {
      excludeFromLatest: false
      replicaCount: 1
      storageAccountType: 'Standard_LRS'
    }
  }
}
output imageName string = imageDefinition.name
output imageVersionId string = imageVersion.id
