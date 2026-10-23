targetScope = 'resourceGroup'

@description('Environment name.')
param environmentName string = 'dev'

@description('Azure region for resources.')
param location string = resourceGroup().location

@description('Admin username for the VM.')
param adminUsername string = 'azureuser'

@description('SSH Public Key for secure authentication.')
@secure()
param adminPublicKey string

// 1. Supporting Networking for Dev (VNet & Subnet)
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${environmentName}-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-compute'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
}

// 2. Consume the Compute Module
module computeModule '../../modules/compute/compute.bicep' = {
  name: 'deploy-compute-${environmentName}'
  params: {
    namePrefix: 'app-${environmentName}'
    location: location
    subnetId: vnet.properties.subnets[0].id
    adminUsername: adminUsername
    adminPublicKey: adminPublicKey
    vmSize: 'Standard_B2s'
  }
}

@description('Output the deployed VM ID from the compute module.')
output devVmId string = computeModule.outputs.vmId

@description('Output the private IP address of the VM.')
output devVmPrivateIp string = computeModule.outputs.privateIpAddress
