# BlueGreen

az deployment group create --resource-group rg-bg --template-file "./bicep/main.bicep" --parameters bgServiceName="bgappservice" blueCommitId="$0b699ef"



--parameters "./bicep/main.parameters.json"
