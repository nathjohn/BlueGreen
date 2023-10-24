# BlueGreen

## Enable sh script to run in GitHub action
Run
```bash
 git update-index --chmod=+x .\infra\set-params.sh         
``` 
locally to make the bash script executable. Once you commit and push the change to your GitHub repository the script will be allowed to run in your GitHub action.

## Create environment and first version of app
```bash
az deployment group create --resource-group <name-of-resource-group> --template-file "./bicep/main.bicep" --parameters firstDeployment=true bgServiceName="bgappservice" 
```

## create spn for resource group access to use in github action
```bash
az ad sp create-for-rbac --name bg123 --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/exampleRG --json-auth
```


Save the output of the above command in a GitHub secret called AZURE_CREDENTIALS in your GitHub repository.

## Github actions
Set the following secrets in your GitHub repository:
* `AZURE_CREDENTIALS` - Azure service principal credentials with permissions to create and manage resources in your subscription and resource group. Refer to [Azure login action with a service principal secret](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret).
Add the following environment variables to your GitHub repository:
* `AZURE_ENVIRONMENT_NAME` - the short name of the existing Azure Container Apps environment where the sample app will be deployed to, for example `mycontainerappenv`. Do not use the full environment ARM resource id.
* `AZURE_RG` - the name of the existing Azure resource group where the sample app will be deployed to.
* `AZURE_APP_NAME` - the name of the containerapp where the sample app will be deployed to.
* `AZURE_APP_DNSSUFFIX` - the default domain of the containerapp environment where the sample app will be deployed to, for example `whitedesert-078f44c6.<region>.azurecontainerapps.io`. You can use this command to get it:

```bash
az containerapp env show -g <name-of-resource-group> -n <name-of-containerapps-environment> --query properties.defaultDomain
```


