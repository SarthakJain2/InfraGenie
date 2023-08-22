function Post-Image-215x115 {
    param (
        [string]$ProductId,    
        [string]$AccessToken,
        [string]$GetListingInstanceId,
        [string]$FileName_215x115
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$GetListingInstanceId/images"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "ListingImage"
        fileName = $FileName_215x115
        type = "AzureLogoWide"
        state = "PendingUpload"
        description = ""
        order = 0
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}



