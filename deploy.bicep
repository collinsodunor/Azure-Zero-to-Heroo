az group create --name learn-azure-cli --location eastus && \
az deployment group create \
  --resource-group learn-azure-cli \
  --template-file main.bicep \
  --parameters adminUsername=azureuser adminPassword='StrongPassword123!'
