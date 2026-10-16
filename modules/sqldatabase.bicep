// modules/sqldatabase.bicep

@description('The environment name (e.g. dev, stag, prod)')
param environment string

@description('Azure region for the resources')
param location string = resourceGroup().location

@description('Base name for the SQL Server')
param serverName string

@description('Name of the SQL Database')
param databaseName string

@description('Administrator login username for the SQL Server')
param adminUsername string

@description('Administrator login password for the SQL Server')
@secure()
param adminPassword string

@description('SQL Database SKU Name')
param skuName string = 'Basic'

@description('SQL Database Tier')
param skuTier string = 'Basic'

@description('SQL Database Capacity')
param skuCapacity int = 5

@description('Maximum size of the database in bytes')
param maxSizeBytes int = 2147483648

// Common tags including environment
var resourceTags = {
  Environment: environment
  ManagedBy: 'Bicep'
}

// Logical SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  tags: resourceTags
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: resourceTags
  sku: {
    name: skuName
    tier: skuTier
    capacity: skuCapacity
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
  }
}

// Firewall Rule
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Module Outputs
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlServerId string = sqlServer.id
output sqlDatabaseId string = sqlDatabase.id
