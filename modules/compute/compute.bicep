@description('Prefix for all compute resources.')
param namePrefix string

@description('Azure region for deployment.')
param location string = resourceGroup().location

@description('Subnet ID where the VM Network Interface will be attached.')
param subnetId string

@description('Admin username for the Virtual Machine.')
param adminUsername string = 'azureuser'

@description('SSH Public Key for secure authentication.')
@secure()
param adminPublicKey string

@description('Virtual machine size.')
param vmSize string = 'Standard_B2s'

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${namePrefix}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: '${namePrefix}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 30
      }
    }
    osProfile: {
      computerName: '${namePrefix}-vm'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

@description('The resource ID of the deployed Virtual Machine.')
output vmId string = vm.id

@description('The private IP address of the Virtual Machine.')
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
