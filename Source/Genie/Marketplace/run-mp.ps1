Param (
    [string] $ResourceGroupName = 'rg-mp-dev-002',
    [string] $Env = 'prod',
    [string] $NetworkingType = 'isolated'
)

$deploymentName = "Marketplace-$(Get-Date -f 'yyyyMMddhhmmss')"
az deployment group create --name $deploymentName -g $ResourceGroupName -f ./marketplace.bicep -p "marketplace.parameters.json" --query "properties.outputs" --output tsv