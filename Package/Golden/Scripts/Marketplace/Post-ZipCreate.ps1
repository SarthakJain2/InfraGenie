function Create-ZipCreate {
    param (
        [string]$ProductID,
        [string]$token
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packages"
    $headers = @{
        Authorization = "Bearer $token"
        
        'Content-Type' = 'application/json'
    }
    $body = @{
        resourceType = "AzureApplicationPackage"
        filename = "ama-helloworlds.zip"
        } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}
