targetScope = 'resourceGroup'

@description('Prefix for resource names')
param prefix string = 'core'

@description('Environment name identifier')
param environment string = 'dev'

@description('Azure region')
param location string = 'eastus'

// Instantiate ONLY the Function App Module
module functionModule '../modules/azure-functions.bicep' = {
  name: 'deploy-function-${environment}'
  params: {
    prefix: prefix
    envName: environment
    location: location
    runtimeWorker: 'node'
    runtimeVersion: '20'
  }
}

// Outputs
output functionAppName string = functionModule.outputs.functionAppName
output functionAppHostName string = functionModule.outputs.functionAppHostName
