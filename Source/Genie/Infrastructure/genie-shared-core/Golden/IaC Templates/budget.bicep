targetScope = 'resourceGroup'

@description('Provide a name suffix per CAF.  Ignore the vm- prefix')
param nameSuffix string

@description('Start date')
param startDate string

@description('End date')
param endDate string

@description('Set total amount')
param amount int = 2000

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param firstThreshold int = 90

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param secondThreshold int = 110

@description('Contact Email')
param contactEmails array

resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: 'budget-${nameSuffix}'
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: 'Monthly'
    category: 'Cost'
    amount: amount
    notifications: {
      NotificationForExceededBudget1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: firstThreshold
        contactEmails: contactEmails
      }
      NotificationForExceedecBudget2: {
        enabled: true
        operator: 'GreaterThan'
        threshold: secondThreshold
        contactEmails: contactEmails
        thresholdType: 'Forecasted'
      }
    }
  }

}
