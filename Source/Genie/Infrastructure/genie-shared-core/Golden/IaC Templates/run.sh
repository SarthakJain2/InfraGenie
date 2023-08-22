#!/bin/bash
component=$1
index=$2
purge=$3
rg='rg-poc-dev-eastus-001'
loc='eastus'

if [[ $(az group list --query "[?name=='$rg'] | length(@)") == 0 ]]
then
    az group create --name $rg --location $loc
fi

if [[ $component == "" ]]
then
    component="all"
fi


if [[ $index == "" ]]
then
    index="001"
fi

if [[ $purge == "true" ]]
then
    echo "Purging Key vault... 'kv-poc-dev-$index'"
    az keyvault purge --name kv-poc-dev-$index
fi

echo "Starting to create resources..."
start=$(date +%s)

# Run prerequisites
if [[ $component != "all" ]]
then
    echo "Creating prerequisites..."
    echo "Creating network..."
    az deployment group create -g $rg -f ./network.bicep -p ./network.parameters.json

    echo "Creating Key vault..."
    az deployment group create -g $rg -f ./core-vault.bicep -p ./core-vault.parameters.json

    echo .
    echo "------------------"
fi

if [[ $component == "all" ]] 
then
    az deployment group create -g $rg -f ./main.bicep -p ./main.parameters.json
elif [[ $component == "sql" ]]
then
    echo "Creating Database --------------"
    az deployment group create -g $rg -f ./sql.bicep -p ./sql.parameters.json
elif [[ $component == "win10" ]]
then
    echo "Creating Win 10 Client --------------"
    az deployment group create -g $rg -f ./vm.windows.desktop.bicep -p ./vm.windows.desktop.parameters.json
fi


end=$(date +%s)
echo "Done creating..."
echo "Elapsed Time: $((($end-$start)/60)) minutes"

echo $component