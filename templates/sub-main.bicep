targetScope = 'subscription'

param location string = 'centralindia'
param rgName string
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
  tags: tags
}

output rgId string = rg.id
