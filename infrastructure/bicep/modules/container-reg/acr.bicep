param containerUserAssignedManagedIdentityId string
param containerUserAssignedManagedIdentityPrincipalId string
param containerRegistryName string
param containerRegistryPullRoleGuid string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: containerRegistryName
}

resource containerRegistryPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(containerRegistry.name)) {
  scope: containerRegistry
  name: guid(subscription().id, containerRegistry.id, containerUserAssignedManagedIdentityId)
  properties: {
    principalId: containerUserAssignedManagedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}
