param containerUserAssignedManagedIdentityId string
param containerUserAssignedManagedIdentityPrincipalId string
param containerRegistryPullRoleGuid string
param containerRegistryName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: 'acrl2vcut6x7hxom'
}

resource containerRegistryPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(containerRegistryName)) {
  scope: containerRegistry
  name: guid(subscription().id, containerRegistry.id, containerUserAssignedManagedIdentityId)
  properties: {
    principalId: containerUserAssignedManagedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}
