rg=$1

if [[  $rg == "" ]]; then
    echo "No resource group specified"
    az deployment sub create -n 'nuke-all' -l eastus -f ./nuke.json --tags project-name=vmss --mode complete
elif [[ $(az group exists -n $rg) == $true]]; then
    echo "Nuking $rg"
    az deployment group create -g $rg -l eastus -f ./nuke.json
else
    az group list --tag project-name=$rg --query [].name -o tsv | xargs -otl az group delete --no-wait -y -n
fi

