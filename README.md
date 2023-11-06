[![Blue-Green Deployment](https://github.com/mbn-ms-dk/BlueGreen/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mbn-ms-dk/BlueGreen/actions/workflows/ci.yml)

# BlueGreen 
[Blue-Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html) is a software release strategy that aims to minimize downtime and reduce the risk associated with deploying new versions of an application. In a blue-green deployment, two identical environments, referred to as "blue" and "green," are set up. One environment (blue) is running the current application version and one environment (green) is running the new application version.

Once green environment is tested, the live traffic is directed to it, and the blue environment is used to deploy a new application version during next deployment cycle.

| Revision | Description |
| -------- | -------- |
| **Blue** revision | The revision labeled as blue is the currently running and stable version of the application. This revision is the one that users interact with, and it's the target of production traffic. |
| **Green** revision | The revision labeled as green is a copy of the blue revision except it uses a newer version of the app code and possibly new set of environment variables. It doesn't receive any production traffic initially but is accessible via a labeled fully qualified domain name (FQDN). |

After you test and verify the new revision, you can then point production traffic to the new revision. If you encounter issues, you can easily roll back to the previous version.

| Actions | Description |
| -------- | -------- |
| Testing and verification | The **green** revision is thoroughly tested and verified to ensure that the new version of the application functions as expected. This testing might involve various tasks, including functional tests, performance tests, and compatibility checks. |
| Traffic switch | Once the **green** revision is tested and verified, you can switch the traffic from the **blue** revision to the **green** revision. |
| Rollback | If you encounter issues with the **green** revision, you can easily roll back to the **blue** revision. |
| Role Change | The roles of the **blue** and **green** revisions change after a successful deployment to the **green** revision. During the next release cycle, the **green** revision represents the stable production environment while the new version of the application code is deployed and tested in the **blue** revision. |

## Create environment 
Create a resource group for the environment. The following will create a new resource group in the `northeurope` region.
```bash	
az group create --name <name-of-resource-group> --location northeurope
```

Then use the following to create a new Azure ContainerApps enironment as well as a new Azure Container Registry. It will also deploy an initial version of the sample app to the environment.

```bash
az deployment group create --resource-group <name-of-resource-group> --template-file "./bicep/deploy-infra.bicep" 
```

## create spn for resource group access to use in github action

Create service principal to connect your Github to Azure. This will create a new service principal with owner role on the resource group. The service principal will be used by the GitHub action to deploy the sample app to the Azure ContainerApps environment.

```bash
az ad sp create-for-rbac --name <name-of-spn> --role owner --scopes /subscriptions/{subscription-id}/resourceGroups/exampleRG --json-auth
```
Save the output of the above command in a GitHub secret called `AZURE_CREDENTIALS` in your GitHub repository.



## Github actions

The values from the `az deployment group create` command can be retrieved from the Azure portal or CLI and added.

Set the following secrets in your GitHub repository:
* `AZURE_CREDENTIALS` - Azure service principal credentials with permissions to create and manage resources in your subscription and resource group. Refer to [Azure login action with a service principal secret](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret).
Add the following environment variables to your GitHub repository:
* `AZURE_ENVIRONMENT_NAME` - the short name of the existing Azure Container Apps environment where the sample app will be deployed to, for example `mycontainerappenv`. Do not use the full environment ARM resource id.
* `AZURE_ACR_NAME` - the short name of the existing Azure Container Registry where the sample app will be deployed from, for example `mycontainerregistry`. Do not use the full registry ARM resource id.
* `AZURE_RG` - the name of the existing Azure resource group where the sample app will be deployed to.
* `AZURE_APP_NAME` - the name of the containerapp where the sample app will be deployed to.
* `AZURE_APP_DNSSUFFIX` - the default domain of the containerapp environment where the sample app will be deployed to, for example `whitedesert-078f44c6.<region>.azurecontainerapps.io`. You can use this command to get it:

```bash
az containerapp env show -g <name-of-resource-group> -n <name-of-containerapps-environment> --query properties.defaultDomain
```

## set params script for github actions

This script id called from the GitHub action.

The script `.\infra\set-params.sh` is used to set the blue and green deployments.

### Enable sh script to run in GitHub action
Run
```bash
git update-index --chmod=+x .\infra\set-params.sh         
``` 
locally to make the bash script executable. Once you commit and push the change to your GitHub repository the script will be allowed to run in your GitHub action.

Make changes to the sample app and push the code. When you create a PR an merge it to main branch the GitHub action will run and deploy the sample app to the Azure ContainerApps environment.