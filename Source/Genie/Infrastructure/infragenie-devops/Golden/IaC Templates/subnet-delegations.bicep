param delegations array
output delegations array = [for delegation in delegations: {
  name: delegation.name
  properties: {
    serviceName: delegation.serviceName
  }
}]
