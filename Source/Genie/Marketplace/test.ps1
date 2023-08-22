Param (
$containerName = "packages",
$storageAccountName = "stshareddev002",
$source = "https://$storageAccountName.blob.core.windows.net/$containerName",
$destinationPath = "."
)

az storage blob download-batch `
  --account-name $storageAccountName `
  --account-key (az storage account keys list --account-name $storageAccountName --query "[0].value" -o tsv) `
  --source $source `
  --destination $destinationPath

Write-Host -ForegroundColor Green "All files downloaded successfully."
