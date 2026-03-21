az deployment group create \
  --resource-group learn-azure-cli \
  --template-file main.bicep \
  --parameters adminUsername=azureuser \
               adminPassword='StrongPassword123!'
