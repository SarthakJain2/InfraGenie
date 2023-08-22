@description('Always global loaction for SaaS.')
param location string

@description('Set of core tags')
param coreTags object

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Provide a plan Id. e.g - free-100-2022. Free tier provides 100 emails/day')
param planId string = 'free-100-2022'

@description('Give the offerId for sendGrid')
param offerId string = 'tsg-saas-offer'

@description('Provide the publisher ID')
param publisherId string = 'sendgrid'

param quantity int = 1

param termId string = 'gmz7xq9ge3py'

@description('Provide the azure subscription Id for sendGrid')
param azureSubscriptionId string = subscription().subscriptionId

param publisherTestEnvironment string = ''

param autoRenew bool = true

resource name_resource 'Microsoft.SaaS/resources@2018-03-01-beta' = {
  name: 'sg-${nameSuffix}'
  location: location
  tags: coreTags
  properties: {
    saasResourceName: 'sg-${nameSuffix}'
    publisherId: publisherId
    SKUId: planId
    offerId: offerId
    quantity: quantity
    termId: termId
    autoRenew: autoRenew
    paymentChannelType: 'SubscriptionDelegated'
    paymentChannelMetadata: {
      AzureSubscriptionId: azureSubscriptionId
    }
    publisherTestEnvironment: publisherTestEnvironment
    storeFront: 'AzurePortal'
  }
}
