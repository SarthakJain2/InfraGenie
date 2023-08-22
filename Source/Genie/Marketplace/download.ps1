function Download-AzureStorageFiles {
    param (
        [string]$ConnectionString,
        [string]$ContainerName,
        [string]$LocalDownloadPath
    )

    $context = New-AzStorageContext -ConnectionString $ConnectionString

    $blobs = Get-AzStorageBlob -Container $ContainerName -Context $context

    
    if (-Not (Test-Path $LocalDownloadPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $LocalDownloadPath
    }

    foreach ($blob in $blobs) {
        $blobName = $blob.Name
        $localFilePath = Join-Path -Path $LocalDownloadPath -ChildPath $blobName
        Get-AzStorageBlobContent -Blob $blobName -Container $ContainerName -Context $context -Destination $localFilePath -Force
        Write-Host "Downloaded: $blobName"
    }

    Write-Host "All files downloaded successfully."
}

$connectionString = "DefaultEndpointsProtocol=https;AccountName=stshareddev002;AccountKey=a4TLllX0ImlEYzgpp64s7jzu9I/DmP0d7rgtdPW5WDclRAeXNr8OuZZr1Di9ZDKlwpXj51Ihv8Vf+AStrBI+wA==;EndpointSuffix=core.windows.net"
$containerName = "packages"
$localDownloadPath = ".\newFiles"

Download-AzureStorageFiles -ConnectionString $connectionString -ContainerName $containerName -LocalDownloadPath $localDownloadPath
