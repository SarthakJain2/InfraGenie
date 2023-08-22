function Post-Image-90x90 {
    param (
        [string]$ProductId,    
        [string]$AccessToken,
        [string]$GetListingInstanceId,
        [string]$FileName_90x90
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$GetListingInstanceId/images"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "ListingImage"
        fileName = $FileName_90x90
        type = "AzureLogoMedium"
        state = "PendingUpload"
        description = ""
        order = 0
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}



