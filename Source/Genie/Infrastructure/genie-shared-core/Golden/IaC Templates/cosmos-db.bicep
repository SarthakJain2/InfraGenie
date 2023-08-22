@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Set of core tags')
param coreTags object

@description('A unique string')
param uniqueStr string = uniqueString(newGuid())

// @description('Autoscale throughput for the container')
// @minValue(1000)
// @maxValue(1000000)
// param maxThroughput int = 1000

@description('Provide a short name suffix per CAF.  Ignore the kv- prefix')
param nameSuffixShort string

param existingNetworkId string = ''

@description('The name of the subnet')
param subnetName string

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

module switchVnets './vnet-switcher.bicep' = {
  name: 'switchVnets-${uniqueStr}'
  params: {
     nameSuffixShort: nameSuffixShort
     subnetName: subnetName
     existingNetworkId: existingNetworkId
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: 'cosmos-${nameSuffixShort}'
  location: location
  tags: coreTags
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: locations
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
       {
         id: switchVnets.outputs.subnetId
         ignoreMissingVNetServiceEndpoint: true
       }
    ]    
  }
}

// resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
//   name: 'database-${nameSuffixShort}'
//   parent: cosmosDb
//   properties: {
//     resource: {
//       id: 'database-${nameSuffixShort}'
//     }
//   }
// }

// resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = {
//   name: 'container-${nameSuffixShort}'
//   parent: database
//   properties: {
//     resource: {
//       id: 'container-${nameSuffixShort}'
//       partitionKey: {
//         paths: [
//           '/myPartitionKey'
//         ]
//         kind: 'Hash'
//       }
//       indexingPolicy: {
//         indexingMode: 'consistent'
//         includedPaths: [
//           {
//             path: '/*'
//           }
//         ]
//         excludedPaths: [
//           {
//             path: '/myPathToNotIndex/*'
//           }  
//           {
//             path: '/_etag/?'
//           }
//         ]
//         compositeIndexes: [
//           [
//             {
//               path: '/name'
//               order: 'ascending'
//             }
//             {
//               path: '/age'
//               order: 'descending'
//             }
//           ]
//         ]
//         spatialIndexes: [
//           {
//             path: '/path/to/geojson/property/?'
//             types: [
//               'Point'
//               'Polygon'
//               'MultiPolygon'
//               'LineString'
//             ]
//           }
//         ]
//       }
//       defaultTtl: 86400
//       uniqueKeyPolicy: {
//         uniqueKeys: [
//           {
//             paths:[
//               '/phoneNumber'
//             ]
//           }
//         ]
//       }
//     }
//     options: {
//       autoscaleSettings: {
//         maxThroughput: maxThroughput
//       }
//     }
//   }
// }
