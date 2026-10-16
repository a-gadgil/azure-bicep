// environments/dev/main.bicep

param location string = 'eastus'
param environment string = 'dev'

@secure()
param sqlAdminPassword string

// Instantiate SQL Database Module
module sqlDev '../../modules/sqldatabase.bicep' = {
  name: 'sql-dev-deployment'
  params: {
    environment: environment
    location: location
    serverName: 'sql-server-${environment}-001'
    databaseName: 'sqldb-${environment}-001'
    adminUsername: 'sqladminUser'
    adminPassword: sqlAdminPassword
    skuName: 'Basic'
    skuTier: 'Basic'
    skuCapacity: 5
  }
}

output sqlFqdn string = sqlDev.outputs.sqlServerFqdn
