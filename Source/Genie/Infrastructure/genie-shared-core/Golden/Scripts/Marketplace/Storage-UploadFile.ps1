$parameterPath = ".\storage.parameter.json"
function Upload-FilesToBlobStorage {
    param (
        [string]$ParameterPath,
        [string]$StorageAccountName,
        [string]$StorageAccountKey,
        [string]$ContainerName
    )

    $jsonContent = Get-Content -Path $ParameterPath -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json

    $localDirectoryPath = $jsonObject.localDirectoryPath
    $storageAccountName = $jsonObject.storageAccountName
    $storageAccountKey = $jsonObject.storageAccountKey
    $containerName = $jsonObject.containerName

    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    Get-ChildItem -Path $localDirectoryPath -File -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($localDirectoryPath.Length)
        $blobName = $relativePath -replace '\\', '/'
        Set-AzStorageBlobContent -Container $ContainerName -File $_.FullName -Blob $blobName -Context $storageContext -Force
    }
}
Upload-FilesToBlobStorage -ParameterPath $parameterPath -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -ContainerName $containerName


