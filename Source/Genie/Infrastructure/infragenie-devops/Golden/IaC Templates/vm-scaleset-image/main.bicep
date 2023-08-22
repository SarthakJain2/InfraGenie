targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Specifies the environment this template deploys to')
param env string

@description('Current Project Name')
param projectName string

@description('Set of core tags')
param coreTags object

@description('Provide the name of the VM For Image Gallery')
param galleryVmName string

@description('Provide the name of the VM For Image Gallery')
param galleryVmRG string

@description('Provide the type of the VM being added')
param galleryVmType string

@description('Identrify the SKU of the VM')
param galleryVmSku object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

param indexOverride string = ''

// Compute current index
var rg = resourceGroup().name
var idx = lastIndexOf(rg, '-')
var nextIndex = (idx > 0) ? int(substring(rg, idx + 1)) : 1
var index = (indexOverride == '') ? padLeft(nextIndex, 3, '0') : indexOverride

module globalConfig 'global.bicep' = {
  name: 'configModule${uniqueStr}'
  params: {
    env: env
  }
}

module imageGallery 'image-gallery.bicep' = {
  name: 'imagegallery'
  params: {
    galleryVmName: galleryVmName
    galleryVmRG: galleryVmRG
    galleryVmType: galleryVmType
    galleryVmSku: galleryVmSku
    location: location
    nameSuffixShortGallery: format(globalConfig.outputs.nameSuffixShortGalleryFormat, projectName, env, index)
    imageVersionName: '1.0.0'
    coreTags: coreTags    
  }
}

output imageName string = imageGallery.outputs.imageName
output imageVersionId string = imageGallery.outputs.imageVersionId
