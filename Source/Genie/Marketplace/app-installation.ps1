. ./download.ps1

. ./extract.ps1

#Download
Download-AzureStorageFiles -ConnectionString $connectionString -ContainerName $containerName -LocalDownloadPath $localDownloadPath

#Extract
Extract-NuGetPackages -LocalDownloadPath $localDownloadPath