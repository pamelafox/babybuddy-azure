targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name to prefix all resources')
param name string = 'babybuddy'

@minLength(1)
@description('Primary location for all resources')
param location string = 'eastus'

@description('Home IP address')
param homeIP string

@secure()
param databasePassword string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-resource-group'
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    name: name
    location: location
    homeIP: homeIP
    databasePassword: databasePassword
  }
}

output webUrl string = resources.outputs.webUrl
