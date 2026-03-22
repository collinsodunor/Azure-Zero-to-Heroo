param location string = 'eastus'
param vmName string = 'myUbuntuSpotVM'
param adminUsername string

@secure()
param adminPassword string // NEW: password for login

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: 'myVnet'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [ { name: 'default', properties: { addressPrefix: '10.0.0.0/24' } } ]
  }
}

// NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Public IP
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: 'myPublicIP'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: 'myNIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'default') }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIP.id }
        }
      }
    ]
    networkSecurityGroup: { id: nsg.id }
  }
}

// Spot Virtual Machine with password login
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B2als_v2' }
    priority: 'Spot'
    evictionPolicy: 'Deallocate'
    billingProfile: { maxPrice: -1 }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword 
      linuxConfiguration: {
        disablePasswordAuthentication: false 
      }
    }
    storageProfile: {
  imageReference: {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }

  osDisk: {
    createOption: 'FromImage'
    managedDisk: {
      storageAccountType: 'Standard_LRS'
    }
  }
}

    networkProfile: { networkInterfaces: [ { id: nic.id } ] }
  }
}
