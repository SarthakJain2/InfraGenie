param(
  [string] $TenantId,
  [string] $SubscriptionName,
  [string] $KeyVaultName,
  [string] $KeyVaultRg,
  [string] $CertficateName,
  [String] $fileName = "..\.ssl-certificates\rhipheus.cloud.pfx",
  [string] $Password
)

Write-Host "Selecting '$SubscriptionName'"
az account set --subscription "$SubscriptionName"

Write-Host "Updating network policies"
az keyvault update --name $KeyVaultName --default-action allow --resource-group $KeyVaultRg

Write-Host "Allowing public access"
az keyvault update --name $KeyVaultName --public-network-access 'enabled' --resource-group $KeyVaultRg

Write-Host "Updating network policies to deny public access"
az keyvault update --name $KeyVaultName --default-action deny --resource-group $KeyVaultRg

Write-Host "Importing certificate"
$certificate = $(az keyvault certificate import --vault-name $KeyVaultName --name $CertficateName -f $fileName --password $Password)
Write-Host "Certificate ID: $($certificate.id)"