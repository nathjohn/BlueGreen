targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {
  solution: 'bluegreen'
  shortName: 'bg'
  iac: 'bicep'
  environment: 'aca'
}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the service')
param bgServiceName string

@description('The target port for the service.')
param bgPortNumber int = 5028

@minLength(1)
@maxLength(64)
@description('CommitId for blue revision')
param blueCommitId string = 'initial'

@maxLength(64)
@description('CommitId for green revision')
param greenCommitId string = ''

@maxLength(64)
@description('CommitId for the latest deployed revision')
param latestCommitId string = ''

@description('Name of the label that gets 100% of the traffic')
param productionLabel string = 'blue'

// ------------------
// VARIABLES
// ------------------

var containerRegistryPullRoleGuid='7f951dda-4ed3-4680-a7ca-43fe172d538d'

// ------------------
// RESOURCES
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: 'acrl2vcut6x7hxom'
  scope: resourceGroup('shared-acr')
}

resource containerUserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'aca-useridentity-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
}


module containerRegistryPullRoleAssignment 'modules/container-reg/acr.bicep' = {
  name: 'acr-role-assignment'
  scope: resourceGroup('shared-acr')
  params: {
    containerRegistryName: containerRegistry.name
    containerRegistryPullRoleGuid: containerRegistryPullRoleGuid
    containerUserAssignedManagedIdentityId: containerUserAssignedManagedIdentity.id
    containerUserAssignedManagedIdentityPrincipalId: containerUserAssignedManagedIdentity.properties.principalId
  }
}

module bgService 'modules/container-apps/bg-service.bicep' = {
  name: 'bg-service-${uniqueString(resourceGroup().id)}'
  params: {
    bgServiceName: bgServiceName
    bgPortNumber: bgPortNumber
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    containerRegistryName: containerRegistry.name
    containerUserAssignedManagedIdentityId: containerUserAssignedManagedIdentity.id
    blueCommitId: blueCommitId
    greenCommitId: greenCommitId
    latestCommitId: latestCommitId
    productionLabel: productionLabel
  }
}
