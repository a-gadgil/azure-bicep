targetScope = 'resourceGroup'

@description('Prefix for resource names')
param prefix string = 'core'

@description('Environment name identifier')
param environment string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

// 1. Networking Module
module networkingModule '../modules/networking.bicep' = {
  name: 'deploy-networking-${environment}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// 2. Storage Module
module storageModule '../modules/storage.bicep' = {
  name: 'deploy-storage-${environment}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// 3. Compute Module
module computeModule '../modules/compute.bicep' = {
  name: 'deploy-compute-${environment}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// 4. Key Vault Module
module keyvaultModule '../modules/keyvault.bicep' = {
  name: 'deploy-keyvault-${environment}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// 5. ACR Module
module acrModule '../modules/acr.bicep' = {
  name: 'deploy-acr-${environment}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// 6. Function App Module
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
output functionAppHostName string = functionModule.outputs.functionAppHostName
