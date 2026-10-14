@description('Prefix for all resources')
param prefix string

@description('Environment name identifier (e.g., dev, stag, prod)')
param envName string

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Runtime worker stack')
param runtimeWorker string = 'node'

@description('Runtime version')
param runtimeVersion string = '20'

var resourceName = '${prefix}-${envName}-func'
var storageAccountName = '${toLower(prefix)}${toLower(envName)}funcstg'

// 1. Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: length(storageAccountName) > 24 ? substring(storageAccountName, 0, 24) : storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// 2. App Service Plan (Consumption Plan - Y1)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${resourceName}-plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

// 3. Function App
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: resourceName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: '${toUpper(runtimeWorker)}|${runtimeVersion}'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(resourceName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtimeWorker
        }
      ]
    }
    httpsOnly: true
  }
}

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output functionAppHostName string = functionApp.properties.defaultHostName
