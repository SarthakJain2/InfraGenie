function Create-ZipUpload {
    param (
        [string]$ProductID,
        [string]$token,
        [string]$currentlistingids,
        [string]$currentlistingids1,
        [string]$FilesasUri
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packages/$currentlistingids"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
        'If-Match'      = '"$currentlistingids1"'
    }

    $body = @{
        "resourceType" = "AzureApplicationPackage"
        "fileName" = "ama-helloworlds.zip"
        "fileSasUri" = $FilesasUri
        "state" = "Uploaded"
        "@odata.etag" = $currentlistingids1
        "id" = $currentlistingids
      } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}
