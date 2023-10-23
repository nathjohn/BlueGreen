# BlueGreen

az deployment group create --resource-group rg-bg --template-file "./bicep/main.bicep" --parameters bgServiceName="bgappservice" blueCommitId="e0aa110"

Run
```bash
 git update-index --chmod=+x .\infra\set-params.sh         
``` 
locally to make the bash script executable. Once you commit and push the change to your GitHub repository the script will be allowed to run in your GitHub action.
