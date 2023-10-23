# BlueGreen

az deployment group create --resource-group rg-bg --template-file "./bicep/main.bicep" --parameters bgServiceName="bgappservice" blueCommitId="e0aa110"



--parameters "./bicep/main.parameters.json"
