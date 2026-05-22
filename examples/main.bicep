// Example: consume the naming module and emit a few sample names.
// Build:  az bicep build --file examples/main.bicep
// Deploy: az deployment group create -g <existing-rg> -f examples/main.bicep

param location string = resourceGroup().location

module naming '../naming.bicep' = {
  name: 'naming'
  params: {
    cloudAcronym: 'azu'
    prefix: 'contoso'
    workload: 'web'
    environment: 'p'
    location: location
    useAzureRegionAbbr: true
  }
}

output sampleResourceGroup string = naming.outputs.resourceGroup
output sampleStorageAccount string = naming.outputs.storageAccount
output sampleKeyVault string = naming.outputs.keyVault
output sampleAks string = naming.outputs.aksCluster
output sampleVnet string = naming.outputs.virtualNetwork
output allNames object = naming.outputs.names
