targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource Id of the container apps environment.')
param containerAppsEnvironmentId string


@description('The name of the service')
param bgServiceName string

@description('The target port for the service.')
param bgPortNumber int

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerUserAssignedManagedIdentityId string

@minLength(1)
@maxLength(64)
@description('CommitId for blue revision')
param blueCommitId string

@maxLength(64)
@description('CommitId for green revision')
param greenCommitId string = ''

@maxLength(64)
@description('CommitId for the latest deployed revision')
param latestCommitId string = ''

@allowed([
  'blue'
  'green'
])
@description('Name of the label that gets 100% of the traffic')
param productionLabel string = 'blue'

var currentCommitId = !empty(latestCommitId) ? latestCommitId : blueCommitId

//use a preexisting container image in a preexisting container registry
var buildbg = {
  outputs: {
    acrImage: 'acrl2vcut6x7hxom.azurecr.io/bgapp:initial'
  }
}

// ------------------
// RESOURCES
// ------------------

resource bgService 'Microsoft.App/containerApps@2023-05-02-preview' = {
  name: bgServiceName
  location: location
  tags: union(tags, {
    containerApp: bgServiceName
    blueCommitId: blueCommitId
    greenCommitId: greenCommitId
    latestCommitId: currentCommitId
    productionLabel: productionLabel
   })
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${containerUserAssignedManagedIdentityId}': {}
    }
  }
  properties:{
    managedEnvironmentId: containerAppsEnvironmentId
    workloadProfileName: 'Consumption'
    configuration: {
      maxInactiveRevisions: 10 // Remove old inactive revisions
      activeRevisionsMode: 'multiple' // Multiple active revisions mode is required when using traffic weights
      ingress: {
        external: true
        targetPort: bgPortNumber
        traffic: !empty(blueCommitId) && !empty(greenCommitId) ? [
          {
            revisionName: '${bgServiceName}--${blueCommitId}'
            label: 'blue'
            weight: productionLabel == 'blue' ? 100 : 0
          }
          {
            revisionName: '${bgServiceName}--${greenCommitId}'
            label: 'green'
            weight: productionLabel == 'green' ? 100 : 0
          }
        ] : [
          {
            revisionName: '${bgServiceName}--${blueCommitId}'
            label: 'blue'
            weight: 100
          }
        ]
      }
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: containerUserAssignedManagedIdentityId
        }
      ] : []
    }
    template: {
      revisionSuffix: currentCommitId
      containers: [
        {
          name: bgServiceName
          image: buildbg.outputs.acrImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'REVISION_COMMIT_ID' //only used for simple test in gh actions
              value: currentCommitId
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output bgServiceContainerAppName string = bgService.name
output fqdn string = bgService.properties.configuration.ingress.fqdn
output latestRevisionName string = bgService.properties.latestRevisionName
