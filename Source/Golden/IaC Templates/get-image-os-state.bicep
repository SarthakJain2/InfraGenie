param imageReferenceId string

var subStartIdx = (indexOf(imageReferenceId, '/subscriptions/') + length('/subscriptions/'))
var subEndIdx = indexOf(imageReferenceId, '/resourceGroups') - subStartIdx
var subscriptionId = empty(imageReferenceId) ? subscription().subscriptionId : substring(imageReferenceId, subStartIdx, subEndIdx)

var startGalIdx = indexOf(imageReferenceId, '/galleries/') + length('/galleries/')
var endGalIdx = indexOf(imageReferenceId, '/images') - startGalIdx
var gallery = substring(imageReferenceId, startGalIdx, endGalIdx)

var startDefIdx = indexOf(imageReferenceId, '/images/') + length('/images/')
var endDefIdx = indexOf(imageReferenceId, '/versions') - startDefIdx
var definition = substring(imageReferenceId, startDefIdx, endDefIdx)

var startIdx = (indexOf(imageReferenceId, '/resourceGroups/') + length('/resourceGroups/'))
var endIdx = indexOf(imageReferenceId, '/providers') - startIdx
var rg = substring(imageReferenceId, startIdx, endIdx)

resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' existing = {
  name: '${gallery}/${definition}'
  scope: resourceGroup(subscriptionId, rg)
}

output subscriptionId string = subscriptionId
output rg string = rg
output gallery string = gallery
output defnition string = definition
output osState string = imageDefinition.properties.osState
