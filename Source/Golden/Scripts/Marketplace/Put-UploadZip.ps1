function Create-ZipUpload {
    param (
        [string]$ProductId,
        [string]$AccessToken,
        [string]$putzipIDs,
        [string]$putzipetagIDs,
        [string]$posturizip,
        [string]$FileName
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packages/$putzipIDs"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
        'If-Match'      = '"$putzipetagIDs"'
    }

    $body = @{
        "resourceType" = "AzureApplicationPackage"
        "fileName" = $FileName
        "fileSasUri" = $FilesasUri
        "state" = "Uploaded"
        "@odata.etag" = $putzipetagIDs
        "id" = $putzipIDs
      } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}
