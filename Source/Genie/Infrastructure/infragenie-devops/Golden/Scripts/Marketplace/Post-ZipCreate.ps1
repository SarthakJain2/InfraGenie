function Create-ZipCreate {
    param (
        [string]$ProductId,
        [string]$AccessToken,
        [string]$FileName
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packages"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }
    $body = @{
        resourceType = "AzureApplicationPackage"
        filename = $FileName
        } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}
